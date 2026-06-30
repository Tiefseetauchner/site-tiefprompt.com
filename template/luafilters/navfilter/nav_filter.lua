local navlib = require 'navlib'
local navconfig = require 'navconfig'

local NAV = nil

local function capture_meta(meta)
  NAV = navlib.build(meta)
  return meta
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
    cls, escape(item.href), escape(item.label)
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
      item_cls, escape(child.href), escape(child.label)
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
  for _, item in ipairs(navlib.tree(NAV, navconfig)) do
    if item.kind == 'group' then
      items[#items + 1] = render_group(item)
    else
      items[#items + 1] = render_link(item)
    end
  end

  return table.concat({
    '<nav class="navbar navbar-expand-lg navbar-dark bg-dark">',
    '  <div class="container">',
    '    <a class="navbar-brand" href="/">TiefPrompt</a>',
    '    <button class="navbar-toggler" type="button" data-bs-toggle="collapse"',
    '      data-bs-target="#navMain" aria-controls="navMain" aria-expanded="false"',
    '      aria-label="Toggle navigation">',
    '      <span class="navbar-toggler-icon"></span>',
    '    </button>',
    '    <div class="collapse navbar-collapse" id="navMain">',
    '      <ul class="navbar-nav ms-auto">',
    table.concat(items, '\n'),
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
