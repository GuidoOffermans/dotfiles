vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    -- hl_op replaces on_yank in 0.13; macOS runs stable 0.12
    if vim.hl.hl_op then
      vim.hl.hl_op()
    else
      vim.hl.on_yank()
    end
  end,
})
