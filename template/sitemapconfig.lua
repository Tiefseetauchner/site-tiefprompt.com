-- Sitemap rules for this site, consumed by sitemap_filter.lua.
--
-- `base_url` is prepended to every clean page URL. Each rule in `rules` matches
-- a page's URL path (a Lua pattern, tested against the leading '/...'); the
-- first match wins and sets <priority>/<changefreq>. The final catch-all rule
-- ('.*') applies to anything not matched earlier, so keep it last.
--
-- A page opts out of the sitemap entirely with `sitemap: false` in its front
-- matter; the 404 page is always excluded (see sitemap_filter.lua).

return {
  base_url = 'https://tiefprompt.com',

  rules = {
    { pattern = '^/$',         priority = '1.0', changefreq = 'weekly'  }, -- home
    { pattern = '^/features/',  priority = '0.8', changefreq = 'monthly' },
    { pattern = '^/support$',   priority = '0.5', changefreq = 'monthly' },
    { pattern = '^/policies/',  priority = '0.3', changefreq = 'yearly'  },
    { pattern = '^/imprint$',   priority = '0.3', changefreq = 'yearly'  },
    { pattern = '.*',           priority = '0.5', changefreq = 'monthly' }, -- fallback
  },
}
