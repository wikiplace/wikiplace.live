-- Draw the Wikiplace logo from scratch: an open book whose pages are a world map.
-- Run from brand/:
--   aseprite -b --script-param map=source/map-128.png --script-param out=wikiplace.aseprite --script source/book.lua
--
-- Everything but the map is drawn as exact, left/right-symmetric shapes on a
-- 128x128 grid. The map (ocean and continents) is copied pixel for pixel from
-- the regridded source. Each part lands on its own Aseprite layer:
-- background, cover, pages, flag, ribbon.

local S = 128
local MID = 63 -- last column of the left half; everything mirrors across MID + 0.5
local pc = app.pixelColor
local function rgb(h) return pc.rgba(h >> 16 & 255, h >> 8 & 255, h & 255, 255) end

local BG      = rgb(0x17131a)
local OCEAN   = rgb(0x0030a8)
local LAND    = rgb(0x70e038)
local MOUND   = rgb(0x28a800)
local PAGE    = rgb(0xf8e8c0) -- cream
local EDGE    = rgb(0xe8c078) -- page-edge tan
local LINE    = rgb(0xb87840) -- page lines, spine fold
local COVER   = rgb(0x904030)
local OUTLINE = rgb(0x702820)
local BOARD   = rgb(0xa07850) -- cork board inside the leather turn-in
local GOLD    = rgb(0xe0a000)
local SHINE   = rgb(0xf8e040)
local RED     = rgb(0xf83030)

-- Layout of the flat book (left half; mirrored to the right).
local MAP_L, MAP_T, MAP_B = 19, 28, 84
local PAGE_L, PAGE_T, STACK_B = 16, 24, 92
local COVER_L, COVER_T, COVER_B = 10, 26, 99
local TURN_IN = 2 -- leather margin folded over the board edge

-- The open book can't lie flat. Paper bows up a lot; the leather-over-card
-- cover only a little.
local PAPER_ARCH, COVER_ARCH = 6, 2

-- Each page (and cover half) bows up from its outer edge, peaks about two-thirds
-- of the way in, and curls back down into the gutter. Run lengths grow toward
-- the peak and shrink toward the spine, which keeps the pixel steps clean.
local function lift(x, arch)
  x = math.min(x, S - 1 - x)
  if x < PAGE_L then return 0 end
  local t = (x - PAGE_L) / (MID - PAGE_L)
  local l = t <= 0.7 and arch * (1 - ((t - 0.7) / 0.7) ^ 2)
                      or arch * (1 - 0.7 * ((t - 0.7) / 0.3) ^ 2)
  return math.floor(l + 0.5)
end

-- Drawing helpers on a target image; sym mirrors across the centre line.
local function sym(img, x, y, c)
  img:drawPixel(x, y, c)
  img:drawPixel(S - 1 - x, y, c)
end
local function rect(img, x0, y0, x1, y1, c)
  for y = y0, y1 do for x = x0, x1 do sym(img, x, y, c) end end
end
local function blank() local i = Image(S, S, ColorMode.RGB); i:clear(pc.rgba(0, 0, 0, 0)); return i end

-- Shift every column up by lift(x, arch).
local function arch(img, amount)
  local out = blank()
  for x = 0, S - 1 do
    local l = lift(x, amount)
    for y = 0, S - 1 - l do out:drawPixel(x, y, img:getPixel(x, y + l)) end
  end
  return out
end

-- Cover: one board behind the pages, outlined. The leather turns in over the
-- board's edges for TURN_IN px; inside that margin the bare board shows.
-- Gold corner brackets: 7x7 L shapes, 3px thick, shine on the outer edge.
local cover = blank()
rect(cover, COVER_L, COVER_T, MID, COVER_B, OUTLINE)
rect(cover, COVER_L + 1, COVER_T + 1, MID, COVER_B - 1, COVER)
rect(cover, COVER_L + 1 + TURN_IN, COVER_T + 1 + TURN_IN, MID, COVER_B - 1 - TURN_IN, BOARD)
local function bracket(x0, y0, flip)
  for dy = 0, 6 do
    for dx = 0, 6 do
      local ry = flip and (6 - dy) or dy
      if dx < 3 or ry < 3 then
        sym(cover, x0 + dx, y0 + dy, (dx == 0 or ry == 0) and SHINE or GOLD)
      end
    end
  end
