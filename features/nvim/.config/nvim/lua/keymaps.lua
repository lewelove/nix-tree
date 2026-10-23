local map = vim.keymap.set
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Leader Keys
vim.keymap.set('n', '<leader>w', ':w!<CR>')
vim.keymap.set('n', '<leader>q', ':q!<CR>')
vim.keymap.set('n', '<leader>l', ':Lazy<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR> ')

vim.keymap.set('n', '<C-q>', ':qa!<CR>')

-- No clipboard override
map("n", "x", '"_x')
-- map({"n", "v"}, "d", '"_d')
-- map("n", "dd", '"_dd')
map("v", "p", '"_dP')

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Easy window navigation
vim.keymap.set('n', '<C-Left>', '<C-w>h', { desc = "Go to left window" })
vim.keymap.set('n', '<C-Right>', '<C-w>l', { desc = "Go to right window" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better navigation
vim.keymap.set({ 'n', 'v' }, 'j', 'gj', { silent = true })
vim.keymap.set({ 'n', 'v' }, 'k', 'gk', { silent = true })
vim.keymap.set({ 'n', 'v' }, '0', 'g0', { silent = true })
vim.keymap.set({ "n", "v" }, "<Down>", "gj", { silent = true })
vim.keymap.set({ "n", "v" }, "<Up>", "gk", { silent = true })
vim.keymap.set("i", "<Down>", "<C-o>gj", { silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", { silent = true })

-- Quick Save Raw Idea
vim.keymap.set("n", "<leader>s", function() require("scripts.QuickSaveNote").quick_save() end, { desc = "Quick Save Raw Note", silent = true })

-- Replace whole file with clipboard paste
vim.keymap.set('n', '<leader>v', 'ggVG"_dP | :w<CR>', { desc = 'Paste clipboard to whole buffer' })

-- Copy entire buffer
vim.keymap.set('n', '<leader>y', 'ggVG"+y', { desc = 'Yank whole buffer to clipboard' })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- DIFF NAVIGATION & MERGING
-- =============================================================
-- Smart Diff Merge (Leader m)
-- If in DIFF_REVIEW -> Push to original (diffput)
-- If in Original    -> Pull from review (diffget)
vim.keymap.set({ "n", "v" }, "<leader>b", function()
  if vim.fn.bufname("%") == "DIFF_REVIEW" then
    vim.cmd("diffput")
  else
    vim.cmd("diffget")
  end
end, { desc = "Smart Diff Put/Get" })
-- =============================================================

-- DIFF MERGE TOOL (Internal V-Split)
-- =============================================================
vim.keymap.set("n", "<leader>d", function()
  local ft = vim.bo.filetype
  local clipboard = vim.fn.getreg('+')
  if clipboard == "" then
    vim.notify("Clipboard is empty!", vim.log.levels.WARN)
    return
  end

  vim.cmd("diffthis")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(clipboard, "\n"))
  
  vim.bo[buf].filetype = ft
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_name(buf, "DIFF_REVIEW")

  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  
  vim.cmd("diffthis")

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      vim.cmd("diffoff!")
    end,
  })
  
end, { desc = "Diff Merge Tool (Internal)" })
-- =============================================================

-- Reload Configuration
vim.keymap.set("n", "<leader>rl", function()
  local config_dir = vim.fn.stdpath("config") .. "/lua/"

  dofile(config_dir .. "options.lua")
  dofile(config_dir .. "autocmds.lua")
  dofile(config_dir .. "keymaps.lua")
  dofile(config_dir .. "keymaps-plugins.lua")

  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Config" })

-- Smart Yank in Quotes
vim.keymap.set("n", "<leader>'", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local sq_odd, dq_odd = false, false
  for i = 1, col do
    local c = line:sub(i, i)
    if c == "'" then sq_odd = not sq_odd end
    if c == '"' then dq_odd = not dq_odd end
  end
  if dq_odd then
    vim.cmd('normal! yi"')
  elseif sq_odd then
    vim.cmd("normal! yi'")
  else
    local next_sq = line:find("'", col)
    local next_dq = line:find('"', col)
    if next_sq and next_dq then
      if next_sq < next_dq then vim.cmd("normal! yi'") else vim.cmd('normal! yi"') end
    elseif next_sq then
      vim.cmd("normal! yi'")
    else
      vim.cmd('normal! yi"')
    end
  end
end, { desc = "Smart yank inside quotes" })
