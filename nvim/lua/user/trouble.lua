local ok, trouble = pcall(require, "trouble")
if not ok then
  vim.notify("Error requiring trouble")
  return
end

trouble.setup({
  win = {
    type = "split",
    position = "bottom",
    size = 15,
  },
})
