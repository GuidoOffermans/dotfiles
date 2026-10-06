require("nvim-autopairs").setup { map_cr = false } -- <CR> is mapped in lsp.lua to also accept completions

-- vim-tmux-navigator maps <C-h/j/k/l> itself; outside tmux they just move between splits

-- oil: edit directories like buffers, also replaces netrw (`nvim .`, `:e dir`)
require("oil").setup {
  view_options = { show_hidden = true },
}
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

require("yazi").setup {
  open_for_directories = false,
  keymaps = {
    show_help = "<f1>",
  },
}
vim.keymap.set({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
vim.keymap.set("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open yazi in nvim's working directory" })
vim.keymap.set("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })
