local function setup_extensions()
  local dap, neodev, dap_ui, dap_vt = require "dap", require "neodev", require "dapui", require "nvim-dap-virtual-text"
  local stackmap = require 'stackmap'

  --[[ vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg = 0, fg = '#993939', bg = '#31353f' }) ]]
  --[[ vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg = 0, fg = '#61afef', bg = '#31353f' }) ]]
  --[[ vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' }) ]]

  vim.api.nvim_set_hl(0, "DapBlue", { fg = "#3d59a1" })
  vim.api.nvim_set_hl(0, "DapGreen", { fg = "#9ece6a" })
  vim.api.nvim_set_hl(0, "DapYellow", { fg = "#FFFF00" })
  vim.api.nvim_set_hl(0, "DapOrange", { fg = "#f09000" })
  vim.api.nvim_set_hl(0, "DapLightBlue", { fg = "#2A9FB4" })

  vim.fn.sign_define("DapBreakpoint", { text = "➤", texthl = "DapGreen", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
  vim.fn.sign_define("DapStopped", { text = "➤", texthl = "DapOrange", linehl = "DapOrange", numhl = "DapOrange" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "•", texthl = "DapBlue", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "•", texthl = "DapOrange", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
  vim.fn.sign_define("DapLogPoint", { text = "•", texthl = "DapYellow", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })

  dap_vt.setup()
  dap_ui.setup()

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dap_ui.open()

    -- TODO: change colors of TODO text
    stackmap.push("debugging_shortcuts", "n", {
      ["@"] = ":lua require 'dap'.step_over()<cr>",
      ["#"] = ":lua require 'dap'.step_into()<cr>",
      ["$"] = ":lua require 'dap'.step_out()<cr>"
    })

--[[ vim.keymap.set("n", "<F5>", ":lua require 'dap'.continue()<cr>") ]]
--[[ vim.keymap.set("n", "<leader>b", ":lua require 'dap'.toggle_breakpoint()<cr>") ]]
--[[ vim.keymap.set("n", "<leader>B", ":lua require 'dap'.set_breakpoint(vim.fn.input('Breakpoint conidition: '))<cr>") ]]
--[[ vim.keymap.set("n", "<leader>lp", ":lua require 'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>") ]]
--[[ vim.keymap.set("n", "<leader>dr", ":lua require 'dap'.repl.open()<cr>") ]]
  end

  dap.listeners.before.event_terminated["dapui_config"] = function()
    stackmap.pop("debugging_shortcuts", "n")
    dap_ui.close()
  end

  dap.listeners.before.event_exited["dapui_config"] = function()
    stackmap.pop("debugging_shortcuts", "n")
    dap_ui.close()
  end

  neodev.setup({
    library = {
      plugins = {
        "nvim-dap-ui"
      },
      types = true
    }
  })
end

local function setup_debuggers()
  -- Mason-nvim-dap first so adapters (js-debug, java-debug) are installed/registered
  require("user.dap.mason").setup()
  require("user.dap.adapters").setup()
  require("user.dap.rust").setup()
  require("user.dap.go").setup()
  require("user.dap.ts").setup()
  require("user.dap.java").setup()
  require("user.dap.kotlin").setup()
end

local function setup()
  setup_extensions()
  setup_debuggers()
end

setup()
