local opt, g = vim.opt, vim.g

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
