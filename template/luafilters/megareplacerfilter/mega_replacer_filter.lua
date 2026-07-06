local navlib = require 'navlib'
local navconfig = require 'navconfig'

local DOCMETA = {}
local NAV = {}
local BASE_PATH = nil

local function build_nav(meta)
  local nav = navlib.build(meta)
  if nav then
    return nav
  end
  return {}
end

local function capture_meta(meta)
  DOCMETA = meta
  NAV = build_nav(meta)

  BASE_PATH = nil
  if meta.base_path then
    local trimmed = pandoc.utils.stringify(meta.base_path):gsub('^/+', ''):gsub('/+$', '')
    if trimmed ~= '' then
      BASE_PATH = trimmed
    end
  end

  return meta
end

-- Same rule-selection logic as nav_filter.lua: find the navconfig group
-- matching this document's base_path (see navconfig.lua for why).
local function rules_for_base_path()
  local key = BASE_PATH or '/'
  for _, group in ipairs(navconfig) do
    if group.base_path == key then
      return group.paths
    end
  end
  return {}
end

local function prefixed_href(href)
  if not BASE_PATH then
    return href
  end
  return '/' .. BASE_PATH .. href
end

local function trim(s)
  return s:match('^%s*(.-)%s*$')
end

local function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

local function unescape(url)
  return url:gsub('%%(%x%x)', hex_to_char)
end

local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

local function resolve_path(path, root)
  local cur = root

  for segment in path:gmatch('[^%.]+') do
    local key, idx = segment:match('^([%w_]+)%[(%d+)%]$')
    if key then
      cur = cur and cur[key]
      if not cur then return nil end
      local i = tonumber(idx) + 1
      cur = cur[i]
    else
      cur = cur and cur[segment]
    end
    if not cur then return nil end
  end

  return cur
end

-- autolink: links between Documentation pages have to mean two different
-- things depending on the output. In HTML, each page is its own file, so a
-- link is a normal cross-file href (through navlib/navconfig, same as the
-- navbar). In the Typst/PDF bundle every page is concatenated into one
-- flowing document -- there are no separate pages to link to, so instead we
-- jump to an anchor labelled with the target page's nav id.
--
-- That anchor has to be placed explicitly by the target page itself, via
-- `{{ anchor: '<its own source path>' }}` (see build_anchor below) --
-- Documentation is converted to Typst as a single combined pandoc run over
-- every page's markdown concatenated together (verified: the Meta filter
-- only fires once, with meta.current unset), so there is no per-page hook
-- to insert the anchor automatically the way there would be for a
-- multi_file_output template. Pages that are never autolinked to don't
-- need one.
local function typst_anchor_label(node_id)
  return 'autolink-' .. tostring(node_id):gsub('%W', '-')
end

-- Pulls quoted arguments out of an `autolink: 'path', 'label'` expression.
-- Pandoc's smart-typography extension rewrites straight quotes to curly
-- ones before filters ever see the text, so both styles need to be
-- matched; doesn't need to handle escaping since these are just relative
-- file paths and short labels.
local QUOTE_PATTERNS = {
  "'([^']*)'",
  '"([^"]*)"',
  '‘([^’]*)’',
  '“([^”]*)”',
}

