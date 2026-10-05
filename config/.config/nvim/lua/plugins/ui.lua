require("ember").setup {
  variant = "ember-soft", -- "ember" | "ember-soft" | "ember-light" | "ember-lighter" | "ember-auto"
}
vim.cmd.colorscheme "ember-soft"

require("gitsigns").setup()

local wk = require "which-key"
wk.setup()
wk.add {
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>f", group = "file/find" },
  { "<leader>g", group = "git" },
  { "<leader>p", group = "plugins" },
  { "<leader>q", group = "quit" },
  { "<leader>s", group = "search" },
  { "<leader>u", group = "ui" },
}
