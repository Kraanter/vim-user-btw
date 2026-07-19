local map = require("config.utils").map

local function current_github_repo()
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()
    local root = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()

    if root.code ~= 0 then
        vim.notify("Not inside a git repository", vim.log.levels.WARN)
        return nil
    end

    local repo = vim.system({ "gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner" }, {
        cwd = vim.trim(root.stdout),
        text = true,
    }):wait()

    if repo.code ~= 0 then
        vim.notify(vim.trim(repo.stderr), vim.log.levels.WARN)
        return nil
    end

    return vim.trim(repo.stdout)
end

local function atlas_open_current_repo(domain)
    local repo = current_github_repo()
    if not repo then
        return
    end

    local is_pr = domain == "pulls"
    require("atlas").open(domain, "github", {
        initial_view = {
            name = "Current repo",
            layout = "compact",
            search = "repo:" .. repo .. (is_pr and " is:pr" or " is:issue"),
        },
    })
end

local function atlas_search_current_repo()
    local repo = current_github_repo()
    if not repo then
        return
    end

    require("atlas.pulls.providers.github.completion.search").open("repo:" .. repo .. " ")
end

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

map("n", "<leader>p", function() atlas_open_current_repo("pulls") end, "Atlas repo PRs")
map("n", "<leader>i", function() atlas_open_current_repo("issues") end, "Atlas repo issues")
map("n", "<leader>S", atlas_search_current_repo, "Atlas repo search")
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
