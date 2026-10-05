vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.winborder = "rounded"
opt.scrolloff = 4

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.confirm = true
opt.swapfile = false
opt.undofile = true

vim.diagnostic.config { virtual_text = true, severity_sort = true }
