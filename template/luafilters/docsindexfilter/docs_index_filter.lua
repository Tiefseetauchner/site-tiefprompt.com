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

local function prefixed_href(item)
  if item.static or not BASE_PATH then
    return item.href
  end
  return '/' .. BASE_PATH .. item.href
end

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
  local cls = ''
  return string.format(
    '<li><a class="%s" href="%s">%s</a></li>',
    cls, escape(prefixed_href(item)), escape(item.label)
  )
end

local function render_group(group)
  local children = {}
  for _, item in ipairs(group.children) do
    if item.kind == 'group' then
      children[#children + 1] = render_group(item)
    else
      children[#children + 1] = render_link(item)
    end
  end

  return string.format(
    '<li>'
      .. '<span>%s</span>'
      .. '<ul>%s</ul>'
      .. '</li>',
    escape(group.label), table.concat(children)
  )
end

local function render_index()
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

  return string.format(
    '<ul>%s</ul>',
    table.concat(items)
  )
end

local function is_placeholder(text)
  return type(text) == 'string' and text:find('docsindex')
end

local function handle_raw_block(el)
  if type(el.format) == 'string'
    and el.format:lower():match('html')
    and is_placeholder(el.text)
  then
    return pandoc.RawBlock('html', render_index())
  end
  return nil
end

local function handle_div(el)
  if el.identifier == 'docsindex' or (el.classes and el.classes:includes('docsindex')) then
    return pandoc.RawBlock('html', render_index())
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
