-- lua_add {{{
vim.g["operator#surround#blocks"] = {
    ["-"] = {
        -- なんか知らんが効かん
        { block = { "（", "）" }, motionwise = { "char", "line", "block" }, keys = { "fP" } },
        { block = { "「", "」" }, motionwise = { "char", "line", "block" }, keys = { "fB" } },
        { block = { "『", "』" }, motionwise = { "char", "line", "block" }, keys = { "fD" } },
    },
    javascript = {
        { block = { "/", "/" }, motionwise = { "char", "line", "block" }, keys = { "/" } },
    },
    typescript = {
        { block = { "/", "/" }, motionwise = { "char", "line", "block" }, keys = { "/" } },
    },
    javascriptreact = {
        { block = { "/", "/" }, motionwise = { "char", "line", "block" }, keys = { "/" } },
    },
    typescriptreact = {
        { block = { "/", "/" }, motionwise = { "char", "line", "block" }, keys = { "/" } },
    },
    astro = {
        { block = { "/", "/" }, motionwise = { "char", "line", "block" }, keys = { "/" } },
    },
    vue = {
        { block = { "/", "/" }, motionwise = { "char", "line", "block" }, keys = { "/" } },
    },
}

local function is_operator_surround_disabled_buffer()
    local List = require("plenary.collections.py_list")
    local operator_surround_disabled_buffer_types = List({
        "fern",
        "ddu-ff",
        "ddu-filer",
        "qf",
        "fugitive",
        "gitsigns-blame",
    })
    return operator_surround_disabled_buffer_types:contains(vim.opt_local.ft:get())
end

local augroup = vim.api.nvim_create_augroup("OperatorSurround", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = "*",
    callback = function()
        if not is_operator_surround_disabled_buffer() then
            vim.keymap.set("n", "sa", "<Plug>(operator-surround-append)", { buffer = true })
            vim.keymap.set("n", "sd", "<Plug>(operator-surround-delete)", { buffer = true })
            vim.keymap.set("n", "sr", "<Plug>(operator-surround-replace)", { buffer = true })
        end
    end,
})
vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    pattern = "*",
    callback = function()
        if not is_operator_surround_disabled_buffer() then
            vim.keymap.del("n", "sa", { buffer = true })
            vim.keymap.del("n", "sd", { buffer = true })
            vim.keymap.del("n", "sr", { buffer = true })
        end
    end,
})
-- }}}
