require("snacks").setup {
  bigfile = {},
  dashboard = {},
  explorer = {
    replace_netrw = false, -- oil opens directories
  },
  indent = {},
  input = {},
  picker = {},
  notifier = {
    timeout = 3000,
  },
  quickfile = {},
  scope = {},
  scroll = {},
  statuscolumn = {},
  words = {},
  zen = { enabled = false },

  animate = {},
  git = {},
  lazygit = {},
  terminal = {},
  win = {},
}

-- { lhs, rhs, desc, mode? }
local keys = {
  -- Top Pickers & Explorer
  { "<leader><space>", function() Snacks.picker.smart() end, "Smart Find Files" },
  { "<leader>,", function() Snacks.picker.buffers() end, "Buffers" },
  { "<leader>/", function() Snacks.picker.grep() end, "Grep" },
  { "<leader>:", function() Snacks.picker.command_history() end, "Command History" },
  { "<leader>n", function() Snacks.picker.notifications() end, "Notification History" },
  { "<leader>e", function() Snacks.explorer() end, "File Explorer" },
  -- find
  { "<leader>fb", function() Snacks.picker.buffers() end, "Buffers" },
  { "<leader>fc", function() Snacks.picker.files { cwd = vim.fn.stdpath "config" } end, "Find Config File" },
  { "<leader>ff", function() Snacks.picker.files() end, "Find Files" },
  { "<leader>fg", function() Snacks.picker.git_files() end, "Find Git Files" },
  { "<leader>fp", function() Snacks.picker.projects() end, "Projects" },
  { "<leader>fr", function() Snacks.picker.recent() end, "Recent" },
  -- git
  { "<leader>gb", function() Snacks.picker.git_branches() end, "Git Branches" },
  { "<leader>gl", function() Snacks.picker.git_log() end, "Git Log" },
  { "<leader>gL", function() Snacks.picker.git_log_line() end, "Git Log Line" },
  { "<leader>gs", function() Snacks.picker.git_status() end, "Git Status" },
  { "<leader>gS", function() Snacks.picker.git_stash() end, "Git Stash" },
  { "<leader>gd", function() Snacks.picker.git_diff() end, "Git Diff (Hunks)" },
  { "<leader>gf", function() Snacks.picker.git_log_file() end, "Git Log File" },
  -- grep
  { "<leader>sb", function() Snacks.picker.lines() end, "Buffer Lines" },
  { "<leader>sB", function() Snacks.picker.grep_buffers() end, "Grep Open Buffers" },
  { "<leader>sg", function() Snacks.picker.grep() end, "Grep" },
  { "<leader>sw", function() Snacks.picker.grep_word() end, "Visual selection or word", { "n", "x" } },
  -- search
  { '<leader>s"', function() Snacks.picker.registers() end, "Registers" },
  { "<leader>s/", function() Snacks.picker.search_history() end, "Search History" },
  { "<leader>sa", function() Snacks.picker.autocmds() end, "Autocmds" },
  { "<leader>sc", function() Snacks.picker.command_history() end, "Command History" },
  { "<leader>sC", function() Snacks.picker.commands() end, "Commands" },
  { "<leader>sd", function() Snacks.picker.diagnostics() end, "Diagnostics" },
  { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, "Buffer Diagnostics" },
  { "<leader>sh", function() Snacks.picker.help() end, "Help Pages" },
  { "<leader>sH", function() Snacks.picker.highlights() end, "Highlights" },
  { "<leader>si", function() Snacks.picker.icons() end, "Icons" },
  { "<leader>sj", function() Snacks.picker.jumps() end, "Jumps" },
  { "<leader>sk", function() Snacks.picker.keymaps() end, "Keymaps" },
  { "<leader>sl", function() Snacks.picker.loclist() end, "Location List" },
  { "<leader>sm", function() Snacks.picker.marks() end, "Marks" },
  { "<leader>sM", function() Snacks.picker.man() end, "Man Pages" },
  { "<leader>sq", function() Snacks.picker.qflist() end, "Quickfix List" },
  { "<leader>sR", function() Snacks.picker.resume() end, "Resume" },
  { "<leader>su", function() Snacks.picker.undo() end, "Undo History" },
  { "<leader>uC", function() Snacks.picker.colorschemes() end, "Colorschemes" },
  -- LSP
  { "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition" },
  { "gD", function() Snacks.picker.lsp_declarations() end, "Goto Declaration" },
  { "gr", function() Snacks.picker.lsp_references() end, "References", nil, { nowait = true } },
  { "gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation" },
  { "gy", function() Snacks.picker.lsp_type_definitions() end, "Goto T[y]pe Definition" },
  { "<leader>ss", function() Snacks.picker.lsp_symbols() end, "LSP Symbols" },
  { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols" },
  -- other
  { "<leader>z", function() Snacks.zen() end, "Toggle Zen Mode" },
  { "<leader>Z", function() Snacks.zen.zoom() end, "Toggle Zoom" },
  { "<leader>.", function() Snacks.scratch() end, "Toggle Scratch Buffer" },
  { "<leader>S", function() Snacks.scratch.select() end, "Select Scratch Buffer" },
  { "<leader>bd", function() Snacks.bufdelete() end, "Delete Buffer" },
  { "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File" },
  { "<leader>gB", function() Snacks.gitbrowse() end, "Git Browse", { "n", "v" } },
  { "<leader>gg", function() Snacks.lazygit() end, "Lazygit" },
  { "<leader>un", function() Snacks.notifier.hide() end, "Dismiss All Notifications" },
  { "<c-/>", function() Snacks.terminal() end, "Toggle Terminal" },
  { "<c-_>", function() Snacks.terminal.toggle() end, "which_key_ignore" },
  { "]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference", { "n", "t" } },
  { "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference", { "n", "t" } },
  {
    "<leader>N",
    function()
      Snacks.win {
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      }
    end,
    "Neovim News",
  },
}
for _, k in ipairs(keys) do
  vim.keymap.set(k[4] or "n", k[1], k[2], vim.tbl_extend("force", { desc = k[3] }, k[5] or {}))
end

-- debugging globals
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
vim.print = _G.dd -- Override print to use snacks for `:=` command

-- toggles
Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
Snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>uw"
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map "<leader>uL"
Snacks.toggle.diagnostics():map "<leader>ud"
Snacks.toggle.line_number():map "<leader>ul"
Snacks.toggle
  .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
  :map "<leader>uc"
Snacks.toggle.treesitter():map "<leader>uT"
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map "<leader>ub"
Snacks.toggle.inlay_hints():map "<leader>uh"
Snacks.toggle.indent():map "<leader>ug"
Snacks.toggle.dim():map "<leader>uD"
