-- Lazy

-- Telescope
vim.keymap.set("n", "<C-f>", function()
  require("telescope.builtin").find_files()
end, { desc = "Telescope Find Files" })

vim.keymap.set("n", "<C-g>", function()
  require("telescope.builtin").live_grep()
end, { desc = "Telescope Live Grep" })

-- Neo-Tree
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>')

-- Oil
vim.keymap.set("n", "<leader>o", function()
  require("oil").open()
  vim.schedule(function()
    if vim.bo.filetype == "oil" then
      vim.cmd.edit()
    end
  end)
end, { desc = "Open oil and force refresh" })

