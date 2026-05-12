---@type opencode.Opts
vim.g.opencode_opts = {}

vim.o.autoread = true

vim.keymap.set({ "n", "x" }, "<C-a>", function()
    require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode..." })

vim.keymap.set({ "n", "x" }, "<C-x>", function()
    require("opencode").select()
end, { desc = "Execute opencode action..." })

vim.keymap.set({ "n", "t" }, "<C-.>", function()
    require("opencode").toggle()
end, { desc = "Toggle opencode" })

vim.keymap.set({ "n", "x" }, "go", function()
    return require("opencode").operator("@this ")
end, { desc = "Add range to opencode", expr = true })

vim.keymap.set("n", "goo", function()
    return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line to opencode", expr = true })

vim.keymap.set("n", "<S-C-u>", function()
    require("opencode").command("session.half.page.up")
end, { desc = "Scroll opencode up" })

vim.keymap.set("n", "<S-C-d>", function()
    require("opencode").command("session.half.page.down")
end, { desc = "Scroll opencode down" })

vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

local _99 = require("99")

_99.setup({
    provider = _99.OpenCodeProvider,
})

vim.keymap.set("v", "<leader>9v", function()
    _99.visual()
end, { noremap = true, silent = true, desc = "99: Visual request" })

vim.keymap.set("v", "<leader>9s", function()
    _99.stop_all_requests()
end, { noremap = true, silent = true, desc = "99: Stop all requests" })
