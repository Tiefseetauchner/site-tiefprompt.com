-- Changelog timeline filter.
--
-- Drop a placeholder into a page -- either a fenced div
--
--   ::: tiefchangelog
--   :::
--
-- or a raw-HTML block containing the word `tiefchangelog` -- and this filter
-- swaps in a branching, git-graph style timeline of every changelog page. Like
-- nav_filter.lua it reads the per-page metadata that tiefdownconverter injects
-- (`meta.nodes`, one entry per output page) rather than touching the filesystem.
--
-- Entries are the pages under `changelogs/` (the index itself is skipped),
-- sorted newest-first by the semantic version parsed from the filename.
--
-- Branches
-- --------
-- Each changelog file declares which branch it belongs to via front matter:
--
--   ---
--   branch: release
--   ---
--
-- Files with no `branch` fall on the main branch, which is drawn as the left
-- rail. Everything about the graph is configured on the *host* page (the one
-- carrying the placeholder), so a single place controls the whole picture:
--
--   ---
--   main_branch: main            # name of the left rail (default: "main")
--   branches:                    # optional: order / labels / colours / parents
--     - name: release
--       label: "1.0.x"           # chip shown at the branch tip
--       from: main               # rail it forks off (default: main_branch)
--       color: "#ff7a59"         # rail colour (default: from the palette)
--   milestones:                  # annotations anchored to a version
--     - version: "1.0.0"
--       label: "TiefPrompt 1.0 -- first stable release"
--   ---
--
-- Branches not listed under `branches` still work -- they get a lane, a palette
-- colour, and fork off the main branch, in the order they first appear.
-- Milestones ride the same rail as the version they anchor to, just above it.
--
-- (Later this can be driven by real release dates + branches scraped from the
-- repo; the front matter is just the manual stand-in for now.)

local stringify = pandoc.utils.stringify

local META = nil

-- Geometry. These numbers are mirrored in scss/_changelog.scss (ROW_H / TOP_PAD)
-- so the SVG rails line up with the HTML content column -- keep them in sync.
local ROW_H = 40
local TOP_PAD = 12
local LANE_GAP = 26
local X0 = 16

-- Rail colours are derived from the branch name, so each branch keeps a stable
-- but pseudo-random colour with no palette to maintain (a `color` in the branch
-- config still wins). We fix saturation/lightness for legibility on both themes
-- and let the hash pick the hue.
local COLOR_SAT = 0.60
local COLOR_LIGHT = 0.56

local function hsl_to_hex(h, s, l)
  local c = (1 - math.abs(2 * l - 1)) * s
  local hp = h / 60
  local x = c * (1 - math.abs(hp % 2 - 1))
  local r, g, b = 0, 0, 0
  if hp < 1 then r, g, b = c, x, 0
  elseif hp < 2 then r, g, b = x, c, 0
  elseif hp < 3 then r, g, b = 0, c, x
  elseif hp < 4 then r, g, b = 0, x, c
  elseif hp < 5 then r, g, b = x, 0, c
  else r, g, b = c, 0, x end
  local m = l - c / 2
  local function to255(v) return math.floor((v + m) * 255 + 0.5) end
  return string.format('#%02x%02x%02x', to255(r), to255(g), to255(b))
end

