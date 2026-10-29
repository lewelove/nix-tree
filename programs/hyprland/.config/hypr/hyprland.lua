-- lewelove hyprland config --

_G.x = require("presets")

hl.on("hyprland.start", function () 
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS")
  hl.exec_cmd("systemctl --user start hyprland-session.target")
  hl.exec_cmd("systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal")
  hl.dispatch(hl.dsp.focus({ workspace = "name:D" }))
end)

require("visuals")
require("window_rules")
require("workspace_rules")

require("keybinds")

require("plugins.meta-workspaces")
require("plugins.dynamic-layout")
require("plugins.focus-on-dnd")

-- IO

hl.config ({

  input = {
    kb_layout = "us",
    sensitivity = -0.5,
    repeat_rate = 35,
    repeat_delay = 200,
    focus_on_close = 2,
  },

  cursor = {
    no_hardware_cursors = false,
    inactive_timeout = 3,
  },

  binds = {
    movefocus_cycles_fullscreen = true,
  },

})
