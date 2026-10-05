-- nvim-treesitter's main branch: it only installs parsers, highlighting is
-- started by Neovim itself. Parsers are compiled with the tree-sitter CLI.
require("nvim-treesitter").install {
  "bash",
  "c",
  "diff",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "odin",
  "printf",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

vim.api.nvim_create_autocmd("FileType", {
  desc = "Start treesitter highlighting and indent",
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
