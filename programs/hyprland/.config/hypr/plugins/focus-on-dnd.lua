-- Focus viewport on the window under a held LMB

-- local TICK_MS = 300
local TICK_MS = 1000
local SCROLLING_LAYOUT = "scrolling"

local function active_workspaces()
  local ids = {}

  for _, monitor in ipairs(hl.get_monitors()) do
    for _, workspace in ipairs({ monitor.active_workspace, monitor.active_special_workspace }) do
      if workspace then
        ids[workspace.id] = true
      end
    end
  end

  return ids
end

local function visible(window, ids)
  if window.pinned then
    return true
  end

  return window.workspace ~= nil and ids[window.workspace.id] == true
end

local function contains(window, pos)
  local at, size = window.at, window.size
  return pos.x >= at.x and pos.x < at.x + size.x and pos.y >= at.y and pos.y < at.y + size.y
end

local function window_at(pos, ids)
  local windows = hl.get_windows()

  for i = #windows, 1, -1 do
    local window = windows[i]
    local hit = visible(window, ids) and window.accepts_input and not window.hidden and contains(window, pos)

    if hit then
      return window
    end
  end
end

local function bring_into_view(window)
  if window.floating then return end
  if not window.workspace or window.workspace.tiled_layout ~= SCROLLING_LAYOUT then return end

  hl.dispatch(hl.dsp.layout("fit_into_view"))
end

local function tick()
  local pos = hl.get_cursor_pos()
  if not pos then return end

  local target = window_at(pos, active_workspaces())
  if not target then return end

  local active = hl.get_active_window()
  if not active or active.address ~= target.address then return end

  bring_into_view(target)
end

local timer = hl.timer(tick, { timeout = TICK_MS, type = "repeat" })
timer:set_enabled(false)

hl.bind (
  "mouse:272",
  function() timer:set_enabled(true) end,
  { non_consuming = true } )

hl.bind (
  "mouse:272",
  function() timer:set_enabled(false) end,
  { non_consuming = true, release = true, ignore_mods = true } )
