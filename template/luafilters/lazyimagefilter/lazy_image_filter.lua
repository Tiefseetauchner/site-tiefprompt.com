-- Doc and feature pages embed several screenshots per page, each rendered
-- as a plain <img> by pandoc with no loading hints. The browser fetches all
-- of them eagerly on page load, competing with the page's own markup for
-- bandwidth even when most of them are far below the fold.
--
-- This filter marks every image `loading="lazy"` and `decoding="async"` on
-- HTML output, so the browser defers off-screen images until the user
-- scrolls near them and never blocks rendering on decoding them.

local function handle_image(el)
  if not (FORMAT and FORMAT:match('html')) then
    return nil
  end

  el.attributes.loading = 'lazy'
  el.attributes.decoding = 'async'
  return el
end

return {
  {
    Image = handle_image,
  },
}
