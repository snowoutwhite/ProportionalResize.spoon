--- === ProportionalResize ===
---
--- Keep a window's *relative* size and position when it moves to another display.
---
--- On a multi-monitor setup where the displays use different scaled (effective)
--- resolutions, macOS keeps a window's point size constant when you drag it across
--- screens. A window that fit a large/low-density display then overflows a smaller
--- one (or looks tiny going the other way).
---
--- This Spoon watches window moves and, when a window crosses to a different
--- screen, reprojects it so it keeps the same *fraction* of the destination
--- screen it had on the source screen. A window filling ~70% of the big display
--- ends up filling ~70% of the small one. It does not use full screen / Spaces,
--- so it stays compatible with Stage Manager.
---
--- Download: https://github.com/snowoutwhite/ProportionalResize.spoon

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ProportionalResize"
obj.version = "1.0.0"
obj.author = "snowoutwhite <snowoutwhite2005@gmail.com>"
obj.homepage = "https://github.com/snowoutwhite/ProportionalResize.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- ProportionalResize.animationDuration
--- Variable
--- Seconds the reposition animation takes. 0 = instant (most responsive),
--- larger = smoother glide. Default 0.12.
obj.animationDuration = 0.12

--- ProportionalResize.settleDelay
--- Variable
--- Seconds to wait after a window stops moving before reprojecting it. This avoids
--- yanking the window mid-drag. Default 0.22.
obj.settleDelay = 0.22

--- ProportionalResize.excludedApps
--- Variable
--- List of application names (as shown in the menu bar) to leave untouched,
--- e.g. { "iTerm2", "Terminal" }. Default {}.
obj.excludedApps = {}

-- ---- internal state ----------------------------------------------------------
obj._stableScreen = {}  -- winId -> id of the screen where it last settled
obj._stableRel    = {}  -- winId -> {x,y,w,h} fractions on that screen
obj._timers       = {}  -- winId -> debounce timer
obj._adjusting    = {}  -- winId -> true while we are programmatically moving it
obj._wf           = nil -- window filter

-- absolute frame -> fraction of its screen's usable frame
local function relFrame(f, s)
  return { x = (f.x - s.x) / s.w, y = (f.y - s.y) / s.h, w = f.w / s.w, h = f.h / s.h }
end

function obj:_isExcluded(win)
  local app = win:application()
  if not app then return false end
  local name = app:name()
  for _, n in ipairs(self.excludedApps) do
    if n == name then return true end
  end
  return false
end

-- called once a window has stopped moving; reproject if it changed screens
function obj:_settle(win)
  if not win then return end
  local id = win:id();      if not id then return end
  local scr = win:screen(); if not scr then return end
  local sid = scr:id()
  local s = scr:frame()  -- usable area (excludes menu bar / Dock)

  if self._stableScreen[id] and self._stableScreen[id] ~= sid and self._stableRel[id] then
    -- crossed screens: reproject the relative frame from the old screen
    local rel = self._stableRel[id]
    local rw = math.min(rel.w, 1.0)
    local rh = math.min(rel.h, 1.0)
    local w = rw * s.w
    local h = rh * s.h
    local x = s.x + math.max(0, math.min(rel.x, 1.0 - rw)) * s.w
    local y = s.y + math.max(0, math.min(rel.y, 1.0 - rh)) * s.h
    self._adjusting[id] = true
    win:setFrame({ x = x, y = y, w = w, h = h }, self.animationDuration)
    hs.timer.doAfter(self.settleDelay + self.animationDuration, function()
      self._adjusting[id] = nil
      local sc = win:screen()
      if sc then
        self._stableScreen[id] = sc:id()
        self._stableRel[id] = relFrame(win:frame(), sc:frame())
      end
    end)
  else
    -- same screen (or first sighting): remember current relative frame
    self._stableScreen[id] = sid
    self._stableRel[id] = relFrame(win:frame(), s)
  end
end

function obj:_onMoved(win)
  if not win or not win:isStandard() then return end
  if self:_isExcluded(win) then return end
  local id = win:id(); if not id then return end
  if self._adjusting[id] then return end
  if self._timers[id] then self._timers[id]:stop() end
  self._timers[id] = hs.timer.doAfter(self.settleDelay, function() self:_settle(win) end)
end

--- ProportionalResize:start()
--- Method
--- Start watching window moves and reprojecting on screen change.
---
--- Returns:
---  * The ProportionalResize object
function obj:start()
  if self._wf then self:stop() end
  self._wf = hs.window.filter.new(nil)  -- copy of the default filter
  local handler = function(win) self:_onMoved(win) end
  self._wf:subscribe(hs.window.filter.windowMoved,   handler)
  self._wf:subscribe(hs.window.filter.windowCreated, handler)
  self._wf:subscribe(hs.window.filter.windowFocused, handler)
  return self
end

--- ProportionalResize:stop()
--- Method
--- Stop watching window moves.
---
--- Returns:
---  * The ProportionalResize object
function obj:stop()
  if self._wf then
    self._wf:unsubscribeAll()
    self._wf = nil
  end
  for _, t in pairs(self._timers) do if t then t:stop() end end
  self._timers = {}
  return self
end

return obj
