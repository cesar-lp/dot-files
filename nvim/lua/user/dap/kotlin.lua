-- Kotlin DAP: custom adapter (if built) or Java adapter (Kotlin JVM uses same DAP as Java).
local M = {}

local HOME = os.getenv "HOME"
local DEBUGGER_LOCATION = HOME .. "/.local/share/nvim/kotlin-debug-adapter"
local custom_adapter_path = DEBUGGER_LOCATION .. "/adapter/build/install/adapter/bin/kotlin-debug-adapter"

M.setup = function()
  local dap = require "dap"

  -- Custom Kotlin adapter (optional: only if you built kotlin-debug-adapter locally)
  if vim.fn.executable(custom_adapter_path) == 1 then
    dap.adapters.kotlin = {
      type = "executable",
      command = custom_adapter_path,
      args = { "--interpreter=vscode" },
    }
    dap.configurations.kotlin = {
      {
        type = "kotlin",
        name = "Kotlin (custom adapter)",
        request = "launch",
        projectRoot = vim.fn.getcwd() .. "/app",
        mainClass = function()
          return vim.fn.input("Path to main class > ", "", "file")
        end,
      },
    }
  end

  -- Kotlin JVM: use Java debug adapter (java-debug-adapter from Mason).
  -- Add to existing or create configurations.kotlin.
  local kotlin_configs = dap.configurations.kotlin or {}
  table.insert(kotlin_configs, {
    type = "java",
    request = "launch",
    name = "Kotlin (JVM via Java adapter)",
    mainClass = function()
      return vim.fn.input("Main class (e.g. MainKt) > ", "", "file")
    end,
  })
  dap.configurations.kotlin = kotlin_configs
end

return M
