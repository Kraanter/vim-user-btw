local M = {}

M.map = function(mode, lhs, rhs, desc, extra)
    local opts = { noremap = true, silent = true, desc = desc }
    if extra then
        opts = vim.tbl_extend("force", opts, extra)
    end
    vim.keymap.set(mode, lhs, rhs, opts)
end

return M
