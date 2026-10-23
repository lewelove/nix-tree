-- Safe Kill

return function()
  local active = hl.get_active_window()
  if not active then return end
  local initial_class = active.initialClass or active.initial_class or ""
  if string.match(initial_class, "^steam_app_") then
    return
  end
  hl.dispatch(hl.dsp.window.close())
end
