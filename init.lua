-- ============================================================================
-- Core options
-- ============================================================================
local opt, g, api = vim.opt, vim.g, vim.api

g.mapleader = " "
g.maplocalleader = " "

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
    listchars = { tab = "» ", trail = "·", nbsp = "␣" },

    mouse = "a",
    termguicolors = true,
    splitright = true,
    splitbelow = true,
    confirm = true,
    updatetime = 200,
    timeoutlen = 400,

    winblend = 0,
    pumblend = 0,
}

for k, v in pairs(options) do
    opt[k] = v
end

opt.clipboard = "unnamedplus"

opt.sessionoptions = {
    "blank",
    "buffers",
    "curdir",
    "folds",
    "help",
    "tabpages",
    "winsize",
    "winpos",
    "terminal",
    "localoptions",
}

-- ============================================================================
-- UI polish: borders, diagnostics
-- ============================================================================
vim.diagnostic.config({
    float = { border = "rounded" },
    severity_sort = true,
    virtual_text = { spacing = 2, prefix = "●" },
    underline = true,
    update_in_insert = false,
})

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
    if extra then
        opts = vim.tbl_extend("force", opts, extra)
    end
    vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>o", "<cmd>update|source %<CR>", "Save & Source current file")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- mini.pick (Telescope replacement)
map("n", "<leader>f", "<cmd>Pick files<CR>", "Find files")
map("n", "<leader>b", "<cmd>Pick buffers<CR>", "Find buffers")
map("n", "<leader>g", "<cmd>Pick grep_live<CR>", "Live grep")
map("n", "<leader>h", "<cmd>Pick help<CR>", "Help tags")
map("n", "<leader>sd", "<cmd>Pick lsp scope='document_symbol'<CR>", "LSP document symbols")
map("n", "<leader>ss", "<cmd>Pick lsp scope='workspace_symbol'<CR>", "LSP workspace symbols")

-- Oil
map("n", "<leader>e", "<cmd>Oil --preview<CR>", "File explorer (Oil)")

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
    callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 120 })
    end,
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
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/prettier/vim-prettier" },

    { src = "https://github.com/hrsh7th/nvim-cmp" },
    { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "https://github.com/hrsh7th/cmp-buffer" },
    { src = "https://github.com/hrsh7th/cmp-path" },
    { src = "https://github.com/saadparwaiz1/cmp_luasnip" },

    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/theprimeagen/harpoon",                   version = "harpoon2" },
    { src = "https://github.com/ThePrimeagen/99" },
    { src = "https://github.com/jackplus-xyz/monaspace.nvim" },
})

-- ============================================================================
-- mini.pick -> quickfix helper (inline, no extra file needed)
-- ============================================================================
local function pick_send_to_qflist()
    local pick = require("mini.pick")

    local state = pick.get_picker_state()
    if not state then
        return
    end

    local matches = pick.get_picker_matches()
    if not matches then
        return
    end

    local items = (matches.marked and #matches.marked > 0) and matches.marked or matches.all
    if not items or #items == 0 then
        return
    end

    local qf = {}
    for _, item in ipairs(items) do
        local file, lnum, col, text = item:match("^(.-)%z(.-)%z(.-)%z(.*)$")
        if file and lnum and col then
            table.insert(qf, {
                filename = file,
                lnum = tonumber(lnum) or 1,
                col = tonumber(col) or 1,
                text = (text or ""):gsub("^%s+", ""),
            })
        end
    end

    vim.fn.setqflist(qf, "r")
    vim.cmd("copen")
end

-- ============================================================================
-- LSP
-- ============================================================================
local vue_language_server_path = "~/.bun/bin/vue-language-server"
local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
    name = "@vue/typescript-plugin",
    location = vue_language_server_path,
    languages = { "vue" },
    configNamespace = "typescript",
}
local ts_ls_config = {
    init_options = {
        plugins = { vue_plugin },
    },
    filetypes = tsserver_filetypes,
}

