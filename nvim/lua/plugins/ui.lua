-- Follow the OS appearance: Nvim sets 'background' from the terminal's colors at
-- startup and again whenever the terminal reports a light/dark switch.
local function apply_theme()
  vim.cmd.colorscheme(vim.o.background == "light" and "dracula-pro-alucard" or "dracula-pro-nosferatu")
end
vim.api.nvim_create_autocmd("OptionSet", { pattern = "background", callback = apply_theme })
apply_theme()

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
