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
