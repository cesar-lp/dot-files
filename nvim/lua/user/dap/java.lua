-- Java DAP (adapter installed via mason-nvim-dap: java-debug-adapter).
local M = {}

M.setup = function()
  local dap = require("dap")

  dap.configurations.java = {
    {
      type = "java",
      request = "launch",
      name = "Launch main class",
      mainClass = function()
        return vim.fn.input("Main class > ", "", "file")
      end,
    },
    {
      type = "java",
      request = "launch",
      name = "Debug current file",
      mainClass = "${file}",
    },
    {
      type = "java",
      request = "attach",
      name = "Attach to process",
      hostName = "127.0.0.1",
      port = function()
        return tonumber(vim.fn.input("Port > ", "5005"))
      end,
    },
  }
end

return M
