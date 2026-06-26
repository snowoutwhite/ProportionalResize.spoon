--- === ProportionalResize ===
---
--- Keep a window's *relative* size and position when it moves to another display.
---
--- On a multi-monitor setup where the displays use different scaled (effective)
--- resolutions, macOS keeps a window's point size constant when you drag it across
--- screens. A window that fit a large/low-density display then overflows a smaller
--- one (or looks tiny going the other way).
---
--- This Spoon reprojects a window the moment you drop it on a *different* screen,
--- so it keeps the same *fraction* of the destination screen it had on the source
--- screen. A window filling ~70% of the big display ends up filling ~70% of the
--- small one. It does not use full screen / Spaces, so it stays compatible with
--- Stage Manager.
---
--- v1.1 triggers on mouse-up (hs.eventtap) instead of watching windowMoved: it
--- does *zero* work while you drag (smooth) and reprojects instantly on release
--- (no delay).
---
--- Download: https://github.com/snowoutwhite/ProportionalResize.spoon

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ProportionalResize"
obj.version = "1.1.0"
obj.author = "snowoutwhite <snowoutwhite2005@gmail.com>"
obj.homepage = "https://github.com/snowoutwhite/ProportionalResize.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- ProportionalResize.animationDuration
--- Variable
--- Seconds the resize animation takes. 0 = instant (snappiest); a small value
--- like 0.1 gives a smooth glide. Default 0.
obj.animationDuration = 0.0

--- ProportionalResize.excludedApps
--- Variable
--- List of application names (as shown in the menu bar) to leave untouched,
--- e.g. { "iTerm2", "Terminal" }. Default {}.
obj.excludedApps = {}

-- ---- internal state ----------------------------------------------------------
obj._tap  = nil  -- the mouse eventtap
obj._drag = nil  -- info captured at mouse-down: { id, screenId, rel }

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

-- topmost standard window whose frame contains a point
local function windowUnderPoint(p)
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() then
      local f = w:frame()
      if p.x >= f.x and p.x <= f.x + f.w and p.y >= f.y and p.y <= f.y + f.h then
        return w
      end
    end
  end
  return nil
end

-- mouse-down: cheaply remember the grabbed window, its screen and relative frame
function obj:_onDown()
  self._drag = nil
  local w = windowUnderPoint(hs.mouse.absolutePosition())
  if not w or self:_isExcluded(w) then return end
  local scr = w:screen(); if not scr then return end
  self._drag = { id = w:id(), screenId = scr:id(), rel = relFrame(w:frame(), scr:frame()) }
end

-- mouse-up: if the window ended on a different screen, reproject it immediately
function obj:_onUp()
  local d = self._drag; self._drag = nil
  if not d then return end

  local w = hs.window.focusedWindow()
  if not w or w:id() ~= d.id then w = hs.window.get(d.id) end
  if not w then return end

  local cur = w:screen(); if not cur then return end
  if cur:id() == d.screenId then return end  -- never crossed screens

  local s  = cur:frame()
  local rw = math.min(d.rel.w, 1.0)
  local rh = math.min(d.rel.h, 1.0)
  local x  = s.x + math.max(0, math.min(d.rel.x, 1.0 - rw)) * s.w
  local y  = s.y + math.max(0, math.min(d.rel.y, 1.0 - rh)) * s.h
  w:setFrame({ x = x, y = y, w = rw * s.w, h = rh * s.h }, self.animationDuration)
end

--- ProportionalResize:start()
--- Method
--- Start reprojecting windows on cross-screen drops.
---
--- Returns:
---  * The ProportionalResize object
function obj:start()
  if self._tap then self:stop() end
  local types = hs.eventtap.event.types
  self._tap = hs.eventtap.new({ types.leftMouseDown, types.leftMouseUp }, function(e)
    local t = e:getType()
    if t == types.leftMouseDown then
      self:_onDown()
    elseif t == types.leftMouseUp then
      self:_onUp()
    end
    return false  -- never swallow the event
  end)
  self._tap:start()
  return self
end

--- ProportionalResize:stop()
--- Method
--- Stop reprojecting.
---
--- Returns:
---  * The ProportionalResize object
function obj:stop()
  if self._tap then self._tap:stop(); self._tap = nil end
  self._drag = nil
  return self
end

return obj
