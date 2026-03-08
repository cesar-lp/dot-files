local status_ok, wk = pcall(require, "which-key")
if not status_ok then
  vim.notify("Error requiring which-key")
  return
end

-- New which-key v3 options (replaces deprecated opts.hidden, popup_mappings, window, key_labels, ignore_missing, triggers_blacklist).
local setup = {
  plugins = {
    marks = true,
    registers = true,
    spelling = { enabled = true, suggestions = 20 },
    presets = {
      operators = false,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  icons = {
    breadcrumb = ">",
    separator = ">",
    group = "+",
  },
  keys = {
    scroll_down = "<c-d>",
    scroll_up = "<c-u>",
  },
  win = {
    no_overlap = true,
    padding = { 1, 2 },
    title = true,
    title_pos = "center",
    zindex = 1000,
    wo = { winblend = 0 },
  },
  layout = {
    height = { min = 3, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 3,
    align = "left",
  },
  -- Only show mappings that have a description (our spec + keymaps with desc from plugins).
  filter = function(mapping)
    return mapping.desc and mapping.desc ~= ""
  end,
  show_help = true,
  triggers = {
    { "<leader>", mode = "n" },
  },
}

wk.setup(setup)

-- New which-key v3 spec: use wk.add() with [1]=lhs, [2]=rhs, desc, group, mode.
wk.add({
  mode = "n",
  { "<leader>a", "<cmd>Alpha<cr>", desc = "Alpha" },
  { "<leader>b", "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>", desc = "Buffers" },
  { "<leader>c", "<cmd>Bdelete!<cr>", desc = "Close current buffer" },
  { "<leader>pc", "<cmd>PrtChatNew<cr>", desc = "Parrot: new chat" },
  { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
  { "<leader>w", "<cmd>w!<CR>", desc = "Save" },
  { "<leader>q", "<cmd>q!<CR>", desc = "Quit" },
  { "<leader>h", "<cmd>nohlsearch<CR>", desc = "No Highlight" },
  { "<leader>p", "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = "Projects" },

  { "<leader>C", group = "CloseBuffer", {
    { "<leader>Cc", "<cmd>Bdelete!<CR>", desc = "Close current buffer" },
    { "<leader>Ca", "<cmd>:%bd|Bdelete!<cr>", desc = "Close all buffers" },
    { "<leader>Co", "<cmd>:%bd|e#|bd#<cr>", desc = "Close all other buffers" },
  }},

  { "<leader>d", group = "Debug", {
    { "<leader>dp", "<cmd>lua require 'dap'.toggle_breakpoint()<cr>", desc = "Set breakpoint" },
    { "<leader>dP", "<cmd>lua require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", desc = "Set breakpoint (condition)" },
    { "<leader>dc", "<cmd>lua require 'dap'.continue()<cr>", desc = "Continue" },
    { "<leader>do", "<cmd>lua require 'dap'.step_over()<cr>", desc = "Step over" },
    { "<leader>dO", "<cmd>lua require 'dap'.step_out()<cr>", desc = "Step out" },
    { "<leader>di", "<cmd>lua require 'dap'.step_into()<cr>", desc = "Step into" },
    { "<leader>dr", "<cmd>lua require 'dap'.repl.open()<cr>", desc = "REPL" },
  }},

  { "<leader>g", group = "Git", {
    { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
    { "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Diff" },
    { "<leader>gi", "<cmd>lua _GITUI_TOGGLE()<cr>", desc = "Interactive GIT (gitui)" },
    { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = "Next Hunk" },
    { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", desc = "Prev Hunk" },
    { "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = "Blame" },
    { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
    { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
    { "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
    { "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
    { "<leader>gt", "<cmd>Telescope git_status<cr>", desc = "Status" },
    { "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage" },
  }},

  { "<leader>l", group = "Lsp", {
    { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
    { "<leader>ld", "<cmd>Telescope lsp_document_diagnostics<cr>", desc = "Document Diagnostics" },
    { "<leader>lw", "<cmd>TroubleToggle<cr>", desc = "Workspace Diagnostics" },
    { "<leader>lf", "<cmd>lua vim.lsp.buf.format { async = true }<cr>", desc = "Format" },
    { "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
    { "<leader>lI", "<cmd>LspInstallInfo<cr>", desc = "Installer Info" },
    { "<leader>lj", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", desc = "Next Diagnostic" },
    { "<leader>lk", "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>", desc = "Prev Diagnostic" },
    { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
    { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
    { "<leader>lq", "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", desc = "Quickfix" },
    { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
    { "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
  }},

  { "<leader>P", group = "Plugin", {
    { "<leader>Pi", "<cmd>lua require 'lazy'.home()<cr>", desc = "Info" },
    { "<leader>Ph", "<cmd>lua require 'lazy'.health()<cr>", desc = "Health" },
  }},

  { "<leader>s", group = "Search", {
    { "<leader>sf", "<cmd>lua require('telescope.builtin').find_files()<cr>", desc = "Search files" },
    { "<leader>so", "<cmd>Telescope oldfiles<cr>", desc = "Old files" },
    { "<leader>sp", "<cmd>lua require('telescope.builtin').resume()<cr>", desc = "Previous search" },
    { "<leader>sr", "<cmd>Telescope grep_string<cr>", desc = "Search references" },
    { "<leader>st", "<cmd>Telescope live_grep theme=ivy<cr>", desc = "Search text" },
    { "<leader>sT", "<cmd>lua require('telescope.builtin').grep_string { default_text = 'TODO'}<cr>", desc = "Find TODOs" },
  }},

  { "<leader>t", group = "Term", {
    { "<leader>tn", "<cmd>lua _NODE_TOGGLE()<cr>", desc = "Node" },
    { "<leader>tu", "<cmd>lua _NCDU_TOGGLE()<cr>", desc = "NCDU" },
    { "<leader>tt", "<cmd>lua _HTOP_TOGGLE()<cr>", desc = "Htop" },
    { "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<cr>", desc = "Python" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
    { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Horizontal" },
    { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical" },
  }},

  { "<leader>u", group = "Util", {
    { "<leader>uc", "<cmd>Telescope commands<cr>", desc = "Show Commands" },
    { "<leader>uk", "<cmd>Telescope keymaps<cr>", desc = "Show Keymaps" },
    { "<leader>uh", "<cmd>Telescope help_tags<cr>", desc = "Show Help" },
    { "<leader>um", "<cmd>Telescope man_pages<cr>", desc = "Show Man Pages" },
    { "<leader>ur", "<cmd>Telescope registers<cr>", desc = "Show Registers" },
  }},
})
