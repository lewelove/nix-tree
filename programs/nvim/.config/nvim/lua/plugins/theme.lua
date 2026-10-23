return {
  'rebelot/kanagawa.nvim',
  -- Set priority to ensure it loads before other plugins that rely on colors
  priority = 1000, 
  -- Set lazy = false to load it immediately on startup
  lazy = false, 
  config = function()
    -- 1. Setup/Configure Kanagawa (Optional)
    require('kanagawa').setup({
      -- Customize your preferred variant (wave, dragon, or lotus)
      theme = 'wave', 
      
      -- Common Customizations:
      transparent = true, -- Set to true for a transparent background
      background = {
        dark = 'dragon',   -- Use 'dragon' variant for dark mode
        light = 'lotus',   -- Use 'lotus' variant for light mode
      },
      
      -- Overrides are for customizing specific highlight groups
      overrides = function(colors) 
        local theme = colors.theme
        return {
          -- Line numbers and sign column
          LineNr = { fg = theme.ui.fg_dim, bg = 'none' },
          SignColumn = { bg = 'none' },

          -- General Floating Windows (LSP hover docs, Dressing, etc.)
          NormalFloat = { bg = 'none' },
          FloatBorder = { fg = theme.ui.border, bg = 'none' },
          FloatTitle = { fg = theme.ui.fg, bold = true, bg = 'none' },

          -- Telescope Main window
          TelescopeNormal = { bg = 'none' },
          TelescopeBorder = { fg = theme.ui.border, bg = 'none' },
          
          -- Telescope Prompt (Input bar)
          TelescopePromptNormal = { bg = 'none' },
          TelescopePromptBorder = { fg = theme.ui.border, bg = 'none' },
          TelescopePromptTitle = { fg = theme.ui.special, bold = true, bg = 'none' },
          
          -- Telescope Results
          TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = 'none' },
          TelescopeResultsBorder = { fg = theme.ui.border, bg = 'none' },
          TelescopeResultsTitle = { fg = theme.ui.fg, bg = 'none' },
          
          -- Telescope Preview
          TelescopePreviewNormal = { bg = 'none' },
          TelescopePreviewBorder = { fg = theme.ui.border, bg = 'none' },
          TelescopePreviewTitle = { fg = theme.ui.fg, bg = 'none' },
        }
      end,
      -- ... other configuration options ...
    })

    -- 2. Load the colorscheme
    -- This command must be run after the plugin is set up.
    vim.cmd("colorscheme kanagawa")
  end
}
