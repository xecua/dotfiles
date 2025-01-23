-- lua_add {{{
-- vim.g.loaded_ddu_rg = 1 -- prevent command definition by plugin

vim.api.nvim_create_user_command("DduRgLive", function()
    vim.fn["ddu#start"]({
        sources = { { name = "rg", options = { volatile = true, matchers = {} } } },
        uiParams = { ff = { ignoreEmpty = false } },
    })
end, {})
vim.api.nvim_create_user_command("DduLspDocumentSymbol", function()
    vim.fn["ddu#start"]({
        sources = { { name = "lsp_documentSymbol" } },
        uiParams = { ff = { ignoreEmpty = false, displayTree = true } },
    })
end, {})
vim.api.nvim_create_user_command("DduLspWorkspaceSymbol", function()
    vim.fn["ddu#start"]({
        sources = { { name = "lsp_workspaceSymbol", options = { volatile = true } } },
        uiParams = { ff = { ignoreEmpty = false, displayTree = true } },
    })
end, {})
vim.keymap.set("n", "<Leader>fd", "<Cmd>Ddu file_external<CR>")
vim.keymap.set("n", "<Leader>fb", "<Cmd>Ddu buffer<CR>")
vim.keymap.set("n", "<Leader>ft", "<Cmd>Ddu deol<CR>")
vim.keymap.set("n", "<Leader>fg", "<Cmd>DduRgLive<CR>")
vim.keymap.set("n", "<Leader>fls", "<Cmd>DduLspDocumentSymbol<CR>")
vim.keymap.set("n", "<Leader>flw", "<Cmd>DduLspWorkspaceSymbol<CR>")

vim.api.nvim_create_user_command("DduFiler", function()
    vim.fn["ddu#start"]({
        ui = "filer",
        sources = { { name = "file" } },
        actionOptions = {
            narrow = { quit = false },
            open = { quit = false },
        },
    })
end, {})
-- vim.keymap.set("n", "<C-n>", "<Cmd>DduFiler<CR>")

local ddu_group_id = vim.api.nvim_create_augroup("DduMyCnf", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = ddu_group_id,
    pattern = "ddu-ff",
    callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<CR>", "<Cmd>call ddu#ui#do_action('itemAction')<CR>", opts)
        -- function()
        --     local item = vim.fn["ddu#ui#get_item"]()
        --     if item["__sourceName"] == "rg" then
        --       -- wincmd pだとpreviewに行ってしまうのでダメ
        --     end
        --     vim.fn["ddu#ui#do_action"]("itemAction")
        -- end, opts)
        vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
        vim.keymap.set("n", "/", "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
        vim.keymap.set("n", ",", "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
        vim.keymap.set("n", "t", "<Cmd>call ddu#ui#do_action('toggleAllItems')<CR>", opts)
        vim.keymap.set("n", "f", "<Cmd>call ddu#ui#do_action('itemAction', #{ name: 'quickfix' })<CR>", opts)
        vim.keymap.set("n", "h", "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
        vim.keymap.set("n", "l", "<Cmd>call ddu#ui#do_action('expandItem')<CR>", opts)
        vim.keymap.set("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)
    end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "Ddu:ui:ff:openFilterWindow",
    callback = function()
        vim.fn["pum#set_option"]({
            reversed = true,
            direction = "above",
        })
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "Ddu:ui:ff:closeFilterWindow",
    callback = function()
        vim.fn["pum#set_option"]({
            reversed = false,
            direction = "auto",
        })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = ddu_group_id,
    pattern = "ddu-filer",
    callback = function()
        -- TODO: 開いたときに現在のファイルにカーソルが移動するやつとウィンドウ選んでファイルを開けるやつ
        vim.opt_local.number = true
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
        vim.keymap.set("n", "h", "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
        vim.keymap.set("n", "d", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'trash' })<CR>", opts)
        vim.keymap.set("n", "N", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'newFile' })<CR>", opts)
        vim.keymap.set("n", "K", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'newDirectory' })<CR>", opts)
        vim.keymap.set("n", "R", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'rename' })<CR>", opts)
        vim.keymap.set("n", "y", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'yank' })<CR>", opts)
        vim.keymap.set("n", "p", "<Cmd>call ddu#ui#do_action('itemAction', #{name: 'paste' })<CR>", opts)

        vim.keymap.set("n", "s", function()
            if not vim.fn["ddu#ui#get_item"]()["isTree"] then
                vim.fn["ddu#ui#do_action"](
                    "itemAction",
                    { name = "open", params = { command = "wincmd p|wincmd s|drop" } }
                )
            end
        end, opts)
        vim.keymap.set("n", "v", function()
            if not vim.fn["ddu#ui#get_item"]()["isTree"] then
                vim.fn["ddu#ui#do_action"](
                    "itemAction",
                    { name = "open", params = { command = "wincmd p|wincmd v|drop" } }
                )
            end
        end, opts)
        vim.keymap.set("n", "t", function()
            if not vim.fn["ddu#ui#get_item"]()["isTree"] then
                vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "tab drop" } })
            end
        end, opts)
        vim.keymap.set("n", "l", function()
            if vim.fn["ddu#ui#get_item"]()["isTree"] then
                vim.fn["ddu#ui#do_action"]("expandItem", { isInTree = true })
            else
                vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
            end
        end, opts)
        vim.keymap.set("n", "<LeftRelease>", function()
            local item = vim.fn["ddu#ui#get_item"]()
            if item["isTree"] and item["__expanded"] then
                vim.fn["ddu#ui#do_action"]("collapseItem")
            elseif item["isTree"] then
                vim.fn["ddu#ui#do_action"]("expandItem", { isInTree = true })
            else
                vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
            end
        end, opts)

        vim.keymap.set("n", "<CR>", function()
            if vim.fn["ddu#ui#get_item"]()["isTree"] then
                vim.fn["ddu#ui#do_action"]("itemAction", { name = "narrow" })
            else
                vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
            end
        end, opts)

        vim.keymap.set(
            "n",
            "<BS>",
            "<Cmd>call ddu#ui#do_action('itemAction', #{ name: 'narrow', params: #{ path: '..' } })<CR>",
            opts
        )

        vim.keymap.set("n", "!", function()
            -- これdocに記載されてるやり方だから↑のヒントになりそう
            local current = vim.fn["ddu#custom#get_current"](vim.b.ddu_ui_name)
            local matchers = ((current["sourceOptions"] or {})["file"] or {})["matchers"] or {}
            if #matchers == 0 then
                matchers = { "matcher_hidden" }
            else
                matchers = {}
            end

            vim.print(current["sourceOptions"])

            vim.fn["ddu#ui#do_action"]("updateOptions", {
                sourceOptions = { file = { matchers = matchers } },
            })
            vim.fn["ddu#ui#do_action"]("redraw", { method = "refreshItems" })
        end, opts)
    end,
})

