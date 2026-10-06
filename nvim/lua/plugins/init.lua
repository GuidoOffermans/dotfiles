local function gh(repo)
  return "https://github.com/" .. repo
end

-- build steps, registered before vim.pack.add so they also run on first install
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd "nvim-treesitter"
      end
      vim.cmd "TSUpdate"
    end
  end,
})

vim.pack.add {
  { src = gh "ember-theme/nvim", name = "ember" },
  gh "nvim-tree/nvim-web-devicons",
  gh "folke/snacks.nvim",
  gh "folke/which-key.nvim",
  gh "lewis6991/gitsigns.nvim",
  gh "windwp/nvim-autopairs",
  gh "christoomey/vim-tmux-navigator",
  gh "mikavilpas/yazi.nvim",
  gh "stevearc/oil.nvim",
  { src = gh "nvim-treesitter/nvim-treesitter", version = "main" },
  gh "mason-org/mason.nvim",
}

require "plugins.ui"
require "plugins.snacks"
require "plugins.editor"
require "plugins.treesitter"
require "plugins.lsp"
