local meta_workspaces = {
  Desktop = {
    key = "D",
  },
  Telecom = {
    key = "T",
    on_created_empty = x.telegram_client,
  },
  Music = {
    key = "M",
    on_created_empty = x.mpd_client,
  },
  Games = {
    key = "G",
    on_created_empty = x.steam,
  },
  Image = {
    key = "I",
    on_created_empty = x.photoeditor,
  },
  Alarms = {
    key = "F12",
    name = "Alarm",
    on_created_empty = x.clock,
  },
  Torrent = {
    key = "O",
    layout = "dwindle",
    on_created_empty = x.torrent_client .. " && " .. x.torrent_sources_folder,
  },
  System = {
    key = "Slash",
    name = "/",
    layout = "dwindle",
    on_created_empty = x.terminal .. " -e datamile server & " .. x.terminal .. " -e datamile interface dev",
  },
}

for _, meta in pairs(meta_workspaces) do
  if not meta.name then
    meta.name = meta.key
  end
end

local function switch_workspace(meta)
  local active_ws = hl.get_active_workspace()
  local target_ws = meta.name

  if active_ws and active_ws.name == target_ws then
    local windows = hl.get_workspace_windows("name:" .. target_ws)
    if windows and #windows > 0 then
      local leftmost = windows[1]
      for _, w in ipairs(windows) do
        if w.at.x < leftmost.at.x then
          leftmost = w
        end
      end
      hl.dispatch(hl.dsp.focus({ window = "address:" .. leftmost.address }))
    end
  else
    hl.dispatch(hl.dsp.focus({ workspace = "name:" .. target_ws }))
  end
end

local function move_to_workspace(meta)
  hl.dispatch(hl.dsp.window.move({ workspace = "name:" .. meta.name }))
end

for _, meta in pairs(meta_workspaces) do
  if meta.on_created_empty or meta.layout then
    hl.workspace_rule({
      workspace = "name:" .. meta.name,
      on_created_empty = meta.on_created_empty,
      layout = meta.layout,
    })
  end

  hl.bind("SUPER + " .. meta.key, function()
    switch_workspace(meta)
  end)

  hl.bind("SUPER + SHIFT + " .. meta.key, function()
    move_to_workspace(meta)
  end)
end
