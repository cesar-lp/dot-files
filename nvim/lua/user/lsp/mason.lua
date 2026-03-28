-- gopls: installed by ./bootstrap.sh (go install) and expected on PATH via zsh (GOPATH/bin). Mason does not install gopls.
local servers = {
  "cssls",
  "html",
  "ts_ls",
  "pyright",
  "bashls",
  "jsonls",
  "yamlls",
  "rust_analyzer",
  "gopls", -- use binary from PATH
  "kotlin_language_server",
}

-- Mason should not install gopls (we use the one from bootstrap).
local mason_servers = vim.tbl_filter(function(s) return s ~= "gopls" end, servers)

local settings = {
  ui = {
    border = "none",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    }, },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
  ensure_installed = mason_servers,
  automatic_installation = true
})

-- Load nvim-lspconfig so vim.lsp.config gets default server configs (cmd, filetypes, etc.)
require("lspconfig")

-- Use vim.lsp.config (Neovim 0.11+) instead of deprecated lspconfig[server].setup()
local handlers = require("user.lsp.handlers")
local capabilities = handlers.capabilities

for _, server in pairs(servers) do
  server = vim.split(server, "@")[1]

  local opts = {
    capabilities = capabilities,
  }

  local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", opts, conf_opts)
  end

  -- Extend or set config; on_attach is handled via LspAttach in handlers.lua
  local existing = vim.lsp.config[server] or {}
  vim.lsp.config[server] = vim.tbl_deep_extend("force", existing, opts)
end

vim.lsp.enable(servers)
