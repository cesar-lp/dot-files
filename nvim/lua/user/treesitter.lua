local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
	vim.notify("Error requiring treesitter")
	return
end

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	vim.notify("Error requiring nvim-treesitter.configs")
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
