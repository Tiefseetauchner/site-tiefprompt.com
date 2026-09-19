local M = {}

-- Where the cards live, and the card used when nothing else matches.
M.base_url = 'https://tiefprompt.com/images/og/'
M.default_image = 'home.jpg'

-- Turn a config value into an absolute URL. Bare filenames (what ogconfig
-- uses) are resolved against base_url; anything already absolute is passed
-- through untouched, so front matter can point somewhere else entirely.
local function to_url(image)
  if type(image) ~= 'string' or image == '' then
    return nil
  end
  if image:match('^https?://') then
    return image
  end
  return M.base_url .. image
end

-- base_path arrives straight from project metadata, so it may be a pandoc
-- MetaValue rather than a plain string. Normalize before comparing.
local function normalize_base_path(base_path)
  if base_path == nil or type(base_path) == 'string' then
    return base_path
  end
  return pandoc.utils.stringify(base_path)
end

-- Pick the rule group matching this project's base path. The main site sets
-- no base_path metadata, so it's keyed under '/' -- see ogconfig.lua.
local function group_for(base_path, rules)
  base_path = normalize_base_path(base_path)
  local key = (base_path == nil or base_path == '') and '/' or base_path
  for _, group in ipairs(rules or {}) do
    if group.base_path == key then
      return group.images
    end
  end
  return nil
end

-- Resolve a node's og:image URL. Front matter wins, then the first matching
-- path rule, then the site default -- so this always returns a usable URL.
function M.resolve(node, base_path, rules)
  node = node or {}

  local fm = node.front_matter or {}
  local from_fm = to_url(fm.og_image)
  if from_fm then
    return from_fm
  end

  local path = node.path
  if path then
    for _, rule in ipairs(group_for(base_path, rules) or {}) do
      if rule.pattern and path:find(rule.pattern) then
        local from_rule = to_url(rule.image)
        if from_rule then
          return from_rule
        end
        break
      end
    end
  end

  return M.base_url .. M.default_image
end

return M
