-- Populates the `tiefsitemap` placeholder with a sitemap <urlset>, mirroring how
-- nav_filter populates `tiefnav`.
--
-- This runs only for the Sitemap markdown project (the single file that carries
-- the placeholder), not on every page compile. The page list comes from
-- `.meta_nav.json`, which the main HTML conversion writes earlier in the same
-- build and which this template leaves untouched (it declares no meta_gen).
-- Priority/changefreq rules and the base URL live in sitemapconfig.lua.

local config = require 'sitemapconfig'

local NAV_META_FILE = '.meta_nav.json'

-- Clean URL from an output path, matching navlib.href_from_path:
-- 'index.html' -> '/', 'features/x/index.html' -> '/features/x'.
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

local function classify(href)
  for _, rule in ipairs(config.rules or {}) do
    if href:find(rule.pattern) then
      return rule.priority, rule.changefreq
    end
  end
  return '0.5', 'monthly'
end

local function escape(s)
  return (tostring(s or '')
    :gsub('&', '&amp;')
    :gsub('<', '&lt;')
    :gsub('>', '&gt;')
    :gsub('"', '&quot;')
    :gsub("'", '&apos;'))
end

local function is_excluded(node)
  if not node.path or node.path == '' then
    return true
  end
  if node.path:match('^404%.html$') then
    return true
  end
  local fm = node.front_matter or {}
  if fm.sitemap == false or fm.sitemap == 'false' then
    return true
  end
  return false
end

local function read_nodes()
  local f = io.open(NAV_META_FILE, 'r')
  if not f then
    return {}
  end
  local raw = f:read('*a')
  f:close()
  local ok, meta = pcall(pandoc.json.decode, raw)
  if not ok or type(meta) ~= 'table' then
    return {}
  end
  return meta.nodes or {}
end

local function render()
  -- No <?xml?> declaration: the build prepends blank lines from the (empty)
  -- header injection, and whitespace before the declaration is invalid XML.
  -- The declaration is optional and UTF-8 is the default, so we omit it;
  -- leading whitespace before the root <urlset> element is allowed.
  local out = {
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
  }

  local seen = {}
  for _, node in ipairs(read_nodes()) do
    if not is_excluded(node) then
      local href = href_from_path(node.path)
      if not seen[href] then
        seen[href] = true
        local priority, changefreq = classify(href)
        out[#out + 1] = '  <url>'
        out[#out + 1] = '    <loc>' .. escape(config.base_url .. href) .. '</loc>'
        out[#out + 1] = '    <changefreq>' .. changefreq .. '</changefreq>'
        out[#out + 1] = '    <priority>' .. priority .. '</priority>'
        out[#out + 1] = '  </url>'
      end
    end
  end

  out[#out + 1] = '</urlset>'
  return table.concat(out, '\n')
end

local function is_placeholder(text)
  return type(text) == 'string' and text:find('tiefsitemap')
end

local function handle_raw_block(el)
  if type(el.format) == 'string'
    and el.format:lower():match('html')
    and is_placeholder(el.text)
  then
    return pandoc.RawBlock('html', render())
  end
  return nil
end

local function handle_div(el)
  if el.identifier == 'tiefsitemap'
    or (el.classes and el.classes:includes('tiefsitemap'))
  then
    return pandoc.RawBlock('html', render())
  end
  return nil
end

return {
  {
    RawBlock = handle_raw_block,
    Div = handle_div,
  },
}
