local ok, ibl = pcall(require, "ibl")
if not ok then
  vim.notify("Error requiring ibl (indent-blankline v3)")
  return
end

ibl.setup({
  indent = {
    char = "▏",
  },
  scope = {
    enabled = true,
    show_start = false,
  },
  exclude = {
    buftypes = { "terminal", "nofile" },
    filetypes = {
      "help",
      "startify",
      "dashboard",
      "NvimTree",
      "Trouble",
    },
  },
})