end
bracket(COVER_L - 2, COVER_T - 1, false)
bracket(COVER_L - 2, COVER_B - 6, true)
cover = arch(cover, COVER_ARCH)

-- Pages: cream sheet, page stack with two page lines, a dark edge underneath,
-- the map, and the spine fold.
local pages = blank()
rect(pages, PAGE_L, PAGE_T, MID, MAP_B + 2, PAGE)
rect(pages, PAGE_L, MAP_B + 3, MID, STACK_B, EDGE)
for x = PAGE_L + 1, MID - 2 do
  sym(pages, x, MAP_B + 4, LINE)
  sym(pages, x, MAP_B + 7, LINE)
end
rect(pages, PAGE_L, STACK_B + 1, MID, STACK_B + 1, OUTLINE)

-- Map: map-coloured pixels from the source, ocean everywhere else. The source's
-- own flag is erased (land if land is within 2px, else ocean); the flag layer
-- redraws it cleanly.
local MAP_COLOURS = {}
for _, h in ipairs({ 0x0030a8, 0x70e038, 0x40f8f0, 0xf89028, 0xf868a0, 0xf8d800, 0xb070f8 }) do
  MAP_COLOURS[rgb(h)] = true
end
local FLAG_BOX = { x0 = 30, y0 = 31, x1 = 43, y1 = 48 }
local src = app.open(app.params["map"]).cels[1].image
local function near_land(x, y)
  for dy = -2, 2 do for dx = -2, 2 do
    if src:getPixel(x + dx, y + dy) == LAND then return true end
  end end
  return false
end
for y = MAP_T, MAP_B do
  for x = MAP_L, S - 1 - MAP_L do
    local v = src:getPixel(x, y)
    local in_flag = x >= FLAG_BOX.x0 and x <= FLAG_BOX.x1 and y >= FLAG_BOX.y0 and y <= FLAG_BOX.y1
    if not MAP_COLOURS[v] then v = (in_flag and near_land(x, y)) and LAND or OCEAN end
    pages:drawPixel(x, y, v)
  end
end
for y = PAGE_T, STACK_B do sym(pages, MID, y, LINE) end
pages = arch(pages, PAPER_ARCH)

-- Flag on North America, placed after the arch as one piece so it stays upright:
-- a mound, a 1px pole with a gold finial, and an outlined red banner.
local flag = blank()
local FLAG_X, FLAG_BASE = 33, 46 -- pole column and mound row on the flat page
do
  local px, py = FLAG_X, FLAG_BASE - lift(FLAG_X, PAPER_ARCH)
  for x = px - 1, px + 1 do flag:drawPixel(x, py, MOUND) end
  for x = px - 2, px + 2 do flag:drawPixel(x, py + 1, MOUND) end
  for y = py - 13, py - 1 do flag:drawPixel(px, y, BG) end
  flag:drawPixel(px, py - 14, SHINE)
  for y = py - 13, py - 7 do
    for x = px + 1, px + 9 do
      local edge = y == py - 13 or y == py - 7 or x == px + 9
      flag:drawPixel(x, y, edge and BG or RED)
    end
  end
end

-- Bookmark ribbon: hangs straight from under the pages. 8px wide, V-notched tail
-- (3 rows deep, widest at the tip).
local ribbon = blank()
local RIB_L, RIB_T, RIB_B = MID - 3, STACK_B - 1 - lift(MID - 3, PAPER_ARCH), COVER_B + 9
rect(ribbon, RIB_L, RIB_T, MID, RIB_B, RED)
local CLEAR = pc.rgba(0, 0, 0, 0)
sym(ribbon, MID, RIB_B - 2, CLEAR)
rect(ribbon, MID - 1, RIB_B - 1, MID, RIB_B - 1, CLEAR)
rect(ribbon, MID - 2, RIB_B, MID, RIB_B, CLEAR)

-- Assemble the layers, bottom to top.
local sprite = Sprite(S, S, ColorMode.RGB)
local background = Image(S, S, ColorMode.RGB)
background:clear(BG)
sprite.layers[1].name = "background"
sprite.cels[1].image = background
for _, part in ipairs({ { "cover", cover }, { "pages", pages }, { "flag", flag }, { "ribbon", ribbon } }) do
  local layer = sprite:newLayer()
  layer.name = part[1]
  sprite:newCel(layer, 1, part[2], Point(0, 0))
end
sprite:saveAs(app.params["out"])
