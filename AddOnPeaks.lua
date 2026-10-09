-- AddOnPeaks: přehled nejvyšších jednorázových zásahů addonů (C_AddOnProfiler).
-- /aop        -> ukáže okno s top 15, uloží celý přehled do AddOnPeaksDB
-- /aop hide   -> skryje okno
-- Při odhlášení se přehled uloží také do souboru (zápis do WTF až po odhlášení / reloadu).

local METRIC_AVG, METRIC_LAST, METRIC_PEAK, METRIC_OVER50 = 0, 3, 4, 8
local TOP_N = 15

local function CollectRows()
  local rows = {}
  if not C_AddOnProfiler or not C_AddOns then
    return rows
  end
  for i = 1, C_AddOns.GetNumAddOns() do
    local name = C_AddOns.GetAddOnInfo(i)
    if name then
      rows[#rows + 1] = {
        name = name,
        avg = C_AddOnProfiler.GetAddOnMetric(name, METRIC_AVG) or 0,
        last = C_AddOnProfiler.GetAddOnMetric(name, METRIC_LAST) or 0,
        peak = C_AddOnProfiler.GetAddOnMetric(name, METRIC_PEAK) or 0,
        over50 = C_AddOnProfiler.GetAddOnMetric(name, METRIC_OVER50) or 0,
      }
    end
  end
  table.sort(rows, function(a, b) return a.peak > b.peak end)
  return rows
end

-- Okno ----------------------------------------------------------------

local win = CreateFrame("Frame", "AddOnPeaksFrame", UIParent, "BackdropTemplate")
win:SetSize(460, 360)
win:SetPoint("CENTER")
win:SetFrameStrata("DIALOG")
win:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
})
win:SetBackdropColor(0, 0, 0, 0.9)
win:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
win:SetMovable(true)
win:EnableMouse(true)
win:RegisterForDrag("LeftButton")
win:SetScript("OnDragStart", win.StartMoving)
win:SetScript("OnDragStop", win.StopMovingOrSizing)
win:Hide()

win.title = win:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
win.title:SetPoint("TOPLEFT", 12, -10)
win.title:SetText("AddOnPeaks: top " .. TOP_N .. " (peak ms)")

local close = CreateFrame("Button", nil, win, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -2, -2)

-- Sloupce: pořadí, název, peak (ms), poslední (ms), počet nad 50 ms
local COL = {
  rank  = { x = 12,  w = 24,  justify = "RIGHT" },
  name  = { x = 42,  w = 200, justify = "LEFT" },
  peak  = { x = 246, w = 70,  justify = "RIGHT" },
  last  = { x = 322, w = 60,  justify = "RIGHT" },
  over  = { x = 388, w = 60,  justify = "RIGHT" },
}
local HEADERS = { rank = "#", name = "Addon", peak = "Peak ms", last = "Last ms", over = ">50ms" }
local ROW_H = 16
local HEADER_Y = -40

local function MakeCell(parent, font, col, y)
  local fs = parent:CreateFontString(nil, "OVERLAY", font)
  fs:SetPoint("TOPLEFT", col.x, y)
  fs:SetWidth(col.w)
  fs:SetJustifyH(col.justify)
  return fs
end

-- hlavička
for key, text in pairs(HEADERS) do
  local fs = MakeCell(win, "GameFontNormalSmall", COL[key], HEADER_Y)
  fs:SetText(text)
  fs:SetTextColor(0.7, 0.7, 0.7)
end
local divider = win:CreateTexture(nil, "ARTWORK")
divider:SetColorTexture(0.4, 0.4, 0.4, 1)
divider:SetPoint("TOPLEFT", 12, HEADER_Y - 16)
divider:SetSize(436, 1)

-- řádky (vytvoří se jednou, potom se jen přepisují)
local rowCells = {}
for i = 1, TOP_N do
  local y = HEADER_Y - 22 - (i - 1) * ROW_H
  rowCells[i] = {
    rank = MakeCell(win, "GameFontHighlightSmall", COL.rank, y),
    name = MakeCell(win, "GameFontHighlightSmall", COL.name, y),
    peak = MakeCell(win, "GameFontHighlightSmall", COL.peak, y),
    last = MakeCell(win, "GameFontHighlightSmall", COL.last, y),
    over = MakeCell(win, "GameFontHighlightSmall", COL.over, y),
  }
end

-- barva podle závažnosti peaku
local function PeakColor(ms)
  if ms >= 100 then return 1, 0.3, 0.3 end   -- červená
  if ms >= 20 then return 1, 0.82, 0 end     -- žlutá
  return 0.6, 1, 0.6                         -- zelená
end

local function ShowRows(rows, stamp)
  win.title:SetText("AddOnPeaks " .. (stamp or ""))
  for i = 1, TOP_N do
    local cells = rowCells[i]
    local r = rows[i]
    if r then
      cells.rank:SetText(i)
      cells.name:SetText(r.name)
      cells.peak:SetText(string.format("%.1f", r.peak))
      cells.peak:SetTextColor(PeakColor(r.peak))
      cells.last:SetText(string.format("%.1f", r.last))
      cells.over:SetText(r.over50)
      cells.rank:Show(); cells.name:Show(); cells.peak:Show(); cells.last:Show(); cells.over:Show()
    else
      cells.rank:Hide(); cells.name:Hide(); cells.peak:Hide(); cells.last:Hide(); cells.over:Hide()
    end
  end
  win:Show()
end

-- Příkaz --------------------------------------------------------------

SLASH_ADDONPEAKS1 = "/aop"
SlashCmdList["ADDONPEAKS"] = function(msg)
  if msg and msg:lower():match("^%s*hide") then
    win:Hide()
    return
  end
  local rows = CollectRows()
  local stamp = date("%H:%M:%S")
  AddOnPeaksDB = { time = date("%Y-%m-%d %H:%M:%S"), rows = rows }
  ShowRows(rows, stamp)
end

-- Uložení při odhlášení -----------------------------------------------

local saver = CreateFrame("Frame")
saver:RegisterEvent("PLAYER_LOGOUT")
saver:SetScript("OnEvent", function()
  AddOnPeaksDB = { time = date("%Y-%m-%d %H:%M:%S"), rows = CollectRows() }
end)
