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

require("nvim-treesitter.configs").setup({
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
})

require("treesitter-context").setup({
    enable = true,
    multiwindow = false,
    max_lines = 0,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 20,
    trim_scope = "outer",
    mode = "cursor",
    separator = nil,
    zindex = 20,
    on_attach = nil,
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

require("render-markdown").setup({
    completions = { lsp = { enabled = true } },
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
