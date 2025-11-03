-- ============================================================================
-- Core options
-- ============================================================================
local opt, g, api = vim.opt, vim.g, vim.api

-- Leader keys must be set before mappings
g.mapleader = " "
g.maplocalleader = " "

-- Options (single source of truth)
local options = {
    number = true,
    relativenumber = true,
    signcolumn = "yes",
    wrap = true,
    breakindent = true,
    cursorline = true,
    colorcolumn = "80",
    scrolloff = 10,

    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,
    expandtab = true,

    swapfile = false,
    undofile = true,

    ignorecase = true,
    smartcase = true,
    inccommand = "split",

    list = true,
    -- whitespace guides
    listchars = { tab = "» ", trail = "·", nbsp = "␣" },

    -- modern QoL
    mouse = "a",
    termguicolors = true,
    splitright = true,
    splitbelow = true,
    confirm = true,
    updatetime = 200,
    timeoutlen = 400,

    -- popup transparency (keep; works with many UIs)
    winblend = 0,
    pumblend = 0,
}

for k, v in pairs(options) do
    opt[k] = v
end

-- Clipboard (no need to schedule)
opt.clipboard = "unnamedplus"

-- Persist more session state
opt.sessionoptions = {
    "blank", "buffers", "curdir", "folds", "help", "tabpages", "winsize",
    "winpos", "terminal", "localoptions",
}

-- ============================================================================
-- UI polish: borders, diagnostics
-- ============================================================================
vim.diagnostic.config({
    float = { border = "rounded" },
    severity_sort = true,
    virtual_text = {
        spacing = 2,
        prefix = "●",
    },
    underline = true,
    update_in_insert = false,
})

-- Ensure all floating windows (LSP, help, etc.) use rounded borders
-- (works for hover, signature, etc.)
local orig = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, syntax, opts, ...)
end

-- ============================================================================
-- Keymaps
-- ============================================================================
local map = function(mode, lhs, rhs, desc, extra)
    local opts = { noremap = true, silent = true, desc = desc }
    if extra then opts = vim.tbl_extend("force", opts, extra) end
    vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>o", "<cmd>update|source %<CR>", "Save & Source current file")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- mini.pick (Telescope replacement)
map("n", "<leader>f", "<cmd>Pick files<CR>", "Find files")
map("n", "<leader>b", "<cmd>Pick buffers<CR>", "Find buffers")
map("n", "<leader>g", "<cmd>Pick grep_live<CR>", "Live grep")
map("n", "<leader>h", "<cmd>Pick help<CR>", "Help tags")
map('n', '<leader>sd', "<cmd>Pick lsp scope='document_symbol'<CR>", 'LSP document symbols')
map('n', '<leader>ss', "<cmd>Pick lsp scope='workspace_symbol'<CR>", 'LSP workspace symbols')

-- Oil
map("n", "<leader>e", "<cmd>Oil<CR>", "File explorer (Oil)")

-- Transparency
map("n", "<leader>t", "<cmd>TransparentToggle<CR>", "Toggle transparency")

-- Harpoon
map("n", "<leader>a", function() require("harpoon"):list():add() end, "Harpoon add file")
map("n", "<C-e>", function()
    local h = require("harpoon")
    h.ui:toggle_quick_menu(h:list())
end, "Harpoon menu")
map("n", "<C-j>", function() require("harpoon"):list():select(1) end, "Harpoon 1")
map("n", "<C-k>", function() require("harpoon"):list():select(2) end, "Harpoon 2")
map("n", "<C-l>", function() require("harpoon"):list():select(3) end, "Harpoon 3")
map("n", "<C-;>", function() require("harpoon"):list():select(4) end, "Harpoon 4")
map("n", "<C-S-P>", function() require("harpoon"):list():prev() end, "Harpoon prev")
map("n", "<C-S-N>", function() require("harpoon"):list():next() end, "Harpoon next")

-- ============================================================================
-- Autocmds
-- ============================================================================
api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function() vim.highlight.on_yank({ higroup = "Visual", timeout = 120 }) end,
})

-- ============================================================================
-- Plugins (Neovim pack.lua)
-- ============================================================================
vim.pack.add({
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/xiyaowong/transparent.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/echasnovski/mini.pick" },
    { src = "https://github.com/echasnovski/mini.extra" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/Saghen/blink.cmp",            version = "v1.7.0" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/rmagatti/auto-session" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/theprimeagen/harpoon",        version = "harpoon2" },
})

-- ============================================================================
-- LSP
-- ============================================================================
-- Prefer the new helper when available; otherwise basic lspconfig fallback
if vim.lsp and vim.lsp.enable then
    vim.lsp.enable({ "lua_ls", "ts_ls", "gopls", "intelephense", "rust_analyzer" })
else
    local lsp = require("lspconfig")
    local servers = { lua_ls = {}, tsserver = {}, gopls = {}, intelephense = {} }
    for name, cfg in pairs(servers) do
        if lsp[name] then lsp[name].setup(cfg) end
    end
end

-- Buffer-local LSP mappings on attach
api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(ev)
        local buf = ev.buf
        local bmap = function(mode, lhs, rhs, desc)
            map(mode, lhs, rhs, desc, { buffer = buf })
        end

        bmap("n", "K", vim.lsp.buf.hover, "Hover")
        -- Navigation
        bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        bmap("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
        bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        bmap("n", "gr", vim.lsp.buf.references, "List references")
        -- Code
        bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        bmap("n", "<leader>lf", function()
            local ft = vim.bo[buf].filetype
            if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" then
                vim.cmd("silent! Prettier")
            else
                vim.lsp.buf.format({ async = true })
            end
        end, "Format buffer")
        -- Diagnostics
        bmap("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
        bmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        bmap("n", "<leader>q", vim.diagnostic.setloclist, "Populate loclist")
        -- Symbols
        bmap("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
        bmap("n", "<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
        -- Sig help
        bmap("n", "<leader>lh", vim.lsp.buf.signature_help, "Signature help")

        -- Enable omnifunc for completion
        vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end,
})

-- ============================================================================
-- Completion & snippets
-- ============================================================================
require("blink.cmp").setup({
    snippets = { preset = "luasnip" },
})
require("luasnip.loaders.from_vscode").lazy_load()

-- ============================================================================
-- Tools
-- ============================================================================
require("mini.pick").setup({
    source = {
        grep_live = {
            command = { 'rg', '--vimgrep', '--no-heading', '--smart-case' },
        },
    },
})
require("mini.extra").setup()
require("oil").setup({})
require("auto-session").setup({})
require("gitsigns").setup({
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text_pos = 'right_align',
        delay = 0,
    },
})

-- ============================================================================
-- Theme
-- ============================================================================
vim.cmd.colorscheme("rose-pine-moon")
require("transparent").setup({
    -- keep your existing config; add these to exclusions
    exclude_groups = {
        "NormalFloat", "FloatBorder", "Pmenu", "PmenuSel",
        -- mini.pick groups (catch-all; harmless if some don’t exist)
        "MiniPickNormal", "MiniPickBorder", "MiniPickPrompt",
        "MiniPickMatchCurrent", "MiniPickMatch", "MiniPickHeader",
    },
})

-- Get palette for current Rose Pine variant
local palette = require("rose-pine.palette")

-- Current selection in the picker
api.nvim_set_hl(0, "MiniPickMatchCurrent", { bg = palette.overlay, fg = palette.text, bold = true })
