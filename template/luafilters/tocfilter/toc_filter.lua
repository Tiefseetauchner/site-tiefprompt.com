-- "On this page" sidebar filter.
--
-- Scoped to the Documentation project only, via the same meta.base_path
-- signal nav_filter.lua / docs_index_filter.lua / mega_replacer_filter.lua
-- already use (set per-project in manifest.toml's metadata_fields) -- no
-- new metadata field, no per-file authoring.
--
-- Collects h2/h3 Header blocks (pandoc's auto_identifiers extension has
-- already stamped ids on them by the time this filter runs) and, if the
-- page has any, wraps the document as:
--
--   <div class="docs-layout">
--     <div class="docs-content">...original content...</div>
--     <button class="docs-toc-toggle">On this page</button>
--     <aside class="docs-toc" id="docsToc"><nav><ul>...</ul></nav></aside>
--   </div>
--
-- Scrollspy and the responsive toggle are client-side (static_resources/js/toc.js);
-- this filter only emits the static markup and anchors.

local BASE_PATH = nil

local function capture_meta(meta)
  BASE_PATH = nil
  if meta.base_path then
    local trimmed = pandoc.utils.stringify(meta.base_path):gsub('^/+', ''):gsub('/+$', '')
    if trimmed ~= '' then
      BASE_PATH = trimmed
    end
  end

  return meta
end

local function escape(s)
  return (tostring(s or '')
    :gsub('&', '&amp;')
    :gsub('<', '&lt;')
    :gsub('>', '&gt;')
    :gsub('"', '&quot;'))
end

local function collect_headers(blocks)
  local headers = {}
  for _, block in ipairs(blocks) do
    if block.t == 'Header' and (block.level == 2 or block.level == 3) then
      headers[#headers + 1] = {
        level = block.level,
        id = block.identifier,
        text = pandoc.utils.stringify(block.content),
      }
    end
  end
  return headers
end

local function render_link(header)
  return string.format(
    '<li><a href="#%s">%s</a>',
    escape(header.id), escape(header.text)
  )
end

local function render_toc(headers)
  local items = {}
  local open_h3_list = false

  for _, header in ipairs(headers) do
    if header.level == 2 then
      if open_h3_list then
        items[#items + 1] = '</ul></li>'
        open_h3_list = false
      elseif #items > 0 then
        items[#items + 1] = '</li>'
      end
      items[#items + 1] = render_link(header)
    else
      if not open_h3_list then
        items[#items + 1] = '<ul>'
        open_h3_list = true
      end
      items[#items + 1] = render_link(header) .. '</li>'
    end
  end

  if open_h3_list then
    items[#items + 1] = '</ul>'
  end
  if #items > 0 then
    items[#items + 1] = '</li>'
  end

  return table.concat({
    '<button type="button" class="docs-toc-toggle" aria-expanded="false" aria-controls="docsToc">On this page</button>',
    '<aside class="docs-toc" id="docsToc">',
    '  <nav aria-label="On this page">',
    '    <ul>',
    table.concat(items),
    '    </ul>',
    '  </nav>',
    '</aside>',
  }, '\n')
end

local function handle_pandoc(doc)
  if not BASE_PATH then
    return doc
  end

  local headers = collect_headers(doc.blocks)
  if #headers == 0 then
    return doc
  end

  -- The toggle/sidebar come first in document order so that on narrow
  -- viewports (where .docs-layout is plain block flow, not flex) the toggle
  -- button lands right under the nav instead of after all the article
  -- content. At the lg breakpoint, CSS `order` swaps it back to the right.
  local content_div = pandoc.Div(doc.blocks, { class = 'docs-content' })
  local sidebar = pandoc.RawBlock('html', render_toc(headers))
  local layout = pandoc.Div({ sidebar, content_div }, { class = 'docs-layout' })

  return pandoc.Pandoc({ layout }, doc.meta)
end

return {
  { Meta = capture_meta },
  { Pandoc = handle_pandoc },
}
