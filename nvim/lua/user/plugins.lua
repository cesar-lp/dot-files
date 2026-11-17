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
  {
    "windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter
    event = "InsertEnter",
    config = function()
      require "user.autopairs"
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy", -- gc/gb right after the first frame
    config = function()
      require "user.comment"
    end,
  },
  { "kylechui/nvim-surround", event = "VeryLazy" },
  { "nvim-tree/nvim-web-devicons" },
  {
    "nvim-tree/nvim-tree.lua",
    -- Loads on its commands (<leader>e) or when a folder is opened: `nvim <folder>` or
    -- `:edit <folder>` later. A file opened directly doesn't load it.
    cmd = {
      "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeFindFileToggle",
      "NvimTreeClose", "NvimTreeRefresh", "NvimTreeCollapse", "NvimTreeCollapseKeepBuffers",
      "NvimTreeResize", "NvimTreeClipboard", "NvimTreeHiTest",
    },
    init = function()
      -- nvim-tree replaces netrw (disable_netrw); keep netrw off until it loads.
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      local group = vim.api.nvim_create_augroup("UserNvimTreeLoad", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
        group = group,
        nested = true,
        callback = function(ev)
          if vim.fn.isdirectory(ev.file) ~= 1 then
            return
          end
          require("lazy").load({ plugins = { "nvim-tree.lua" } })
          -- nvim-tree's own BufEnter hijack was created during this event; run it for this buffer.
          require("nvim-tree").open_on_directory()
        end,
      })
    end,
    config = function()
      -- Loaded (by a command or a folder): from now on nvim-tree's own hijack handles folders.
      pcall(vim.api.nvim_del_augroup_by_name, "UserNvimTreeLoad")
      require "user.nvim-tree"
    end,
  },
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
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" }, -- only buffers with a file have guides
    config = function()
      require "user.indentline"
    end,
  },
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

  -- cmp plugins: completion and snippets load on the first InsertEnter.
  {
    "hrsh7th/nvim-cmp", -- The completion plugin
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require "user.cmp"
    end,
  },
  { "hrsh7th/cmp-buffer", lazy = true }, -- buffer completions
  { "hrsh7th/cmp-path", lazy = true }, -- path completions
  { "saadparwaiz1/cmp_luasnip", lazy = true }, -- snippet completions
  { "hrsh7th/cmp-nvim-lsp", lazy = true }, -- also required by user.lsp.handlers for capabilities
  { "hrsh7th/cmp-nvim-lua", lazy = true },

  -- snippets
  { "L3MON4D3/LuaSnip", lazy = true, dependencies = { "rafamadriz/friendly-snippets" } },
  { "rafamadriz/friendly-snippets", lazy = true },

  -- LSP: Mason, the server configs and none-ls load with the first file or on a :Mason / :Lsp
  -- command. A file nvim starts with doesn't wait for them: they load right after the first
  -- frame and attach to it then (user.lsp).
  {
    "neovim/nvim-lspconfig",
    init = function()
      local function load()
        require("lazy").load({ plugins = { "nvim-lspconfig" } })
      end
      vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("UserLspLoad", { clear = true }),
        once = true,
        callback = function()
          if vim.v.vim_did_enter == 1 then
            load() -- a file opened later: before its FileType, as usual
          elseif #vim.api.nvim_list_uis() == 0 then
            vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = load }) -- headless: no first frame
          else
            vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", once = true, callback = load })
          end
        end,
      })
    end,
    cmd = {
      "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate",
      "LspInfo", "LspStart", "LspStop", "LspRestart", "LspLog", "LspInstall", "LspUninstall",
    },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "nvimtools/none-ls.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require "user.lsp"
    end,
  },
  { "williamboman/mason.nvim", lazy = true }, -- set up in user.lsp.mason
  { "williamboman/mason-lspconfig.nvim", lazy = true },
  { "nvimtools/none-ls.nvim", lazy = true },
  { "RRethy/vim-illuminate", event = { "BufReadPost", "BufNewFile" } },
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
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- signs are per file; a folder doesn't need them
    config = function()
      require "user.gitsigns"
    end,
  },
  { "tpope/vim-fugitive", event = "VeryLazy" },

  -- Syntax / parsing: loads with the first file, before its FileType.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate", "TSUninstall", "TSLog" },
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
      "neovim/nvim-lspconfig", -- sets up Mason, which mason-nvim-dap needs
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

  -- Folding: the fold options live in user.options; ufo itself loads with the first file.
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require "user.nvim-ufo"
    end,
  },
  { "kevinhwang91/promise-async", lazy = true },

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
