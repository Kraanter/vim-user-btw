vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = true
vim.o.tabstop = 4
vim.o.swapfile = false
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.winborder = "none"
vim.o.breakindent = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.colorcolumn = "80"

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'
vim.o.list = true

vim.schedule(function()
	vim.opt.clipboard = 'unnamedplus'
end)

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.keymap.set('n', '<leader>o', '<cmd>update<CR><cmd>source<CR>')
vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<CR>')

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim" },
	{ src = "https://github.com/xiyaowong/transparent.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/Saghen/blink.cmp",            version = "v1.7.0" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/rmagatti/auto-session" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/theprimeagen/harpoon",        version = "harpoon2" },
})

-- LSP setup
vim.lsp.enable({ "lua_ls", "ts_ls", "gopls", "intelephense" })

-- Telescope replacement
require("mini.pick").setup()
vim.ui.select = function(items, opts, on_choice)
	require "mini.pick".ui_select(items, opts, on_choice)
end
vim.keymap.set('n', '<leader>f', "<cmd>Pick files<CR>")
vim.keymap.set('n', '<leader>g', "<cmd>Pick grep_live<CR>")
vim.keymap.set('n', '<leader>h', "<cmd>Pick help<CR>")

-- Setup LSP keymaps only when a language server attaches
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(ev)
		local buf = ev.buf
		local opts = { buffer = buf, silent = true, noremap = true }

		-- Helper function for easier keymap definition
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs)
		end

		-- === NAVIGATION ===
		map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
		map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
		map('n', 'gt', vim.lsp.buf.type_definition, 'Go to type definition')
		map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
		map('n', 'gr', vim.lsp.buf.references, 'List references')

		-- === CODE ACTIONS ===
		map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
		map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
		map('n', '<leader>lf', function()
			local ft = vim.bo.filetype

			-- Run :Prettier for JavaScript or TypeScript files
			if ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact' then
				vim.cmd('Prettier')
			else
				vim.lsp.buf.format { async = true }
			end
		end, 'Format buffer')

		-- === DIAGNOSTICS ===
		map('n', 'gl', vim.diagnostic.open_float, 'Show diagnostics')
		map('n', '[d', vim.diagnostic.goto_prev, 'Prev diagnostic')
		map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')
		map('n', '<leader>q', vim.diagnostic.setloclist, 'Diagnostics list')

		-- === SYMBOLS ===
		map('n', '<leader>ds', vim.lsp.buf.document_symbol, 'Document symbols')
		map('n', '<leader>ws', vim.lsp.buf.workspace_symbol, 'Workspace symbols')

		-- === MISC ===
		map('n', '<leader>lh', vim.lsp.buf.signature_help, 'Signature help')

		-- === COMPLETION (optional) ===
		vim.opt_local.omnifunc = 'v:lua.vim.lsp.omnifunc'
	end,
})

-- Autocomplete
require("blink.cmp").setup({
	snippets = { preset = "luasnip" },
})
require "luasnip.loaders.from_vscode".lazy_load()

-- Filesystem editing
require "oil".setup()
vim.keymap.set('n', '<leader>e', "<cmd>Oil<CR>")

-- Session management per 'project'
require "auto-session".setup({})

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

vim.cmd("colorscheme rose-pine-moon")
vim.cmd(":hi StatusLine guibg=NONE")
