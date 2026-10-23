local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil

if is_ssh then
  local osc52 = require("vim.ui.clipboard.osc52")

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = function()
        return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
      end,
      ["*"] = function()
        return { vim.fn.getreg('"', 1, true), vim.fn.getregtype('"') }
      end,
    },
  }

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("Osc52Yank", { clear = true }),
    callback = function()
      if vim.v.event.operator == "y" then
        osc52.copy("+")(vim.v.event.regcontents)
      end
    end,
  })
end

vim.opt.clipboard = "unnamedplus"

-- vim.keymap.set({ "v", "x" }, "<leader>y", '"+y', { desc = "Yank selection to clipboard" })
vim.keymap.set("n", "<leader>y", 'ggVG"+y', { desc = "Yank whole buffer to clipboard" })
