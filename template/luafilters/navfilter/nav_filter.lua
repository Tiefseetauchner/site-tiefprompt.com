local navlib = require 'navlib'
local navconfig = require 'navconfig'

local NAV = nil
local BASE_PATH = nil

local function capture_meta(meta)
  NAV = navlib.build(meta)

  BASE_PATH = nil
  if meta.base_path then
    local trimmed = pandoc.utils.stringify(meta.base_path):gsub('^/+', ''):gsub('/+$', '')
    if trimmed ~= '' then
      BASE_PATH = trimmed
    end
  end

  return meta
end

-- Nav hrefs are built from a path relative to this document's own markdown
-- project, which knows nothing about where that project's output lands in
-- the final site (e.g. Documentation builds under /docs/web/). base_path
-- (set per-project via manifest.toml's metadata_fields) closes that gap.
-- Static links (see navlib.tree) already carry a final href, so they're
-- passed through untouched.
local function prefixed_href(item)
  if item.static or not BASE_PATH then
    return item.href
  end
  return '/' .. BASE_PATH .. item.href
end

-- navconfig groups its rules by the base path they apply to (see
-- navconfig.lua). Find the group matching the current document's base_path,
-- falling back to '/' for projects that don't set one.
local function rules_for_base_path()
  local key = BASE_PATH or '/'
  for _, group in ipairs(navconfig) do
    if group.base_path == key then
      return group.paths
    end
  end
  return {}
end

local function escape(s)
  return (tostring(s or '')
    :gsub('&', '&amp;')
    :gsub('<', '&lt;')
    :gsub('>', '&gt;')
    :gsub('"', '&quot;'))
end

local function render_link(item)
  local cls = 'nav-link'
  if item.active then
    cls = cls .. ' active'
  end
  return string.format(
    '<li class="nav-item"><a class="%s" href="%s">%s</a></li>',
    cls, escape(prefixed_href(item)), escape(item.label)
  )
end

local function render_group(group)
  local toggle_cls = 'nav-link dropdown-toggle'
  if group.active then
    toggle_cls = toggle_cls .. ' active'
  end

  local children = {}
  for _, child in ipairs(group.children) do
    local item_cls = 'dropdown-item'
    if child.active then
      item_cls = item_cls .. ' active'
    end
    children[#children + 1] = string.format(
      '<li><a class="%s" href="%s">%s</a></li>',
      item_cls, escape(prefixed_href(child)), escape(child.label)
    )
  end

  return string.format(
    '<li class="nav-item dropdown">'
      .. '<a class="%s" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">%s</a>'
      .. '<ul class="dropdown-menu">%s</ul>'
      .. '</li>',
    toggle_cls, escape(group.label), table.concat(children)
  )
end

local function render_navbar()
  if not NAV then
    return ''
  end

  local items = {}
  for _, item in ipairs(navlib.tree(NAV, rules_for_base_path())) do
    if item.kind == 'group' then
      items[#items + 1] = render_group(item)
    else
      items[#items + 1] = render_link(item)
    end
  end

  -- Bootstrap 5.3: the navbar adapts to the active color mode on its own, so
  -- no navbar-dark/navbar-light is needed. The toggle button swaps between the
  -- abyss (dark) and the shallows (light); see custom-tail.html for the wiring
  -- and tiefprompt.scss for which icon shows in which mode.
  -- Teleprompter (fun) mode: turns the marketing site into a live demo of the
  -- product -- the page mirrors, blows up the type, and auto-scrolls like a real
  -- teleprompter. Wiring lives in js/fun.js, styles in scss/_fun.scss, and the
  -- no-flash bootstrap in custom-head-2.html.
  local fun_toggle = table.concat({
    '<li class="nav-item d-flex align-items-center">',
    '  <button type="button" id="funToggle" class="btn btn-link nav-link border-0 px-2"',
    '    aria-label="Toggle teleprompter mode" aria-pressed="false" title="Teleprompter mode">',
    '    <svg class="fun-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16" aria-hidden="true">',
    '      <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/>',
    '      <path d="M6.271 5.055a.5.5 0 0 1 .52.038l3.5 2.5a.5.5 0 0 1 0 .814l-3.5 2.5A.5.5 0 0 1 6 10.5v-5a.5.5 0 0 1 .271-.445"/>',
    '    </svg>',
    '  </button>',
    '</li>',
  }, '\n')

  local theme_toggle = table.concat({
    '<li class="nav-item d-flex align-items-center">',
    '  <button type="button" id="themeToggle" class="btn btn-link nav-link border-0 px-2"',
    '    aria-label="Toggle dark mode" title="Toggle dark mode">',
    '    <svg class="theme-icon theme-icon-dark" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16" aria-hidden="true">',
    '      <path d="M6 .278a.77.77 0 0 1 .08.858 7.2 7.2 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277q.792-.001 1.533-.16a.79.79 0 0 1 .81.316.73.73 0 0 1-.031.893A8.35 8.35 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.75.75 0 0 1 6 .278"/>',
    '    </svg>',
    '    <svg class="theme-icon theme-icon-light" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16" aria-hidden="true">',
    '      <path d="M8 11a3 3 0 1 1 0-6 3 3 0 0 1 0 6m0 1a4 4 0 1 0 0-8 4 4 0 0 0 0 8M8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0m0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13m8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5M3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8m10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0m-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0m9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707M4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708"/>',
    '    </svg>',
    '  </button>',
    '</li>',
  }, '\n')

  return table.concat({
    '<nav class="navbar navbar-expand-lg bg-body-tertiary border-bottom">',
    '  <div class="container">',
    '    <a class="navbar-brand" href="/">TiefPrompt</a>',
    '    <button class="navbar-toggler" type="button" data-bs-toggle="collapse"',
    '      data-bs-target="#navMain" aria-controls="navMain" aria-expanded="false"',
    '      aria-label="Toggle navigation">',
    '      <span class="navbar-toggler-icon"></span>',
    '    </button>',
    '    <div class="collapse navbar-collapse" id="navMain">',
    '      <ul class="navbar-nav ms-auto align-items-lg-center">',
    table.concat(items, '\n'),
    fun_toggle,
    theme_toggle,
    '      </ul>',
    '    </div>',
    '  </div>',
    '</nav>',
  }, '\n')
end

local function is_placeholder(text)
  return type(text) == 'string' and text:find('tiefnav')
end

local function handle_raw_block(el)
  if type(el.format) == 'string'
    and el.format:lower():match('html')
    and is_placeholder(el.text)
  then
    return pandoc.RawBlock('html', render_navbar())
  end
  return nil
end

local function handle_div(el)
  if el.identifier == 'tiefnav' or (el.classes and el.classes:includes('tiefnav')) then
    return pandoc.RawBlock('html', render_navbar())
  end
  return nil
end

return {
  { Meta = capture_meta },
  {
    RawBlock = handle_raw_block,
    Div = handle_div,
  },
}
