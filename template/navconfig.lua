-- Navigation rules for this site, consumed by nav_filter.lua via navlib.
--
-- Rules are grouped by the base path of the project they apply to. base_path
-- is the same value set per markdown project in manifest.toml's
-- metadata_fields (see nav_filter.lua) -- the main site sets none, so it's
-- keyed under '/'; Documentation sets base_path = "docs/web".
--
-- Within a group, each rule matches a node's output path (a Lua pattern,
-- relative to that project's own root). First match wins; a page's `nav_*`
-- front matter overrides whatever a rule sets. `%1`..`%9` in `label`/`group`
-- refer to captures from `pattern`.
--
-- A rule with `static = true` isn't matched against nodes at all -- it's
-- always rendered as a fixed `href`/`label`, useful for linking into another
-- project's pages (which never appear in this project's own node list). See
-- navlib.tree for details.
--
-- Fields: pattern, label, group, hidden, order, keep_extension, static, href.

return {
  {
    base_path = '/',
    paths = {
      -- Home
      { pattern = '^index%.html$', label = 'Home', order = 0 },

      -- Feature pages collapse into a "Features" dropdown
      { pattern = '^features/', group = 'Features', order = 10 },

      -- Privacy policies grouped by language code captured from the path
      { pattern = '^policies/privacy/(%w+)/', group = 'Privacy', label = '%1', order = 20 },

      -- Top-level support link
      { pattern = '^support/', label = 'Support', order = 30 },

      -- Documentation is its own markdown project/base path, so it never
      -- shows up in this project's own nodes -- link to it statically.
      { static = true, href = '/docs/web/', label = 'Documentation', order = 40 },

      -- Imprint is reachable from the footer only
      { pattern = '^imprint/', hidden = true },

      -- Donate page is reachable from the footer only
      { pattern = '^donate/', hidden = true },

      -- separate changelog versions are hidden from nav
      { pattern = '^changelogs/(%d+)', hidden = true },

      -- 404 shouldn't be in the nav
      { pattern = '^(%d+)%.html$', hidden = true },
    },
  },
  {
    base_path = 'docs/web',
    paths = {
      -- Index
      { pattern = '^index%.html$', label = 'Index', order = 0 },

      -- Flat files in the root of the docs project (e.g. "01GettingStarted.md") are top-level
      -- and need to preserve the extension. It must exclude '/' so it doesn't match section folders
      { pattern = '^(%d+)([^/]+)%.html$', label = '%2', order = 10, keep_extension = true },

      -- Section folders (e.g. "02Usage/01Setup.md") collapse into a
      -- dropdown keyed by the folder name; the display name and sort order
      -- for that key come from the `groups` map in the section index's
      -- front matter (see index.typign_md), resolved by navlib.tree.
      -- Documentation pages are flat files (no directory/index.html nesting
      -- like the rest of the site), so they need the .html extension kept.
      { pattern = '^(%d+%a+)/%d+(.+)%.html$', group = '%1', label = '%2', keep_extension = true, order = 10 },
    },
  },
}
