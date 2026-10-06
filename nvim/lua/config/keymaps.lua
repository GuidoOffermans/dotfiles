local map = vim.keymap.set

map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlight" })
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- code (Neovim's own gr* LSP maps work too: grn, gra, grr, gri)
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map({ "n", "x" }, "<leader>cf", function()
  vim.lsp.buf.format()
end, { desc = "Format" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- plugins
map("n", "<leader>pu", function()
  vim.pack.update()
end, { desc = "Update Plugins" })
