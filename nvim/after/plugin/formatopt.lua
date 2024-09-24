vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- leximaが原因(たぶん)でNORMALモードに戻ったときに誤爆する。回避策あったらそっちのがいい
        vim.opt_local.formatoptions:remove({ "r" })
    end,
})
