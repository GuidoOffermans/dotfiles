return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require "nvim-treesitter.configs"
        configs.setup {
            auto_install = true,
            ensure_installed = {
                "lua",
                "vim",
                "vimdoc",
                "html",
                "css",
                "typescript",
                "javascript",
                "odin",
            },

            highlight = {
                enable = true,
                use_languagetree = true,
            },
            indent = { enable = true },
        }
    end,
}
