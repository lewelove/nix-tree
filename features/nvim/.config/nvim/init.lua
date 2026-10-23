require("options")

require("keymaps")
require("keymaps-plugins")
require("clipboard")

require("lazy-init")

require("autocmds")

local album_script = require("scripts.albumscript")

vim.api.nvim_create_user_command('AlbumScript', function()
  album_script.process_metadata()
  vim.notify("AlbumScript: Processed and saved.", vim.log.levels.INFO)
end, { desc = "Run album metadata cleanup" })

local vapor_script = require("scripts.vapormemory")

vim.api.nvim_create_user_command('VaporMemory', function()
  local success = vapor_script.process_vapor_metadata()
  if success then
    vim.notify("VaporMemory: Processed and saved.", vim.log.levels.INFO)
  else
    vim.notify("VaporMemory: Skipped (Not Vaporwave).", vim.log.levels.WARN)
  end
end, { desc = "Run specialized Vapor Memory cleanup" })

local quicksave_script = require("scripts.QuickSaveNote")

vim.api.nvim_create_user_command('QuickSaveNote', function()
  quicksave_script.quick_save()
  vim.notify("QuickSaveNote: Processed and saved.", vim.log.levels.INFO)
end, { desc = "Run quicksave note process" })

local teletime_script = require("scripts.telegram_time_to_iso")

vim.api.nvim_create_user_command('TeleTime', function(opts)
  teletime_script.process_range(opts)
end, { range = true, desc = "Convert Telegram timestamps (M/D/YY at HH:MM:SS) to UTC Zulu ISO (-3h)" })
