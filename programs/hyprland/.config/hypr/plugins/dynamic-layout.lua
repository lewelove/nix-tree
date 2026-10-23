local last_workspace = hl.get_active_workspace()

-- hl.on("workspace.active", function(ws)
--   if not ws then return end
--   if last_workspace and last_workspace.name ~= ws.name then
--     local windows = hl.get_workspace_windows("name:" .. last_workspace.name)
--     if not windows or #windows == 0 then
--       hl.workspace_rule({
--         workspace = "name:" .. last_workspace.name,
--         layout = "scrolling"
--       })
--     end
--   end
--   last_workspace = ws
-- end)

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
