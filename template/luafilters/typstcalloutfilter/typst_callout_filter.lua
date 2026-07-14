-- Callout boxes are annotated with a class like `callout-info` or `callout-warn` in markdown.
-- Pandoc's Typst writer has no idea what to do with them and silently drops the class,
-- leaving the callout box unstyled. This filter turns a `callout-<TYPE>` class into
-- an explicit Typst callout box (`#callout(type: "<TYPE>")[<CONTENT>]`), which the 
-- Typst writer does understand thanks to the 00Defs.typ defining said callout macro.

local function handle_div(el)
  if not (FORMAT and FORMAT:match('typst')) then
    return nil
  end

  for i, class in ipairs(el.classes) do
    local callout_type = class:match('^callout%-(%w+)$')
    if callout_type then
      table.remove(el.classes, i)
      return pandoc.RawBlock('typst', string.format('#callout(type: "%s")[', callout_type) .. pandoc.utils.stringify(el.content) .. ']')
    end
  end

  return nil
end

return {
  {
    Div = handle_div,
  },
}