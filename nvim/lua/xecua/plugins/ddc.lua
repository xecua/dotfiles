-- lua_add {{{
vim.keymap.set({ "i", "c" }, "<Tab>", function()
    if vim.fn["denippet#jumpable"](1) then
        return "<Plug>(denippet-jump-next)"
    elseif vim.fn["pum#visible"]() then
        return "<Cmd>call pum#map#insert_relative(1)<CR>"
    end
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
    if string.match(current_char, "^%s*$") ~= nil then
        return "<Tab>"
    end
    return vim.fn["ddc#map#manual_complete"]()
end, {
    expr = true,
    desc = "Select next entry or start completion. At the head of line, feed <tab>",
})
vim.keymap.set({ "i", "c" }, "<S-Tab>", function()
    if vim.fn["denippet#jumpable"](-1) then
        return "<Plug>(denippet-jump-prev)"
    elseif vim.fn["pum#visible"]() then
        return "<Cmd>call pum#map#insert_relative(-1)<CR>"
    end
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
    if string.match(current_char, "^%s*$") ~= nil then
        return "<C-h>"
    end
    return vim.fn["ddc#map#manual_complete"]()
end, { expr = true, desc = "Select previous entry, or feed <C-h>" })

vim.keymap.set({ "i", "c" }, "<C-n>", function()
    if vim.fn["pum#visible"]() then
        vim.fn["pum#map#insert_relative"](1, "loop")
    else
        vim.fn["ddc#map#manual_complete"]()
    end
end, { desc = "Select next entry or start completion" })
vim.keymap.set({ "i", "c" }, "<C-p>", function()
    if vim.fn["pum#visible"]() then
        vim.fn["pum#map#insert_relative"](-1, "loop")
    else
        vim.fn["ddc#map#manual_complete"]()
    end
end, { desc = "Select previous entry or start completion" })
vim.keymap.set({ "i", "c" }, "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
vim.keymap.set({ "i", "c" }, "<C-c>", "<Cmd>call pum#map#cancel()<CR>")
-- }}}

-- lua_source {{{
vim.lsp.config("*", {
    capabilities = require("ddc_source_lsp").make_client_capabilities(),
})
vim.fn["ddc#custom#patch_global"]({
    ui = "pum",
    sources = {
        "lsp",
        "file",
        "around",
        "denippet",
    },
    sourceOptions = {
        _ = {
            matchers = { "matcher_fuzzy" },
            sorters = { "sorter_fuzzy" },
            converters = { "converter_fuzzy" },
            ignoreCase = true,
        },
        around = { mark = "A" },
        denippet = {
            mark = "snip",
            dup = "keep",
            matchers = { "matcher_head" },
            sorters = { "sorter_rank" },
            converters = {},
        },
        lsp = {
            mark = "LSP",
            dup = "keep",
            sorters = { "sorter_fuzzy", "sorter_lsp-kind" },
            forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
            isVolatile = true,
        },
        file = {
            mark = "file",
            forceCompletionPattern = [[\S/\S*]],
        },
        cmdline = {
            mark = "cmd",
            forceCompletionPattern = [[\S\s*]],
        },
        ["cmdline-history"] = {
            mark = "cmd-hist",
            matchers = { "matcher_head" },
            sorters = { "sorter_rank" },
            converters = {},
        },
        input = { mark = "input", isVolatile = true },
        line = { mark = "line" },
        skkeleton = {
            mark = "skk",
            matchers = {},
            sorters = {},
            converters = {},
            minAutoCompleteLength = 1,
            isVolatile = true,
        },
    },
    sourceParams = {
        lsp = {
            snippetEngine = vim.fn["denops#callback#register"](function(body)
                vim.fn["denippet#anonymous"](body)
            end),
            enableResolveItem = true,
            enableAdditionalTextEdit = true,
            confirmBehavior = "replace",
        },
    },
    autoCompleteEvents = { "InsertEnter", "TextChangedI", "TextChangedP", "CmdlineChanged" },
    cmdlineSources = {
        [":"] = { "cmdline", "cmdline_history", "around" },
        ["@"] = { "cmdline_history", "input", "file", "around" },
        [">"] = { "cmdline_history", "input", "file", "around" },
        ["/"] = { "around", "line" },
        ["?"] = { "around", "line" },
        ["-"] = { "around", "line" },
        ["="] = { "input" },
    },
})

-- ddc-file (windows)
vim.fn["ddc#custom#patch_filetype"]({ "ps1", "dosbatch", "autohotkey", "registry" }, {
    sourceOptions = {
        file = {
            forceCompletionPattern = [[\S\\\S*]],
        },
    },
    sourceParams = {
        file = {
            mode = "win32",
        },
    },
})

-- skkeletonが有効なときはそれだけをsourceに
vim.api.nvim_create_autocmd("User", {
    pattern = "skkeleton-enable-pre",
    callback = function()
        vim.fn["ddc#custom#patch_buffer"]("sources", { "skkeleton" })
    end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "skkeleton-disable-pre",
    callback = function()
        vim.fn["ddc#custom#patch_buffer"]("sources", { "lsp", "file", "around", "denippet" })
    end,
})

vim.keymap.set({ "n", "v" }, ":", function()
    vim.fn["pum#set_option"]({
        reversed = true,
        direction = "above",
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "DDCCmdlineLeave",
        once = true,
        callback = function()
            vim.fn["pum#set_option"]({
                reversed = false,
                direction = "auto",
            })
        end,
    })

    vim.fn["ddc#enable_cmdline_completion"]()
    return ":"
end, { expr = true })

vim.fn["ddc#enable"]({ context_filetype = "treesitter" })
-- }}}
