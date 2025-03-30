-- autocommands
local init_augroup_id = vim.api.nvim_create_augroup("Init", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = init_augroup_id,
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[silent! %s#\s\+$##e]])
        vim.cmd([[silent! %s#\($\n\s*\)\+\%$##e]])
        pos[1] = math.min(pos[1], vim.api.nvim_buf_line_count(0))
        vim.api.nvim_win_set_cursor(0, pos)
    end,
    desc = "Remove redundant lines",
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = {
        "astro",
        "c",
        "cpp",
        "dart",
        "fish",
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "typespec",
        "json",
        "nix",
        "jsonc",
        "rst",
        "satysfi",
        "vim",
        "vue",
        "xml",
        "yaml",
    },
    callback = function()
        vim.opt_local.tabstop = 2
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = {
        "astro",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },
    callback = function()
        -- regex string as text object
        vim.keymap.set("o", "i/", "<Cmd>normal! T/vt/<CR>")
        vim.keymap.set("o", "a/", "<Cmd>normal! F/vf/<CR>")
        vim.keymap.set("v", "i/", "<Cmd>normal! T/ot/<CR>")
        vim.keymap.set("v", "a/", "<Cmd>normal! F/of/<CR>")
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = { "gitconfig", "go", "tsv" },
    callback = function()
        vim.opt_local.expandtab = false
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = { "csv", "tsv" },
    callback = function()
        vim.opt_local.wrap = false
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = "snippets",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.softtabstop = -1
        vim.opt_local.shiftwidth = 0
        vim.opt_local.tabstop = 2
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = init_augroup_id,
    pattern = "tex",
    callback = function()
        vim.opt_local.makeprg = "latexmk"
    end,
})
vim.api.nvim_create_autocmd(
    { "BufWritePost", "FileWritePost" },
    { group = init_augroup_id, pattern = { "*.saty", "*.tex" }, command = "QuickRun" }
)
if vim.fn.executable("pdftotext") == 1 then
    vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = init_augroup_id,
        pattern = "*.pdf",
        command = [[enew | file #.txt | 0read !pdftotext -layout -nopgbrk "#" -]],
    })
end
-- automatically open QuickFix window after grep
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = init_augroup_id,
    pattern = { "grep", "vimgrep" },
    command = "copen",
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = init_augroup_id,
    pattern = { "lgrep", "lvimgrep" },
    command = "lopen",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = init_augroup_id,
    pattern = "*",
    command = [[
        hi! CurSearch cterm=reverse gui=reverse
        hi link NormalFloat Normal
    ]],
})

vim.api.nvim_create_autocmd("User", {
    group = init_augroup_id,
    pattern = "DBUIOpened",
    command = "setl number",
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = init_augroup_id,
    pattern = "*",
    callback = function()
        local path = string.gsub(vim.fn.expand("%:p"), "^" .. vim.fn.expand("$HOME"), "~")
        if path == "" then
            path = vim.fn.getcwd()
        end
        vim.opt.titlestring = "nvim: " .. vim.fn.pathshorten(path)
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = init_augroup_id,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf
        vim.api.nvim_buf_create_user_command(buffer, "LspFormat", function()
            vim.lsp.buf.format({
                filter = function(c)
                    return c.name ~= "typescript-tools" and c.name ~= "lua_ls" and c.name ~= "sqls"
                end,
            })
        end, {})
        vim.api.nvim_buf_create_user_command(buffer, "LspHover", function()
            vim.lsp.buf.hover({
                border = "single",
                focusable = false,
                focus = false,
                silent = true,
            })
        end, {})
        vim.api.nvim_buf_create_user_command(buffer, "LspSignatureHelp", function()
            vim.lsp.buf.signature_help({
                border = "single",
                focusable = false,
                focus = false,
                silent = true,
            })
        end, {})
        vim.api.nvim_buf_create_user_command(buffer, "LspReferences", "lua vim.lsp.buf.references()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspDefinition", "lua vim.lsp.buf.definition()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspTypeDefinition", "lua vim.lsp.buf.type_definition()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspImplementation", "lua vim.lsp.buf.implementation()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspCodeAction", "lua vim.lsp.buf.code_action()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspIncomingCalls", "lua vim.lsp.buf.incoming_calls()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspOutgoingCalls", "lua vim.lsp.buf.outgoing_calls()", {})
        vim.api.nvim_buf_create_user_command(buffer, "LspRename", "lua vim.lsp.buf.rename()", {})

        -- Mappings.
        local opts = { buffer = buffer, silent = true }

        -- LSP related: preceded by <Leader>l
        vim.keymap.set("n", "K", "<Cmd>LspHover<CR>", opts)
        vim.keymap.set("n", "<Leader>lh", "<Cmd>LspSignatureHelp<CR>", opts)
        vim.keymap.set("n", "<Leader>lr", "<Cmd>LspReferences<CR>", opts)
        vim.keymap.set("n", "<Leader>ld", "<Cmd>LspDefinition<CR>", opts)
        vim.keymap.set("n", "<Leader>lt", "<Cmd>LspTypeDefinition<CR>", opts)
        vim.keymap.set("n", "<Leader>li", "<Cmd>LspImplementation<CR>", opts)
        vim.keymap.set("n", "<Leader>la", "<Cmd>LspCodeAction<CR>", opts)
        vim.keymap.set("n", "<Leader>lci", "<Cmd>LspIncomingCalls<CR>", opts)
        vim.keymap.set("n", "<Leader>lco", "<Cmd>LspOutgoingCalls<CR>", opts)
        vim.keymap.set("n", "<F2>", "<Cmd>LspRename<CR>", opts)
        vim.keymap.set({ "i", "s" }, "<C-s>", "<Cmd>LspSignatureHelp<CR>", opts)

        if client.name == "jdtls" then
            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspOrganizeImports",
                'lua require("jdtls").organize_imports()',
                {}
            )
            vim.keymap.set("n", "<Leader>lo", "<Cmd>LspOrganizeImports<CR>", { buffer = buffer, silent = true })

            vim.api.nvim_buf_create_user_command(buffer, "LspTestClass", 'lua require("jdtls").test_class()', {})
            vim.keymap.set("n", "<Leader>dc", "<Cmd>LspTestClass<CR>", { buffer = buffer, silent = true })

            vim.api.nvim_buf_create_user_command(
                buffer,
                "LspTestMethod",
                'lua require("jdtls").test_nearest_method()',
                {}
            )
            vim.keymap.set("n", "<Leader>dm", "<Cmd>LspTestMethod<CR>", { buffer = buffer, silent = true })

            require("jdtls").setup_dap({ hotcodereplace = "auto" })
        end

        if client:supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, buffer)
        end

        if client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = init_augroup_id,
                buffer = buffer,
                command = "LspFormat",
                desc = "LSP: Format on save",
            })
        end

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable()
        end

        if client:supports_method("textDocument/signatureHelp") then
            vim.api.nvim_create_autocmd("CursorHoldI", {
                group = init_augroup_id,
                buffer = buffer,
                command = "LspSignatureHelp",
                desc = "LSP: Signature Help while Typing.",
            })
        end
    end,
})
