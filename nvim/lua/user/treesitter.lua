local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  -- Plugin not installed yet (run :Lazy sync) or not loaded
  return
end

configs.setup({
	ensure_installed = {"rust", "lua", "typescript", "javascript", "kotlin"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
	ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
	autopairs = {
		enable = true,
	},
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "css" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = true,
	},
	indent = { enable = true, disable = { "css", "python", "yaml" } },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})
