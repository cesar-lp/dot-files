local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  vim.notify("Error requiring cmp_nvim_lsp")
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities()

M.setup = function()
  -- Use LspAttach for on_attach (Neovim 0.11+); per-server on_attach in config is deprecated
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end
      M.on_attach(client, args.buf)
    end,
  })

  -- Use vim.diagnostic.config for sign text (sign_define for diagnostics is deprecated in Neovim 0.11+)
  local config = {
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN]  = "",
        [vim.diagnostic.severity.HINT]  = "",
        [vim.diagnostic.severity.INFO]  = "",
      },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function map(bufnr, key, command)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap

  keymap(bufnr, "n", key, "<cmd>" .. command .. "<CR>", opts)
end

local function lsp_keymaps(bufnr)
  map(bufnr, "gD", "lua vim.lsp.buf.declaration()")
  map(bufnr, "gd", "lua vim.lsp.buf.definition()")
  map(bufnr, "K", "lua vim.lsp.buf.hover()")
  map(bufnr, "gI", "lua vim.lsp.buf.implementation()")
  map(bufnr, "gr", "lua vim.lsp.buf.references()")
  map(bufnr, "gl", "lua vim.diagnostic.open_float()")
  map(bufnr, "<leader>lf", "lua vim.lsp.buf.format { async = true }")
  map(bufnr, "<leader>li", "LspInfo")
  map(bufnr, "<leader>lI", "LspInstallInfo")
  map(bufnr, "<leader>la", "lua vim.lsp.buf.code_action()")
  map(bufnr, "<leader>lj", "lua vim.diagnostic.goto_next({buffer=0})")
  map(bufnr, "<leader>lk", "lua vim.diagnostic.goto_prev({buffer=0})")
  map(bufnr, "<leader>lr", "lua vim.lsp.buf.rename()")
  map(bufnr, "<leader>ls", "lua vim.lsp.buf.signature_help()")
  map(bufnr, "<leader>lq", "lua vim.diagnostic.setloclist()")
end

M.on_attach = function(client, bufnr)
  if client.name == "ts_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "rust_analyzer" then
    client.cmd = {
      "rustup", "run", "stable", "rust-analyzer"
    }
  end

  lsp_keymaps(bufnr)

  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    vim.notify("Error requiring iluminate")
    return
  end

  illuminate.on_attach(client)
end

return M
