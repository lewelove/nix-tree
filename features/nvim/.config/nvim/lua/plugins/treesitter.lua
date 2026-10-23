return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local ts = require("nvim-treesitter")
    
    ts.setup()

    require("nvim-treesitter.install").prefer_git = true

    local parsers = {
      "c",
      "rust",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "python",
      "javascript",
      "typescript",
      "html",
      "css",
      "json",
      "svelte",
      "markdown",
      "markdown_inline",
      "nix",
      "toml",
      "bash",
    }

    ts.install(parsers)

    vim.treesitter.language.register("markdown", "md")
    vim.treesitter.language.register("javascript", "js")
    vim.treesitter.language.register("typescript", "ts")
    vim.treesitter.language.register('json', { 'jsonc' })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "c",
        "rust",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "json",
        "jsonc",
        "svelte",
        "markdown",
        "markdown_inline",
        "nix",
        "toml",
        "bash",
      },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