-- }}}

-- lua_source {{{
vim.fn["ddu#custom#alias"]("default", "column", "icon_filename_ff", "icon_filename")
vim.fn["ddu#custom#patch_global"]({
    ui = "ff",
    uiParams = {
        ff = {
            previewWidth = 80,
            previewSplit = "vertical",
            startAutoAction = true,
            statusline = false,
            autoAction = { name = "preview", sync = false },
        },
        filer = {
            split = "vertical",
            winWidth = vim.o.columns / 6,
        },
    },
    uiOptions = {
        filer = { toggle = true },
    },
    sourceParams = {
        file_external = { cmd = { "fd", ".", "-t", "f", "-H", "-E", ".git" } },
        rg = { args = { "--json" } },
    },
    sourceOptions = {
        _ = { matchers = { "matcher_fzf" }, sorters = { "sorter_fzf" } },
        file_external = { columns = { "icon_filename_ff" }, converters = { "converter_hl_dir" } },
        buffer = { columns = { "icon_filename_ff" }, converters = { "converter_hl_dir" } },
        rg = { matchers = {}, sorters = {} },
        source = { defaultAction = "execute" },
        file = { -- filerでしか使ってないのでそれ用に調整してしまう
            columns = { "icon_filename" },
            matchers = { "matcher_hidden" },
            sorters = { "sorter_alpha", "sorter_treefirst" },
        },
        lsp_documentSymbol = { converters = { "converter_lsp_symbol" } },
        lsp_workspaceSymbol = { converters = { "converter_lsp_symbol" } },
    },
    filterParams = {
        matcher_fzf = { highlightMatched = "Search" },
    },
    kindOptions = {
        file = { defaultAction = "open" },
        word = { defaultAction = "append" },
        action = { defaultAction = "do" },
        command_history = { defaultAction = "edit" },
        command = { defaultAction = "edit" },
        help = { defaultAction = "open" },
        readme_viewer = { defaultAction = "open" },
        lsp = { defaultAction = "open" },
        lsp_codeAction = { defaultAction = "apply" },
        ui_select = { defaultAction = "select" },
    },
    columnParams = {
        icon_filename = {
            defaultIcon = { icon = "" },
        },
        icon_filename_for_ff = {
            defaultIcon = { icon = "" },
            padding = 0,
            pathDisplayOption = "relative",
        },
    },
})
-- }}}
