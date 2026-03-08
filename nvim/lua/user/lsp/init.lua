-- LSP: mason sets up servers via vim.lsp.config + vim.lsp.enable (Neovim 0.11+)
-- nvim-lspconfig is loaded by mason-lspconfig and populates vim.lsp.config
require "user.lsp.mason"
require("user.lsp.handlers").setup()
require "user.lsp.null-ls"
