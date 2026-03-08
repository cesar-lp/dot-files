-- Options documented in :help nvim-tree.OPTION_NAME

local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  vim.notify("Error requiring nvim-tree")
  return
end

-- Auto-close when tree is the only window
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") then
      vim.cmd "quit"
    end
  end,
})

-- Use public API for mappings (nvim_tree_callback was removed in newer nvim-tree)
-- l = open/expand folder or open file; h = collapse folder (no character-wise movement in tree)
local function on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = function(desc)
    return { buffer = bufnr, desc = "nvim-tree: " .. desc, noremap = true, silent = true, nowait = true }
  end
  api.map.on_attach.default(bufnr)
  -- Override h/l so they only expand/collapse; no walking within folder name letters
  vim.keymap.set("n", "l", api.node.open.edit, opts("Edit or open"))
  vim.keymap.set("n", "h", api.node.collapse, opts("Collapse folder"))
end

nvim_tree.setup {
  on_attach = on_attach,
  disable_netrw = true,
  hijack_netrw = true,
  open_on_tab = false,
  hijack_cursor = false,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
    ignore_list = {},
  },
  system_open = {
    cmd = nil,
    args = {},
  },
  filters = {
    dotfiles = false,
    custom = {},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 40,
    side = "left",
    number = false,
    relativenumber = false,
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
  actions = {
    open_file = {
      quit_on_open = true,
      window_picker = {
        enable = false,
      },
    },
  },
  renderer = {
    icons = {
      glyphs = {
        default = "",
        symlink = "",
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          deleted = "",
          untracked = "U",
          ignored = "◌",
        },
        folder = {
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  },
}
