-- Layouts

hl.config ({
  general = {
    layout = "scrolling"
  },
  scrolling = {
    -- fullscreen_on_one_column = true,
    fullscreen_on_one_column = false,
    column_width = 0.7,
    focus_fit_method = 0,
  }
})

-- Decor

hl.config ({
  general = {
    gaps_in = 0,
    gaps_out = { top = 12, bottom = 8, left = 12, right = 12 },
    -- gaps_out = 8,
    border_size = 0,
    resize_on_border = false,
    allow_tearing = false,
  },

  decoration = {
    rounding = 0,
    -- rounding_power = 0,
    shadow = {
      enabled = true,
      range = 8,
      render_power = 4,
      color = "rgba(00000060)",
      color_inactive = "rgba(00000000)",
    },
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },
})

-- Animations

hl.curve ( "steep", {
  type = "bezier",
  points = { {0, 1}, {0, 1} }
})

hl.curve ( "ease_out_quint", {
  type = "bezier",
  points = { {0.23, 1}, {0.32, 1} }
})

hl.curve ( "ease_in_out_cubic", {
  type = "bezier",
  points = { {0.65, 0.05}, {0.36, 1} }
})

hl.curve ( "almost_linear", {
  type = "bezier",
  points = { {0.5, 0.5}, {0.75, 1} }
})

hl.animation ({
  leaf = "workspaces",
  enabled = false,
})

hl.animation ({
  leaf = "specialWorkspace",
  enabled = false,
})

hl.animation ({
  leaf = "windows",
  enabled = true,
  speed = 4,
  bezier = "ease_out_quint",
  style = "slide",
})

hl.animation ({
  leaf = "windowsIn",
  enabled = true,
  speed = 4,
  bezier = "ease_out_quint",
})

hl.animation ({
  leaf = "windowsOut",
  enabled = true,
  speed = 4,
  bezier = "ease_out_quint",
})

hl.animation ({
  leaf = "fade",
  enabled = true,
  -- enabled = false,
  speed = 0.5,
  bezier = "almost_linear",
})

hl.animation ({
  leaf = "layers",
  -- enabled = true,
  enabled = false,
  speed = 1,
  bezier = "ease_out_quint",
})

hl.animation ({
  leaf = "layersIn",
  enabled = true,
  speed = 0.2,
  bezier = "steep",
  style = "fade",
})

hl.animation ({
  leaf = "layersOut",
  enabled = true,
  speed = 0.2,
  bezier = "steep",
  style = "fade",
})

-- hl.animation ({
--   leaf = "fadeLayersIn",
--   -- enabled = true,
--   enabled = false,
--   speed = 0.2,
--   bezier = "steep",
-- })
--
-- hl.animation ({
--   leaf = "fadeLayersOut",
--   -- enabled = true,
--   enabled = false,
--   speed = 0.2,
--   bezier = "steep",
-- })
