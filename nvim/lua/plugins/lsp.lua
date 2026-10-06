-- Server configs live in lsp/*.lua (picked up by vim.lsp.config automatically).
-- mason only installs the binaries.
local servers = {
  lua_ls = "lua-language-server",
  pyright = "pyright",
  ols = "ols",
}

require("mason").setup()

local registry = require "mason-registry"
registry.refresh(function()
  for _, pkg_name in pairs(servers) do
    local pkg = registry.get_package(pkg_name)
    if not pkg:is_installed() and not pkg:is_installing() then
      pkg:install()
    end
  end
end)

vim.lsp.enable(vim.tbl_keys(servers))

-- Completion: built-in 'autocomplete' with LSP results via omnifunc ("o"),
-- then words from this and other buffers
vim.o.autocomplete = true
vim.o.complete = "o,.^5,w^5,b^5"
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.pumborder = "rounded"

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP completion side effects (snippets, auto-imports) on accept",
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client:supports_method "textDocument/completion" then
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end
  end,
})

local function selected()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1
end

-- <CR> accepts a selected item, otherwise newline (with autopairs' bracket handling)
vim.keymap.set("i", "<CR>", function()
  if selected() then
    return "<C-y>"
  end
  return require("nvim-autopairs").autopairs_cr()
end, { expr = true, replace_keycodes = false, desc = "Accept completion or newline" })

-- <Tab>/<S-Tab> move through the menu, else jump snippet placeholders
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif vim.snippet.active { direction = 1 } then
    return "<cmd>lua vim.snippet.jump(1)<cr>"
  end
  return "<Tab>"
end, { expr = true, desc = "Next completion / snippet placeholder" })
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif vim.snippet.active { direction = -1 } then
    return "<cmd>lua vim.snippet.jump(-1)<cr>"
  end
  return "<S-Tab>"
end, { expr = true, desc = "Prev completion / snippet placeholder" })
