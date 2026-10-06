require("nvim-autopairs").setup { map_cr = false } -- <CR> is mapped in lsp.lua to also accept completions

-- vim-tmux-navigator maps <C-h/j/k/l> itself; outside tmux they just move between splits

-- oil: edit directories like buffers, also replaces netrw (`nvim .`, `:e dir`)
require("oil").setup {
  view_options = { show_hidden = true },
}
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
