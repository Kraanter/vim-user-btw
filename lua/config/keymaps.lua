local map = require("config.utils").map

map("n", "<leader>o", "<cmd>update|source %<CR>", "Save & Source current file")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

map("n", "<leader>f", "<cmd>Pick files<CR>", "Find files")
map("n", "<leader>b", "<cmd>Pick buffers<CR>", "Find buffers")
map("n", "<leader>g", "<cmd>Pick grep_live<CR>", "Live grep")
map("n", "<leader>h", "<cmd>Pick help<CR>", "Help tags")
map("n", "<leader>sd", "<cmd>Pick lsp scope='document_symbol'<CR>", "LSP document symbols")
map("n", "<leader>ss", "<cmd>Pick lsp scope='workspace_symbol'<CR>", "LSP workspace symbols")

map("n", "<leader>e", "<cmd>Oil --preview<CR>", "File explorer (Oil)")
map("n", "<leader>t", "<cmd>TransparentToggle<CR>", "Toggle transparency")

map("n", "<leader>p", "<cmd>AtlasPulls github<CR>", "Atlas GitHub PRs")
map("n", "<leader>i", "<cmd>AtlasIssues github<CR>", "Atlas GitHub issues")
map("n", "<leader>S", "<cmd>AtlasSearch github<CR>", "Atlas GitHub search")
map("n", "<leader>P", "<cmd>AtlasCreatePR<CR>", "Atlas create PR")
map("n", "<leader>I", "<cmd>AtlasCreateIssue<CR>", "Atlas create issue")

map("n", "<leader>a", function()
    require("harpoon"):list():add()
end, "Harpoon add file")

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
