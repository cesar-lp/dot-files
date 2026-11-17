local status_ok, ufo = pcall(require, "ufo")
if not status_ok then
  vim.notify("Error requiring nvim-ufo")
  return
end

-- foldcolumn, foldlevel, foldlevelstart and foldenable are set in user.options,
-- so they apply from startup even though ufo loads with the first file.

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)

-- Only depend on `nvim-treesitter/queries/filetype/folds.scm`,
-- performance and stability are better than `foldmethod=nvim_treesitter#foldexpr()`
ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    return {'treesitter', 'indent'}
  end
})
--
