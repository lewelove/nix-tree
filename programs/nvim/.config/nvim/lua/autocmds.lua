-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Enable spellcheck for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("SpellCheck", { clear = true }),
  pattern = { "markdown", "text", "xml", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = "#EA4335" })
vim.api.nvim_set_hl(0, "SpellRare", { underline = false, undercurl = false })
vim.api.nvim_set_hl(0, "SpellLocal", { underline = false, undercurl = false })
vim.api.nvim_set_hl(0, "SpellCap", { underline = false, undercurl = false })

-- Create new empty buffer in the same directory as current file
_G.NewBufferSameDir = function()
  if vim.bo.buftype ~= "" then return end

  local current_buf_path = vim.api.nvim_buf_get_name(0)
  local target_dir

  if current_buf_path ~= "" then
    target_dir = vim.fn.fnamemodify(current_buf_path, ":p:h")
  else
    target_dir = vim.fn.expand("~/Notes")
  end

  vim.cmd("enew")

  if vim.fn.isdirectory(target_dir) == 1 then
    vim.cmd("lcd " .. vim.fn.fnameescape(target_dir))
  end
end

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function(event)
    if event.match:match("^%w+://") then return end
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = augroup,
  callback = function()
    if vim.bo.filetype == "" and vim.api.nvim_buf_get_name(0) == "" and vim.bo.buftype == "" then
      vim.bo.filetype = "markdown"
    end
  end,
})
