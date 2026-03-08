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
  { "nvim-lua/plenary.nvim" }, -- Useful lua functions used by lots of plugins
  { "windwp/nvim-autopairs" }, -- Autopairs, integrates with both cmp and treesitter
  { "numToStr/Comment.nvim" },
  { "kylechui/nvim-surround" },
  { "nvim-tree/nvim-web-devicons" },
  { "nvim-tree/nvim-tree.lua" },
  { "akinsho/bufferline.nvim" },
  { "moll/vim-bbye" },
  { "nvim-lualine/lualine.nvim" },
  { "akinsho/toggleterm.nvim" },
  { "ahmedkhalf/project.nvim" },
  { "lukas-reineke/indent-blankline.nvim" },
  { "goolord/alpha-nvim" },
  { "echasnovski/mini.icons", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "folke/which-key.nvim" },

  -- Colorschemes
  { "folke/tokyonight.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "sainnhe/gruvbox-material" },
  { "catppuccin/nvim", name = "catppuccin" },
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
  { "simrat39/rust-tools.nvim" },

  -- Lua
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  { "folke/neodev.nvim" },
  { "tjdevries/stackmap.nvim" },

  -- Telescope
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Git
  { "lewis6991/gitsigns.nvim" },
  { "tpope/vim-fugitive" },

  -- Syntax / parsing (load at startup so config can run)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("user.treesitter")
    end,
  },

  -- DAP (mason-nvim-dap installs adapters; one place with Mason for LSP + DAP)
  { "mfussenegger/nvim-dap" },
  { "nvim-neotest/nvim-nio" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio", "mfussenegger/nvim-dap" },
  },
  { "jay-babu/mason-nvim-dap.nvim", dependencies = { "williamboman/mason.nvim" } },
  { "leoluz/nvim-dap-go" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "mxsdev/nvim-dap-vscode-js", dependencies = { "mfussenegger/nvim-dap" } },

  -- Folding
  { "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async" } },

  -- LLM chat & edits (persistent markdown chats, inline rewrite/append/prepend)
  {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    config = function()
      require("user.parrot").setup()
    end,
  },
}

local opts = {}

require("lazy").setup(plugins, opts)
