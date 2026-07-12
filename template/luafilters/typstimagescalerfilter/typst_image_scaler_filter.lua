-- Markdown images are annotated with Bootstrap-style width classes, e.g.
-- `{.w-100}` for full width. HTML picks these up as actual CSS classes,
-- but pandoc's Typst writer has no idea what to do with them and silently
-- drops the class, leaving every image at its native pixel size. For the
-- high-resolution screenshots used throughout the docs, that renders
-- far too large in the PDF.
--
-- This filter turns a `w-<N>` class into an explicit Typst width
-- (`{width=N%}`), which the Typst writer does understand. SCALE is
-- applied on top of that percentage, so the whole PDF's image size can
-- be tuned from one place without editing every doc page.

local SCALE = 0.9

local function handle_image(el)
  if not (FORMAT and FORMAT:match('typst')) then
    return nil
  end

  for i, class in ipairs(el.classes) do
    local percent = class:match('^w%-(%d+)$')
    if percent then
      table.remove(el.classes, i)
      el.attributes.width = string.format('%g%%', tonumber(percent) * SCALE)
      return el
    end
  end

  return nil
end

return {
  {
    Image = handle_image,
  },
}
