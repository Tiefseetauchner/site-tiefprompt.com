-- Navigation rules for this site, consumed by nav_filter.lua via navlib.
--
-- Each rule matches a node's output path (a Lua pattern). First match wins;
-- a page's `nav_*` front matter overrides whatever a rule sets. `%1`..`%9` in
-- `label`/`group` refer to captures from `pattern`.
--
-- Fields: pattern, label, group, hidden, order.

return {
  -- Home
  { pattern = '^index%.html$', label = 'Home', order = 0 },

  -- Feature pages collapse into a "Features" dropdown
  { pattern = '^features/', group = 'Features', order = 10 },

  -- Privacy policies grouped by language code captured from the path
  { pattern = '^policies/privacy/(%w+)/', group = 'Privacy', label = '%1', order = 20 },

  -- Top-level support link
  { pattern = '^support/', label = 'Support', order = 30 },

  -- Imprint is reachable from the footer only
  { pattern = '^imprint/', hidden = true },

  -- 404 shouldn't be in the nav
  { pattern = '^404%.html$', hidden = true },
}
