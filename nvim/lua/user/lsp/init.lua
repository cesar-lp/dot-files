-- LSP: mason sets up servers via vim.lsp.config + vim.lsp.enable (Neovim 0.11+)
-- nvim-lspconfig is loaded by mason-lspconfig and populates vim.lsp.config
require "user.lsp.mason"
require("user.lsp.handlers").setup()
require "user.lsp.null-ls"

-- Loaded after startup (user.plugins defers it past the first frame): vim.lsp.enable already
-- attaches the servers to the buffers that are open; none-ls only attaches on FileType, so
-- attach it to them here.
if vim.v.vim_did_enter == 1 then
  local ok, null_ls_client = pcall(require, "null-ls.client")
  if ok then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
        null_ls_client.try_add(buf)
      end
    end
  end
end
