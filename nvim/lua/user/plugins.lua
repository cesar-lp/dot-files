local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  { "nvim-lua/plenary.nvim", lazy = true }, -- Useful lua functions used by lots of plugins (loaded on require)
  { "windwp/nvim-autopairs" }, -- Autopairs, integrates with both cmp and treesitter
  { "numToStr/Comment.nvim" },
  { "kylechui/nvim-surround" },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua" },
  { "akinsho/bufferline.nvim" },
  { "moll/vim-bbye", cmd = { "Bdelete", "Bwipeout" } },
  { "nvim-lualine/lualine.nvim" },
  {
    "akinsho/toggleterm.nvim",
    -- Right after the first frame: its <c-\> mapping and the _X_TOGGLE helpers
    -- that which-key calls are defined in user.toggleterm.
    event = "VeryLazy",
    config = function()
      require "user.toggleterm"
    end,
  },
  { "ahmedkhalf/project.nvim" },
  { "lukas-reineke/indent-blankline.nvim" },
  { "goolord/alpha-nvim" },
  { "echasnovski/mini.icons", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "folke/which-key.nvim" },

  -- Colorschemes: only the active one loads at startup; lazy.nvim loads the
  -- others when `:colorscheme <name>` asks for them.
  { "folke/tokyonight.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "rose-pine/neovim", name = "rose-pine" },

  -- cmp plugins
  { "hrsh7th/nvim-cmp" }, -- The completion plugin
  { "hrsh7th/cmp-buffer" }, -- buffer completions
  { "hrsh7th/cmp-path" }, -- path completions
  { "saadparwaiz1/cmp_luasnip" }, -- snippet completions
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-nvim-lua" },

  -- snippets
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "nvimtools/none-ls.nvim" },
  { "RRethy/vim-illuminate" },
  { "simrat39/rust-tools.nvim", lazy = true }, -- not required anywhere yet

  -- Lua
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("user.trouble")
    end,
  },
  { "folke/neodev.nvim", lazy = true }, -- set up with nvim-dap (user.dap)
  { "tjdevries/stackmap.nvim", lazy = true }, -- used by user.dap

  -- Telescope: loads on :Telescope or the first require("telescope...") from a key.
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    config = function()
      require "user.telescope"
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },

  -- Git
  { "lewis6991/gitsigns.nvim" },
  { "tpope/vim-fugitive", event = "VeryLazy" },

  -- Syntax / parsing (load at startup so config can run)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("user.treesitter")
    end,
  },

  -- DAP (mason-nvim-dap installs adapters; one place with Mason for LSP + DAP).
  -- Loads on the first require("dap") (the <leader>d keys) or a :Dap command.
  {
    "mfussenegger/nvim-dap",
    cmd = {
      "DapContinue", "DapToggleBreakpoint", "DapClearBreakpoints", "DapStepOver",
      "DapStepInto", "DapStepOut", "DapTerminate", "DapToggleRepl", "DapNew",
      "DapEval", "DapShowLog", "DapSetLogLevel", "DapPause", "DapDisconnect",
      "DapRestartFrame", "DapInstall", "DapUninstall",
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
      "mxsdev/nvim-dap-vscode-js",
      "folke/neodev.nvim",
      "tjdevries/stackmap.nvim",
    },
    config = function()
      require "user.dap"
    end,
  },
  { "nvim-neotest/nvim-nio", lazy = true },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
  },
  { "jay-babu/mason-nvim-dap.nvim", lazy = true, dependencies = { "williamboman/mason.nvim" } },
  { "leoluz/nvim-dap-go", lazy = true },
  { "theHamsta/nvim-dap-virtual-text", lazy = true },
  { "mxsdev/nvim-dap-vscode-js", lazy = true, dependencies = { "mfussenegger/nvim-dap" } },

  -- Folding
  { "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },

  -- LLM chat & edits (persistent markdown chats, inline rewrite/append/prepend)
  {
    "frankroeder/parrot.nvim",
    -- Only commands, no global keys: load on the first :Prt… (<leader>pc).
    cmd = {
      "PrtChatNew", "PrtChatToggle", "PrtChatPaste", "PrtChatFinder", "PrtChatDelete",
      "PrtChatResponde", "PrtAsk", "PrtRewrite", "PrtAppend", "PrtPrepend", "PrtEdit",
      "PrtImplement", "PrtRetry", "PrtCmd", "PrtContext", "PrtModel", "PrtProvider",
      "PrtInfo", "PrtStatus", "PrtStop", "PrtLog", "PrtReloadCache",
    },
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    config = function()
      require("user.parrot").setup()
    end,
  },
}

local opts = {}

require("lazy").setup(plugins, opts)
