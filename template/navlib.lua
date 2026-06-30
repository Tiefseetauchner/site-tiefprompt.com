local M = {}

local stringify = pandoc.utils.stringify

-- Recursively turn a pandoc MetaValue into a plain Lua value: maps become
-- tables, lists become arrays, inline/block content is stringified.
local function meta_to_value(v)
  local t = pandoc.utils.type(v)

  if t == 'boolean' or t == 'number' or t == 'string' then
    return v
  elseif t == 'Inlines' or t == 'Blocks' then
    return stringify(v)
  elseif t == 'List' then
    local arr = {}
    for i, item in ipairs(v) do
      arr[i] = meta_to_value(item)
    end
    return arr
  elseif t == 'table' or t == 'Meta' then
    local obj = {}
    for k, item in pairs(v) do
      obj[tostring(k)] = meta_to_value(item)
    end
    return obj
  else
    return stringify(v)
  end
end

-- Convert a MetaMap representing a node into a plain Lua table.
local function normalize_node(m)
  return {
    id = m.id and m.id.value and stringify(m.id.value) or nil,
    path = m.path and stringify(m.path) or nil,
    title = m.title and stringify(m.title) or nil,
    prev = m.prev and m.prev.value and stringify(m.prev.value) or nil,
    next = m.next and m.next.value and stringify(m.next.value) or nil,
    depth = m.depth and tonumber(stringify(m.depth)) or nil,
    front_matter = m.front_matter and meta_to_value(m.front_matter) or {},
  }
end

-- Build lookup + ordered list of nodes from metadata.
function M.build(meta)
  if not meta.nodes then
    return nil
  end

  local nodes = {}
  local ordered = {}
  for _, m in ipairs(meta.nodes) do
    local n = normalize_node(m)
    if n.id then
      nodes[n.id] = n
      ordered[#ordered + 1] = n
    end
  end

  local current = nil
  if meta.current then
    current = normalize_node(meta.current)
  end

  return {
    nodes = nodes,
    ordered = ordered,
    current = current,
  }
end

-- Look up a node by ID
function M.get_node(nav, id)
  if not nav or not nav.nodes then
    return nil
  end
  return nav.nodes[id]
end

local function href_from_path(path)
  local href = '/' .. (path or '')
  href = href:gsub('index%.html$', '')
  href = href:gsub('%.html$', '')
  href = href:gsub('//+', '/')
  if #href > 1 then
    href = href:gsub('/$', '')
  end
  return href
end

-- Substitute %1..%9 capture references in a rule string.
local function apply_captures(value, caps)
  if type(value) ~= 'string' then
    return value
  end
  return (value:gsub('%%(%d)', function(d)
    return caps[tonumber(d)] or ''
  end))
end

-- Resolve a node into a nav entry using ordered rules, with front matter
-- overriding any matched rule. Returns { label, group, href, hidden, order }.
function M.classify(node, rules)
  local entry = {
    path = node.path,
    href = href_from_path(node.path),
    label = node.title,
    group = nil,
    hidden = false,
    order = nil,
  }

  for _, rule in ipairs(rules or {}) do
    if node.path and node.path:find(rule.pattern) then
      local caps = { node.path:match(rule.pattern) }
      if rule.label then
        entry.label = apply_captures(rule.label, caps)
      end
      if rule.group ~= nil then
        entry.group = apply_captures(rule.group, caps)
      end
      if rule.hidden ~= nil then
        entry.hidden = rule.hidden
      end
      if rule.order ~= nil then
        entry.order = rule.order
      end
      break
    end
  end

  local fm = node.front_matter or {}
  if fm.nav_label ~= nil then
    entry.label = fm.nav_label
  end
  if fm.nav_group ~= nil then
    entry.group = fm.nav_group
  end
  if fm.nav_hidden ~= nil then
    entry.hidden = fm.nav_hidden == true or fm.nav_hidden == 'true'
  end
  if fm.nav_order ~= nil then
    entry.order = tonumber(fm.nav_order) or entry.order
  end

  return entry
end

-- Build an ordered nav tree from the node list and rules. Top-level entries
-- and groups (collapsed dropdowns) are returned as a flat ordered list:
--   { kind = 'link',  label, href, active }
--   { kind = 'group', label, children = { <link>, ... } }
function M.tree(nav, rules)
  local items = {}
  local group_index = {}
  local current_path = nav.current and nav.current.path or nil

  for idx, node in ipairs(nav.ordered or {}) do
    local entry = M.classify(node, rules)
    if not entry.hidden then
      local order = entry.order or idx
      local link = {
        kind = 'link',
        label = entry.label,
        href = entry.href,
        active = current_path ~= nil and entry.path == current_path,
        order = order,
      }

      if entry.group then
        local g = group_index[entry.group]
        if not g then
          g = { kind = 'group', label = entry.group, children = {}, order = order }
          group_index[entry.group] = g
          items[#items + 1] = g
        end
        if order < g.order then
          g.order = order
        end
        if link.active then
          g.active = true
        end
        g.children[#g.children + 1] = link
      else
        items[#items + 1] = link
      end
    end
  end

  local function by_order(a, b)
    return a.order < b.order
  end

  table.sort(items, by_order)
  for _, item in ipairs(items) do
    if item.kind == 'group' then
      table.sort(item.children, by_order)
    end
  end

  return items
end

return M