vim.lsp.enable({
    "lua_ls",
    "gopls",
    "intelephense",
    "rust_analyzer",
    "jsonls",
    "html",
    "cssls",
    "tailwind",
    "tailwindcss-language-server",
})
vim.lsp.config("vue_ls", {})
vim.lsp.config("ts_ls", ts_ls_config)
vim.lsp.enable({ "ts_ls", "vue_ls" })

api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(ev)
        local buf = ev.buf
        local bmap = function(mode, lhs, rhs, desc)
            map(mode, lhs, rhs, desc, { buffer = buf })
        end

        bmap("n", "K", vim.lsp.buf.hover, "Hover")
        bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        bmap("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
        bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        bmap("n", "gr", vim.lsp.buf.references, "List references")

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

        bmap("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
        bmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        bmap("n", "<leader>q", vim.diagnostic.setloclist, "Populate loclist")

        bmap("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
        bmap("n", "<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
        bmap("n", "<leader>lh", vim.lsp.buf.signature_help, "Signature help")

        vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    end,
})

-- ============================================================================
-- Completion & snippets (nvim-cmp + LuaSnip)
-- ============================================================================
local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    }),
})

-- ============================================================================
-- 99 setup (OpenCode + cmp completion)
-- ============================================================================
local _99 = require("99")

local cwd = vim.uv.cwd()
local basename = vim.fs.basename(cwd)

_99.setup({
    provider = _99.OpenCodeProvider, -- default, but explicit

    logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
    },

    --- Completions: #rules and @files in the prompt buffer (requires nvim-cmp)
    completion = {
        custom_rules = {
            "scratch/custom_rules/",
        },
        files = {
            -- enabled = true,
            -- max_file_size = 102400,
            -- max_files = 5000,
            -- exclude = { ".env", ".env.*", "node_modules", ".git" },
        },
        source = "cmp",
    },

    md_files = {
        "AGENT.md",
    },
})

vim.keymap.set("v", "<leader>9v", function()
    _99.visual()
end, { noremap = true, silent = true, desc = "99: Visual request" })

vim.keymap.set("v", "<leader>9s", function()
    _99.stop_all_requests()
end, { noremap = true, silent = true, desc = "99: Stop all requests" })

-- ============================================================================
-- Tools
-- ============================================================================
require("nvim-treesitter.configs").setup({
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
})

require 'treesitter-context'.setup({
    enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
    multiwindow = false,      -- Enable multiwindow support.
    max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 20, -- Maximum number of lines to show for a single context
    trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
    zindex = 20,     -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})

require("mini.pick").setup({
    source = {
        grep_live = {
            command = { "rg", "--vimgrep", "--no-heading", "--smart-case" },
        },
    },
    mappings = {
        send_to_qf = {
            char = "<C-q>",
            func = pick_send_to_qflist,
        },
    },
})

require("mini.extra").setup()

require("oil").setup({
    watch_for_changes = true,
})

require("gitsigns").setup({
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text_pos = "right_align",
        delay = 0,
    },
})

-- ============================================================================
-- Theme
-- ============================================================================
vim.cmd.colorscheme("rose-pine-moon")

