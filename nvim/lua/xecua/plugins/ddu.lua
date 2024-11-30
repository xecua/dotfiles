-- lua_add {{{
-- vim.g.loaded_ddu_rg = 1 -- prevent command definition by plugin

vim.api.nvim_create_user_command("DduRgLive", function()
    -- actionOptionsでquitをfalseにすれば閉じなくなる(Filer参照)が、openでwincmdを噛ませるように変更する必要がある
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
vim.keymap.set("n", "<Leader>fd", "<Cmd>Ddu file_fd<CR>")
vim.keymap.set("n", "<Leader>fb", "<Cmd>Ddu buffer<CR>")
vim.keymap.set("n", "<Leader>ft", "<Cmd>Ddu deol<CR>")
vim.keymap.set("n", "<Leader>fg", "<Cmd>DduRgLive<CR>")
vim.keymap.set("n", "<Leader>fls", "<Cmd>DduLspDocumentSymbol<CR>")
vim.keymap.set("n", "<Leader>flw", "<Cmd>DduLspWorkspaceSymbol<CR>")

vim.api.nvim_create_user_command("DduFiler", function()
    vim.fn["ddu#start"]({
        ui = "filer",
        sources = { { name = "file" } },
        sourceOptions = { file = { columns = { "icon_filename" } } },
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
        vim.keymap.set("n", "a", "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", opts)
        vim.keymap.set("n", "/", "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", opts)
        vim.keymap.set("n", "p", "<Cmd>call ddu#ui#do_action('togglePreview')<CR>", opts)
        vim.keymap.set("n", ",", "<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>", opts)
        vim.keymap.set("n", "t", "<Cmd>call ddu#ui#do_action('toggleAllItems')<CR>", opts)
        vim.keymap.set("n", "f", "<Cmd>call ddu#ui#do_action('itemAction', #{ name: 'quickfix' })<CR>", opts)
        vim.keymap.set("n", "h", "<Cmd>call ddu#ui#do_action('collapseItem')<CR>", opts)
        vim.keymap.set("n", "l", "<Cmd>call ddu#ui#do_action('expandItem')<CR>", opts)
        vim.keymap.set("n", "q", "<Cmd>call ddu#ui#do_action('quit')<CR>", opts)

        local converter_display_word = "converter_display_word"
        -- _はマーカーとして使う。実際には各sourceのオプションに反映しないといけない
        vim.keymap.set("n", "w", function()
            local current = vim.fn["ddu#custom#get_current"]()
            local new_source_options = current.sourceOptions
            local matchers = new_source_options._.matchers

            -- converter_display_wordは最初にいるはず
            if matchers[1] ~= converter_display_word then
                vim.notify("Display word included.")
                table.insert(matchers, 1, converter_display_word)
            else
                vim.notify("Display word excluded.")
                table.remove(matchers, 1)
            end
            for _, source in ipairs(current.sources) do
                -- 変更されているはずなのでそのままコピー。
                new_source_options[source.name].matchers = matchers
            end

            vim.fn["ddu#ui#do_action"]("updateOptions", { sourceOptions = new_source_options })
            vim.fn["ddu#redraw"](vim.b.ddu_ui_name, { method = "refreshItems" })
        end, opts)

        local matcher_fzf = "matcher_fzf"
        local matcher_substring = "matcher_substring"
        local matcher_regex = "matcher_multi_regex"
        local sorter_alpha = "sorter_alpha"
        local sorter_fzf = "sorter_fzf"
        vim.keymap.set("n", "m", function()
            -- switch matching mode
            local current = vim.fn["ddu#custom#get_current"]()
            local new_source_options = current.sourceOptions
            local matchers = new_source_options._.matchers
            local sorters = new_source_options._.sorters

            -- converter_display_wordがある可能性がある
            for i, m in ipairs(matchers) do
                if m == matcher_fzf then
                    vim.notify("Changing matcher to substring.")
                    matchers[i] = matcher_substring
                    sorters = { sorter_alpha }
                    break
                elseif m == matcher_substring then
                    vim.notify("Changing matcher to regex.")
                    matchers[i] = matcher_regex
                    break
                elseif m == matcher_regex then
                    vim.notify("Changing matcher to fuzzy.")
                    matchers[i] = matcher_fzf
                    sorters = { sorter_fzf }
                    break
                end
            end

            for _, source in ipairs(current.sources) do
                new_source_options[source.name].matchers = matchers
                new_source_options[source.name].sorters = sorters
            end

            vim.fn["ddu#ui#do_action"]("updateOptions", { sourceOptions = new_source_options })

            vim.fn["ddu#redraw"](vim.b.ddu_ui_name, { method = "refreshItems" })
        end, opts)
    end,
})
-- vim.api.nvim_create_autocmd('VimResized', {
--   group = ddu_group_id,
--   callback = function()
--     vim.fn['ddu#custom#patch_global']({
--       uiParams = {
--         ff = {
--           winCol = vim.o.columns / 4,
--           winRow = vim.o.lines / 8,
--           winWidth = vim.o.columns / 2,
--           winHeight = math.floor(vim.o.lines / 2) - 2,
--           previewCol = vim.o.columns / 4,
--           previewRow = vim.o.lines * 3 / 4 + 1,
--           previewWidth = vim.o.columns / 2,
--           previewHeight = math.floor(vim.o.lines / 8),
--         },
--       },
--     })
--   end,
-- })
vim.api.nvim_create_autocmd("User", {
    pattern = "Ddu:ui:ff:openFilterWindow",
    command = 'call pum#set_option("reversed", v:true)',
})

vim.api.nvim_create_autocmd("User", {
    pattern = "Ddu:ui:ff:closeFilterWindow",
    command = 'call pum#set_option("reversed", v:false)',
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
            local isTree = vim.fn["ddu#ui#get_item"]()["isTree"] or false
            if not isTree then
                vim.fn["ddu#ui#do_action"](
                    "itemAction",
                    { name = "open", params = { command = "wincmd p|wincmd s|drop" } }
                )
            end
        end)
        vim.keymap.set("n", "v", function()
            local isTree = vim.fn["ddu#ui#get_item"]()["isTree"] or false
            if not isTree then
                vim.fn["ddu#ui#do_action"](
                    "itemAction",
                    { name = "open", params = { command = "wincmd p|wincmd v|drop" } }
                )
            end
        end)
        vim.keymap.set("n", "l", function()
            local isTree = vim.fn["ddu#ui#get_item"]()["isTree"] or false
            if isTree then
                vim.fn["ddu#ui#do_action"]("expandItem", { isInTree = true })
            else
                vim.fn["ddu#ui#do_action"]("itemAction", { name = "open", params = { command = "wincmd p|drop" } })
            end
        end, opts)

        vim.keymap.set("n", "<CR>", function()
            local isTree = vim.fn["ddu#ui#get_item"]()["isTree"] or false
            if isTree then
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

-- lua_post_source {{{
vim.fn["ddu#custom#patch_global"]({
    ui = "ff",
    uiParams = {
        ff = {
            previewWidth = 80,
            previewSplit = "vertical",
            -- split = 'floating',
            -- floatingBorder = 'rounded',
            -- previewFloating = true,
            -- previewFloatingBorder = 'rounded',
            -- winCol = vim.o.columns / 4,
            -- winRow = vim.o.lines / 8,
            -- winWidth = vim.o.columns / 2,
            -- winHeight = math.floor(vim.o.lines / 2) - 2,
            -- previewCol = vim.o.columns / 4,
            -- previewRow = vim.o.lines * 3 / 4 + 1,
            -- previewWidth = vim.o.columns / 2,
            -- previewHeight = math.floor(vim.o.lines / 8),
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
        file_fd = { args = { "-tf", "-H", "-E", ".git" } },
    },
    sourceOptions = {
        _ = { matchers = { "matcher_fzf" }, sorters = { "sorter_fzf" } },
        source = { defaultAction = "execute" },
        file = { matchers = { "matcher_hidden" }, sorters = {} }, -- filerでしか使ってない
        lsp_documentSymbol = { converters = { "converter_lsp_symbol" } },
        lsp_workspaceSymbol = { converters = { "converter_lsp_symbol" } },
    },
    filterParams = {
        matcher_fzf = { highlightMatched = "Search" },
        matcher_substring = { highlightMatched = "Search" },
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
    },
})
-- }}}
