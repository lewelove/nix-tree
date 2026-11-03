hl.bind("SUPER + period", function()
  local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
  if not ws then return end
  hl.workspace_rule({
    workspace = "name:" .. ws.name,
    layout = "dwindle"
  })
end)

hl.bind("SUPER + comma", function()
  local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
  if not ws then return end
  hl.workspace_rule({
    workspace = "name:" .. ws.name,
    layout = "scrolling"
  })
end)
