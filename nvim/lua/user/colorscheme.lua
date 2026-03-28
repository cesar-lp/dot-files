vim.cmd "colorscheme default"

--[[ local colorscheme = "tokyonight-storm" ]]
--[[ local colorscheme = "gruvbox-material" ]]
local colorscheme = "rose-pine-moon"
--[[ local colorscheme = "catppuccin-macchiato" ]]
--[[ local colorscheme = "kanagawa" ]]

-- Must run before `colorscheme` (see rose-pine.nvim README).
require("rose-pine").setup({
  highlight_groups = {
    -- Same pairing as Alacritty cursor: love (#eb6f92) + base text
    Visual = { fg = "base", bg = "love", inherit = false },
    VisualNOS = { fg = "base", bg = "love", inherit = false },
  },
})

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not status_ok then
  vim.notify("Error setting " .. colorscheme .. " theme")
  return
end
