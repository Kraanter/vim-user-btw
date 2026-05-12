local api = vim.api
local map = require("config.utils").map

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
