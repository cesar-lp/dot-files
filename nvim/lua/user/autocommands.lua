local function autocmd(event, opts)
	vim.api.nvim_create_autocmd(event, opts)
end

local function augroup(event)
	return vim.api.nvim_create_augroup(event, { clear = true })
end

local filesPattern = { "*.lua", "*.js", "*.ts", "*.rs", "*.go", "*.json" }

-- Format on save
local autoFormattingGroup = augroup("FormatOnSave")
autocmd("BufWritePre", {
	group = autoFormattingGroup,
	pattern = filesPattern,
	callback = function()
		vim.lsp.buf.format {async = true }
	end,
})

-- -- Auto save
-- local autoSaveGrop = augroup("AutoSave")
-- autocmd({ "FocusLost", "BufEnter" }, {
-- 	group = autoSaveGrop,
-- 	pattern = filesPattern,
-- 	command = "silent update",
-- })

-- Auto resize
local autoResizeGroup = augroup("AutoResize")
autocmd("VimResized", { group = autoResizeGroup, command = "tabdo wincmd =_" })

-- GIT
local gitGroup = augroup("GIT")
autocmd("FileType", { pattern = { "gitcommit" }, group = gitGroup, command = "setlocal wrap" })
autocmd("FileType", { pattern = { "gitcommit" }, group = gitGroup, command = "setlocal spell" })

-- Markdown
local markdownGroup = augroup("Markdown")
autocmd("FileType", { pattern = { "markdown" }, group = markdownGroup, command = "setlocal wrap" })
autocmd("FileType", { pattern = { "markdown" }, group = markdownGroup, command = "setlocal spell" })