-- Hue from a SHA-1 of the branch name (pandoc.utils.sha1 -- the base Lua
-- library ships no hashing, but pandoc's runtime does). SHA-1 avalanches, so
-- near-identical names like release/v1.0 and release/v2.0 land far apart.
local function color_for_branch(name)
  local digest = pandoc.utils.sha1(tostring(name))
  local hue = tonumber(digest:sub(1, 6), 16) % 360
  return hsl_to_hex(hue, COLOR_SAT, COLOR_LIGHT)
end

local function capture_meta(meta)
  META = meta
  return meta
end

local function escape(s)
  return (tostring(s or '')
    :gsub('&', '&amp;')
    :gsub('<', '&lt;')
    :gsub('>', '&gt;')
    :gsub('"', '&quot;'))
end

local function lane_x(lane)
  return X0 + lane * LANE_GAP
end

-- Vertical centre of a row. `i` is the 1-based row index used elsewhere; the
-- HTML content column starts its first row at TOP_PAD, hence the -1.
local function row_y(i)
  return TOP_PAD + (i - 1) * ROW_H + ROW_H / 2
end

-- "1.10.0" -> { 1, 10, 0 }, so 0.10.0 sorts above 0.9.0 numerically.
local function parse_version(v)
  local parts = {}
  for n in tostring(v):gmatch('%d+') do
    parts[#parts + 1] = tonumber(n)
  end
  return parts
end

-- Descending semver comparison (newest first).
local function version_gt(a, b)
  local pa, pb = a.parts, b.parts
  local n = math.max(#pa, #pb)
  for i = 1, n do
    local x, y = pa[i] or 0, pb[i] or 0
    if x ~= y then
      return x > y
    end
  end
  return false
end

local function fm_field(node, key)
  local fm = node.front_matter
  if fm and fm[key] then
    return stringify(fm[key])
  end
  return nil
end

-- Collect the changelog pages from the injected node list. Each becomes
--   { version = "1.1.0", href = "/changelogs/1.1.0", parts = {...}, branch = "..." }
local function collect_entries(meta, main_branch)
  local entries = {}
  if not meta.nodes then
    return entries
  end

  for _, node in ipairs(meta.nodes) do
    local path = node.path and stringify(node.path) or nil
    if path then
      local version = path:match('^changelogs/(.+)%.html$')
      -- Skip the index page and anything that isn't a versioned file.
      if version and version ~= 'index' and version:match('^%d') then
        entries[#entries + 1] = {
          version = version,
          href = '/' .. path:gsub('%.html$', ''),
          parts = parse_version(version),
          branch = fm_field(node, 'branch') or main_branch,
        }
      end
    end
  end

  table.sort(entries, version_gt)
  return entries
end

-- Read `milestones` front matter into a version -> { label } lookup.
local function collect_milestones(meta)
  local by_version = {}
  if not meta.milestones then
    return by_version
  end

  for _, m in ipairs(meta.milestones) do
    local version = m.version and stringify(m.version) or nil
    if version and version ~= '' then
      by_version[version] = {
        label = m.label and stringify(m.label) or version,
      }
    end
  end

  return by_version
end

-- Resolve the set of branches into ordered lanes. Lane 0 is always the main
-- branch. Explicit `branches` config (order / label / colour / parent) is
-- honoured; any branch seen in the entries but not configured is appended in
-- first-appearance order. Returns:
--   lanes      : array of { name, label, color, parent } indexed by lane
--   lane_of    : name -> lane index
local function resolve_lanes(meta, entries, main_branch)
  local lane_of = { [main_branch] = 0 }
  local lanes = { [0] = { name = main_branch, label = nil, color = nil, parent = nil } }

  local function ensure_lane(name)
    if lane_of[name] == nil then
      local idx = #lanes + 1
      lane_of[name] = idx
      lanes[idx] = { name = name, label = nil, color = nil, parent = nil }
    end
    return lane_of[name]
  end

  -- Configured branches first, so they control lane order.
  if meta.branches then
    for _, b in ipairs(meta.branches) do
      local name = b.name and stringify(b.name) or nil
      if name and name ~= main_branch then
        local idx = ensure_lane(name)
        lanes[idx].label = b.label and stringify(b.label) or nil
        lanes[idx].color = b.color and stringify(b.color) or nil
        lanes[idx].parent = b.from and stringify(b.from) or nil
      elseif name == main_branch then
        if b.label then lanes[0].label = stringify(b.label) end
        if b.color then lanes[0].color = stringify(b.color) end
      end
    end
  end

  -- Then any branch that shows up in the data but wasn't configured.
  for _, e in ipairs(entries) do
    ensure_lane(e.branch)
  end

  -- Fill in colour + parent defaults now that every lane exists.
  for idx = 0, #lanes do
    local lane = lanes[idx]
    if not lane.color then
      lane.color = color_for_branch(lane.name)
    end
    if idx > 0 then
      local parent_name = lane.parent
      lane.parent = (parent_name and lane_of[parent_name]) or 0
    end
  end

  return lanes, lane_of
end

-- Build the ordered list of rows (milestones interleaved above their version),
-- tagging the first (topmost = newest) row of each lane so we can show a chip.
local function build_rows(entries, milestones, lane_of)
  local rows = {}
  local seen_lane = {}

  for _, entry in ipairs(entries) do
    local lane = lane_of[entry.branch] or 0
    local milestone = milestones[entry.version]
    if milestone then
      rows[#rows + 1] = { kind = 'milestone', lane = lane, label = milestone.label }
    end
    local row = { kind = 'version', lane = lane, version = entry.version, href = entry.href }
    if not seen_lane[lane] then
      row.tip = true
      seen_lane[lane] = true
    end
    rows[#rows + 1] = row
  end

  return rows
end

-- Compute, per lane, the first (topmost) and last (bottom) row it touches.
local function lane_extents(rows)
  local first, last = {}, {}
  for i, row in ipairs(rows) do
    local l = row.lane
    if first[l] == nil then first[l] = i end
    last[l] = i
  end
  return first, last
end

local function svg_line(x, y1, y2, color)
  return string.format(
    '<line class="cl-line" x1="%d" y1="%.1f" x2="%d" y2="%.1f" stroke="%s" />',
    x, y1, x, y2, escape(color))
end

-- Fork connector: an S-curve from a branch's base (its oldest node) down into
-- the parent rail one row below.
local function svg_fork(bx, by, px, color)
  local mid = by + ROW_H * 0.5
  local endy = by + ROW_H
  return string.format(
    '<path class="cl-line" d="M %d %.1f C %d %.1f %d %.1f %d %.1f" stroke="%s" fill="none" />',
    bx, by, bx, mid, px, mid, px, endy, escape(color))
end

local function svg_version_dot(x, y, color)
  return string.format(
    '<circle class="cl-c-version" cx="%d" cy="%.1f" r="5" stroke="%s" />',
    x, y, escape(color))
end

local function svg_milestone_dot(x, y, color)
  return string.format(
    '<circle class="cl-c-halo" cx="%d" cy="%.1f" r="11" fill="%s" />'
      .. '<circle class="cl-c-milestone" cx="%d" cy="%.1f" r="6" fill="%s" />',
    x, y, escape(color), x, y, escape(color))
end

local function render_rails(rows, lanes)
  local first, last = lane_extents(rows)

  local lines, forks, dots = {}, {}, {}

  -- One vertical rail per lane, plus a fork into its parent.
  for idx = 0, #lanes do
    if first[idx] then
      local lane = lanes[idx]
      local x = lane_x(idx)
      if last[idx] > first[idx] then
        lines[#lines + 1] = svg_line(x, row_y(first[idx]), row_y(last[idx]), lane.color)
      end
      if idx > 0 then
        local px = lane_x(lane.parent or 0)
        forks[#forks + 1] = svg_fork(x, row_y(last[idx]), px, lane.color)
      end
    end
  end

  -- Node dots on top of the rails.
  for i, row in ipairs(rows) do
    local color = lanes[row.lane].color
    local x, y = lane_x(row.lane), row_y(i)
    if row.kind == 'milestone' then
      dots[#dots + 1] = svg_milestone_dot(x, y, color)
    else
      dots[#dots + 1] = svg_version_dot(x, y, color)
    end
  end

  local max_lane = 0
  for idx = 0, #lanes do
    if first[idx] and idx > max_lane then max_lane = idx end
  end

  local width = lane_x(max_lane) + X0
  local height = TOP_PAD * 2 + #rows * ROW_H

  return string.format(
    '<svg class="cl-rails" width="%d" height="%d" viewBox="0 0 %d %d" aria-hidden="true">%s%s%s</svg>',
    width, height, width, height,
    table.concat(lines), table.concat(forks), table.concat(dots))
end

local function render_row_content(row, lanes)
  if row.kind == 'milestone' then
    return string.format(
      '<li class="cl-row cl-row--milestone"><span class="cl-milestone">%s</span></li>',
      escape(row.label))
  end

  local tag = ''
  if row.tip and row.lane > 0 then
    local lane = lanes[row.lane]
    local label = lane.label or lane.name
    tag = string.format(
      ' <span class="cl-branch-tag" style="color:%s;border-color:%s">%s</span>',
      escape(lane.color), escape(lane.color), escape(label))
  end

  return string.format(
    '<li class="cl-row cl-row--version"><a class="cl-version" href="%s.html">%s</a>%s</li>',
    escape(row.href), escape(row.version), tag)
end

local function render_timeline()
  if not META then
    return ''
  end

  local main_branch = META.main_branch and stringify(META.main_branch) or 'main'

  local entries = collect_entries(META, main_branch)
  if #entries == 0 then
    return '<p class="text-muted">No changelogs yet.</p>'
  end

  local milestones = collect_milestones(META)
  local lanes, lane_of = resolve_lanes(META, entries, main_branch)
  local rows = build_rows(entries, milestones, lane_of)

  local content = {}
  for _, row in ipairs(rows) do
    content[#content + 1] = render_row_content(row, lanes)
  end

  return table.concat({
    string.format('<div class="cl-graph" style="--cl-row-h:%dpx;--cl-top-pad:%dpx">', ROW_H, TOP_PAD),
    render_rails(rows, lanes),
    '<ol class="cl-rows">',
    table.concat(content, '\n'),
    '</ol>',
    '</div>',
  }, '\n')
end

local function is_placeholder(text)
  return type(text) == 'string' and text:find('tiefchangelog')
end

local function handle_raw_block(el)
  if type(el.format) == 'string'
    and el.format:lower():match('html')
    and is_placeholder(el.text)
  then
    return pandoc.RawBlock('html', render_timeline())
  end
  return nil
end

local function handle_div(el)
  if el.identifier == 'tiefchangelog'
    or (el.classes and el.classes:includes('tiefchangelog'))
  then
    return pandoc.RawBlock('html', render_timeline())
  end
  return nil
end

return {
  { Meta = capture_meta },
  {
    RawBlock = handle_raw_block,
    Div = handle_div,
  },
}
