-- mason-nvim-dap: install DAP adapters via Mason (same UX as LSP installs).
-- Ensures js-debug-adapter (TS/JS), java-debug-adapter (Java + Kotlin JVM).
local M = {}

M.setup = function()
  local ok, mason_dap = pcall(require, "mason-nvim-dap")
  if not ok then
    vim.notify("mason-nvim-dap not available", vim.log.levels.WARN)
    return
  end

  mason_dap.setup({
    automatic_installation = true,
    ensure_installed = {
      "js-debug-adapter",  -- TypeScript / JavaScript (used by nvim-dap-vscode-js)
      "java-debug-adapter", -- Java; Kotlin JVM can use this too
    },
    handlers = {},
  })
end

return M