require("monaspace").setup({
    use_default = false,

    style_map = {
        italic = {
            Comment = true,
            Todo = true,
            SpecialComment = true,
            ["@comment"] = true,
            ["@comment.documentation"] = true,
            ["@comment.error"] = true,
            ["@comment.warning"] = true,
            ["@comment.todo"] = true,
            ["@comment.hint"] = true,
            ["@comment.info"] = true,
            ["@comment.note"] = true,
            ["@string.documentation"] = true,
            LspCodeLens = true,
            LspInlayHint = true,
            ["@lsp.type.comment"] = true,
            ["@lsp.type.comment.c"] = true,
            ["@lsp.type.comment.cpp"] = true,
            ["@markup.heading"] = true,
            ["@markup.heading.1.markdown"] = true,
            ["@markup.heading.2.markdown"] = true,
            ["@markup.heading.3.markdown"] = true,
            ["@markup.heading.4.markdown"] = true,
            ["@markup.heading.5.markdown"] = true,
            ["@markup.heading.6.markdown"] = true,
            ["@markup.heading.1.marker.markdown"] = true,
            ["@markup.heading.2.marker.markdown"] = true,
            ["@markup.heading.3.marker.markdown"] = true,
            ["@markup.heading.4.marker.markdown"] = true,
            ["@markup.heading.5.marker.markdown"] = true,
            ["@markup.heading.6.marker.markdown"] = true,
            markdownH1 = true,
            markdownH2 = true,
            markdownH3 = true,
            markdownH4 = true,
            markdownH5 = true,
            markdownH6 = true,
            markdownH1Delimiter = true,
            markdownH2Delimiter = true,
            markdownH3Delimiter = true,
            markdownH4Delimiter = true,
            markdownH5Delimiter = true,
            markdownH6Delimiter = true,
        },
        bold = {
            markdownUrl = true,
            htmlLink = true,
            ["@markup.italic"] = true,
            ["@markup.quote"] = true,
            ["@string.special.url"] = true,
            ["@string.special.path"] = true,
            ["@markup.link"] = true,
            ["@markup.link.url"] = true,
            ["@markup.link.markdown_inline"] = true,
            ["@markup.link.label.markdown_inline"] = true,
            mkdInlineURL = true,
            mkdLink = true,
            mkdURL = true,
            mkdLinkDef = true,
            markdownLinkText = true,
            ["@markup.math"] = true,
            ["@markup.environment"] = true,
            ["@markup.environment.name"] = true,
        },
        bold_italic = {
            DiagnosticError = true,
            DiagnosticHint = true,
            DiagnosticInfo = true,
            DiagnosticOk = true,
            DiagnosticWarn = true,
            DiagnosticDefaultError = true,
            DiagnosticDefaultHint = true,
            DiagnosticDefaultInfo = true,
            DiagnosticDefaultOk = true,
            DiagnosticDefaultWarn = true,
            DiagnosticFloatingError = true,
            DiagnosticFloatingHint = true,
            DiagnosticFloatingInfo = true,
            DiagnosticFloatingOk = true,
            DiagnosticFloatingWarn = true,
            DiagnosticSignError = true,
            DiagnosticSignHint = true,
            DiagnosticSignInfo = true,
            DiagnosticSignOk = true,
            DiagnosticSignWarn = true,
            DiagnosticUnderlineError = true,
            DiagnosticUnderlineHint = true,
            DiagnosticUnderlineInfo = true,
            DiagnosticUnderlineOk = true,
            DiagnosticUnderlineWarn = true,
            DiagnosticVirtualTextError = true,
            DiagnosticVirtualTextHint = true,
            DiagnosticVirtualTextInfo = true,
            DiagnosticVirtualTextOk = true,
            DiagnosticVirtualTextWarn = true,
            ErrorMsg = true,
            WarningMsg = true,
            ModeMsg = true,
            MoreMsg = true,
            Question = true,
            RedrawDebugNormal = true,
            RedrawDebugClear = true,
            RedrawDebugComposed = true,
            RedrawDebugRecompose = true,
            healthError = true,
            healthSuccess = true,
            healthWarning = true,
            NvimInternalError = true,
            FloatTitle = true,
            WinBar = true,
            WinBarNC = true,
            StatusLine = true,
            StatusLineNC = true,
            StatusLineTerm = true,
            StatusLineTermNC = true,
        },
    }
})

require("transparent").setup({
    exclude_groups = {
        "NormalFloat",
        "FloatBorder",
        "Pmenu",
        "PmenuSel",
        "MiniPickNormal",
        "MiniPickBorder",
        "MiniPickPrompt",
        "MiniPickMatchCurrent",
        "MiniPickMatch",
        "MiniPickHeader",
    },
})

local palette = require("rose-pine.palette")
api.nvim_set_hl(0, "MiniPickMatchCurrent", { bg = palette.overlay, fg = palette.text, bold = true })
