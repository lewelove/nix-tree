-- hl.window_rule ({
--   name = "",
--   match = { class = "" },
--   float = true,
--   center = true,
--   size = { "monitor_w * 0.5",  "monitor_h * 0.75" },
-- })

hl.window_rule ({
  name = "nvim",
  match = { class = "nvim" },
  float = true,
  center = true,
  size = { "monitor_w * 0.5",  "monitor_h * 0.9" },
})

hl.window_rule ({
  name = "portal",
  match = { class = "xdg-desktop-portal-gtk" },
  tile = true,
  size = { "monitor_w * 0.5",  "monitor_h * 0.75" },
})

hl.window_rule ({
  name = "MPV",
  match = { class = "mpv" },
  fullscreen = true,
})

-- hl.window_rule ({
--   name = "thunar",
--   match = { class = "^(thunar|Thunar)$" },
--   float = true,
--   center = true,
--   size = { "monitor_w * 0.5",  "monitor_h * 0.75" },
-- })

hl.window_rule ({
  name = "steam",
  match = { class = "steam" },
  workspace = "name:G",
})

hl.window_rule ({
  name = "steam_games",
  match = { initial_class = "^steam_app_.*$" },
  workspace = "name:G",
  fullscreen = true
})

-- hl.window_rule ({
--   name = "btop",
--   match = { class = "btop" },
--   float = true,
--   center = true,
--   size = { "monitor_w * 0.75",  "monitor_h * 0.9" },
-- })

hl.window_rule ({
  name = "calculator",
  match = { class = "org.gnome.Calculator" },
  float = true,
  pin = true,
  size = { 360, 540 },
  move = { 1500, 110 },
})

hl.window_rule ({
  name = "WEV",
  match = { class = "wev" },
  float = true,
  pin = true,
  stay_focused = true,
  size = { 320, 320 },
  move = { 1500, 100 },
})

hl.window_rule ({
  name = "No blur for popup windows",
  match = { class = "^$", title = "^$" },
  no_blur = true,
})

hl.window_rule ({
  name = "Chromium windows always tile",
  match = { class = "(?i)chromium-browser" },
  tile = true,
})

hl.window_rule ({
  name = "Chromium DevToolsApp",
  match = { class = "(?i)chromium-browser", initial_title = "(?i)DevToolsApp" },
  float = true,
  center = true,
  size = { "monitor_w * 0.5",  "monitor_h * 0.6" },
})

