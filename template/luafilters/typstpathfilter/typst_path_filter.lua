-- Local resource paths (images, downloadable files, ...) are written
-- relative to the *source* markdown file -- e.g. a page nested under
-- 02Usage/ reaches Documentation/resources/ via '../resources/foo.png'.
-- That's correct for HTML, since each page keeps its own directory
-- structure in the output. But the Typst/PDF bundle concatenates every
-- page into one output.typ living at the project root, next to a single
-- copied resources/ folder (see bundle.typ), so from there the same path
-- just needs to be 'resources/foo.png' -- any leading '../' has to go,
-- regardless of how deeply the source file was nested.
--
-- Only does anything when converting to Typst; a no-op otherwise.

local function rebase(path)
  if not path then
    return path
  end
  local rebased = path:gsub('^%.%./+', '')
  while rebased:match('^%.%./') do
    rebased = rebased:gsub('^%.%./+', '')
  end
  return rebased
end

local function handle_image(el)
  if not (FORMAT and FORMAT:match('typst')) then
    return nil
  end

  if el.src ~= nil then
    el.src = rebase(el.src)
  else
    el.target = rebase(el.target)
  end
  return el
end

local function handle_link(el)
  if not (FORMAT and FORMAT:match('typst')) then
    return nil
  end

  -- Leave alone anything that isn't a local relative path (autolink
  -- targets, external URLs, in-document '#' anchors, ...).
  if el.target:match('^%.%./') then
    el.target = rebase(el.target)
  end
  return el
end

return {
  {
    Image = handle_image,
    Link = handle_link,
  },
}