local function extract_args(s)
  for _, pat in ipairs(QUOTE_PATTERNS) do
    local args = {}
    for q in s:gmatch(pat) do
      args[#args + 1] = q
    end
    if #args > 0 then
      return args
    end
  end
  return {}
end

-- autolink targets are given as the source markdown path (e.g.
-- '02Usage/01Setup.md'), matching what you'd write in a normal markdown
-- link. What nav node.path holds depends on the template doing the nav-meta
-- generation: the HTML template rewrites it to its own output path (e.g.
-- '02Usage/01Setup.html'), while the PDF/Typst template (single-file, no
-- output_extension of its own) leaves it as the source path. Try both so
-- this works the same regardless of which pipeline is currently converting.
local function find_node_by_source_path(source_path)
  local html_target = source_path:gsub('%.md$', '.html')
  for _, node in ipairs(NAV.ordered or {}) do
    if node.path == html_target or node.path == source_path then
      return node
    end
  end
  return nil
end

-- Builds the inline content for `{{ autolink: '<path>'[, '<label>'] }}`.
-- Returns a list of inlines to splice into the document, or nil if the
-- expression isn't an autolink call at all.
local function build_autolink(expr_text)
  local lower = expr_text:lower()
  if lower:sub(1, 9) ~= 'autolink:' then
    return nil
  end

  local args = extract_args(expr_text:sub(10))
  local source_path = args[1]
  if not source_path then
    return { pandoc.Str('{{ ' .. expr_text .. ' RETURNED missing path }}') }
  end

  local node = find_node_by_source_path(source_path)
  if not node then
    return { pandoc.Str('{{ ' .. expr_text .. ' RETURNED unresolved path "' .. source_path .. '" }}') }
  end

  local entry = navlib.classify(node, rules_for_base_path())
  local label = args[2] or entry.label or node.title or source_path

  if FORMAT and FORMAT:match('typst') then
    return { pandoc.Link({ pandoc.Str(label) }, '#' .. typst_anchor_label(node.id)) }
  end

  return { pandoc.Link({ pandoc.Str(label) }, prefixed_href(entry.href)) }
end

-- Builds the inline content for `{{ anchor: '<own source path>' }}`, the
-- landing point for the `autolink:` case above. A no-op outside Typst: HTML
-- pages are already addressable by URL, no in-page anchor needed.
local function build_anchor(expr_text)
  local lower = expr_text:lower()
  if lower:sub(1, 7) ~= 'anchor:' then
    return nil
  end

  if not (FORMAT and FORMAT:match('typst')) then
    return {}
  end

  local args = extract_args(expr_text:sub(8))
  local source_path = args[1]
  if not source_path then
    return { pandoc.Str('{{ ' .. expr_text .. ' RETURNED missing path }}') }
  end

  local node = find_node_by_source_path(source_path)
  if not node then
    return { pandoc.Str('{{ ' .. expr_text .. ' RETURNED unresolved path "' .. source_path .. '" }}') }
  end

  -- A truly empty Span sits so close to neighbouring content (e.g. right
  -- after a heading) that Typst treats it as re-labelling that content
  -- instead of marking its own spot, warning "content labelled multiple
  -- times". A zero-width space gives it just enough of its own presence to
  -- own the label.
  return { pandoc.Span({ pandoc.Str('\226\128\139') }, pandoc.Attr(typst_anchor_label(node.id))) }
end

local function eval_meta_expr(expr)
  expr = trim(expr)
  if expr == '' then
    return ''
  end

  local value = resolve_path(expr, DOCMETA)
  if not value then
    return '{{' .. expr .. '}}'
  end

  return pandoc.utils.stringify(value)
end

local function create_lua_env()
  local env = {
    meta      = DOCMETA,
    M         = DOCMETA,
    pandoc    = pandoc,
    stringify = pandoc.utils.stringify,
    math      = math,
    string    = string,
    table     = table,
    dump      = dump,
    navlib    = navlib,
    nav       = NAV,
  }

  setmetatable(env, { __index = _G })
  return env
end

local function run_lua(expr)
  expr = trim(expr)
  if expr == '' then
    return nil, 'empty expression'
  end

  local env = create_lua_env()
  local chunk, err
  if expr:find('return', 1, true) then
    chunk, err = load(expr, 'meta-expr', 't', env)
  else
    chunk, err = load('return ' .. expr, 'meta-expr', 't', env)
  end

  if not chunk then
    return nil, err
  end

  local ok, result = pcall(chunk)
  if not ok then
    return nil, result
  end

  return result, nil
end

local function eval_lua_expr(expr)
  local value, err = run_lua(expr)

  if err then
    return '{{ lua: ' .. trim(expr) .. ' RETURNED ' .. err .. '}}'
  end

  if not value then
    return 'nil'
  end

  return pandoc.utils.stringify(value)
end

local function eval_condition(expr)
  local value, err = run_lua(expr)
  if value == nil or value == false then
    return false
  end
  return true
end

local function eval_expr(expr)
  expr = trim(expr)
  if expr == '' then
    return ''
  end

  if expr:lower():sub(1, 4) == 'lua:' then
    return eval_lua_expr(expr:sub(5))
  end

  return eval_meta_expr(expr)
end

local function resolve_expr(expr)
  return eval_expr(expr)
end

-- A source line like `{{ expr }}, more text` has no space between the
-- closing braces and the following punctuation, so pandoc glues them into
-- one Str token (e.g. "}},"). Find a Str merely *starting* with "}}" and
-- split off whatever comes after it, so callers can reinsert that tail
-- verbatim instead of it vanishing (or the whole expression failing to
-- match at all).
local function find_closing(inlines, from)
  local j = from
  while j <= #inlines do
    local e = inlines[j]
    if e.t == 'Str' and e.text:sub(1, 2) == '}}' then
      return j, e.text:sub(3)
    end
    j = j + 1
  end
  return nil, nil
end

local function process_inlines(inlines)
  local result = pandoc.List()
  local i = 1

  while i <= #inlines do
    local el = inlines[i]

    if el.t == 'Str' then
      local text = el.text

      local replaced, count = text:gsub('{{(.-)}}', function(inner)
        return resolve_expr(inner)
      end)

      if count > 0 then
        result:insert(pandoc.Str(replaced))
        i = i + 1

      elseif text == '{{' then
        local closing, closing_trailing = find_closing(inlines, i + 1)

        if not closing then
          result:insert(el)
          i = i + 1
        else
          local slice = pandoc.List()
          for k = i + 1, closing - 1 do
            slice:insert(inlines[k])
          end

          local expr_text = pandoc.utils.stringify(pandoc.Inlines(slice))
          local expr_trim = trim(expr_text)
          local lower = expr_trim:lower()

          if lower:sub(1, 9) == 'autolink:' then
            for _, v in ipairs(build_autolink(expr_trim)) do
              result:insert(v)
            end
            if closing_trailing ~= '' then
              result:insert(pandoc.Str(closing_trailing))
            end
            i = closing + 1

          elseif lower:sub(1, 7) == 'anchor:' then
            for _, v in ipairs(build_anchor(expr_trim)) do
              result:insert(v)
            end
            if closing_trailing ~= '' then
              result:insert(pandoc.Str(closing_trailing))
            end
            i = closing + 1

          elseif lower:sub(1, 3) == 'if:' then
            local cond_expr = trim(expr_trim:sub(4))

            local fi_open, fi_close, fi_trailing
            local p = closing + 1

            while p <= #inlines do
              local e = inlines[p]

              if e.t == 'Str' and e.text == '{{' then
                local q_close, q_trailing = find_closing(inlines, p + 1)

                if not q_close then
                  break
                end

                local inner_slice = pandoc.List()
                for r = p + 1, q_close - 1 do
                  inner_slice:insert(inlines[r])
                end

                local inner_expr = trim(pandoc.utils.stringify(pandoc.Inlines(inner_slice)))

                if inner_expr:lower() == 'fi' then
                  fi_open = p
                  fi_close = q_close
                  fi_trailing = q_trailing
                  break
                end

                p = q_close + 1
              else
                p = p + 1
              end
            end

            if not fi_open then
              local replacement = resolve_expr(expr_text)
              result:insert(pandoc.Str(replacement))
              if closing_trailing ~= '' then
                result:insert(pandoc.Str(closing_trailing))
              end
              i = closing + 1
            else
              local cond_ok = eval_condition(cond_expr)

              if cond_ok then
                local inner = pandoc.List()
                if closing_trailing ~= '' then
                  inner:insert(pandoc.Str(closing_trailing))
                end
                for r = closing + 1, fi_open - 1 do
                  inner:insert(inlines[r])
                end

                local processed_inner = process_inlines(inner)
                for _, v in ipairs(processed_inner) do
                  result:insert(v)
                end
              end

              if fi_trailing ~= '' then
                result:insert(pandoc.Str(fi_trailing))
              end
              i = fi_close + 1
            end

          else
            local replacement = resolve_expr(expr_text)
            result:insert(pandoc.Str(replacement))
            if closing_trailing ~= '' then
              result:insert(pandoc.Str(closing_trailing))
            end
            i = closing + 1
          end
        end

      else
        result:insert(el)
        i = i + 1
      end

    elseif el.t == 'Link' then
      el.content = process_inlines(el.content)
      local target = unescape(el.target)
      if target:match('{{') then
        el.target = target:gsub('{{(.-)}}', function(inner)
          return resolve_expr(inner)
        end)
      end
      result:insert(el)
      i = i + 1

    elseif el.t == 'Image' then
      if el.caption and type(el.caption) == 'table' then
        el.caption = process_inlines(el.caption)
      end

      local src = el.src or el.target
      if src then
        local unescaped = unescape(src)
        if unescaped:match('{{') then
          local replaced = unescaped:gsub('{{(.-)}}', function(inner)
            return resolve_expr(inner)
          end)
          if el.src ~= nil then
            el.src = replaced
          else
            el.target = replaced
          end
        end
      end
      result:insert(el)
      i = i + 1

    elseif el.t == 'RawInline' then
      if type(el.format) == 'string'
         and type(el.text) == 'string'
         and el.format:lower():match('html')
      then
        el.text = el.text:gsub('{{(.-)}}', function(inner)
          return resolve_expr(inner)
        end)
      end
      result:insert(el)
      i = i + 1

    else
      if el.content
         and type(el.content) == 'table'
         and el.content[1]
         and type(el.content[1]) == 'table'
         and el.content[1].t
      then
        el.content = process_inlines(el.content)
      end
      result:insert(el)
      i = i + 1
    end
  end

  return result
end

local function handle_block_inlines(el)
  el.content = process_inlines(el.content)
  return el
end

local function handle_raw_block(el)
  if type(el.format) == 'string'
     and type(el.text) == 'string'
     and el.format:lower():match('html')
  then
    el.text = el.text:gsub('{{(.-)}}', function(inner)
      return resolve_expr(inner)
    end)
  end
  return el
end

return {
  { Meta = capture_meta },
  {
    Para   = handle_block_inlines,
    Plain  = handle_block_inlines,
    Header = handle_block_inlines,
    RawBlock = handle_raw_block,
  },
}
