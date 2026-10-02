-- カーソル下のhighlightグループ名を取得 (https://stackoverflow.com/a/37040415)
vim.api.nvim_create_user_command("SynID", function()
    local synid = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), true)
    local name = vim.fn.synIDattr(vim.fn.synIDtrans(synid), "name")
    print(name)
end, {})

-- :h DiffOrig Luaで書き換えたい
vim.api.nvim_create_user_command(
    "DiffOrig",
    "vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis",
    {}
)

-- 現在の状態をセッションとして保存してrestart
vim.api.nvim_create_user_command("Restart", function()
    -- tempname()のファイルだとrestartを乗り越えられない
    local session = vim.fs.joinpath(vim.fn.stdpath("run"), vim.fn.rand() .. ".vim")
    -- restart後のプロセスは環境変数を引き継ぐので、guise.vimが反応しないように消しておく
    -- (VimLeavePreでは間に合わない)
    local saved_env = {}
    for _, name in ipairs({ "GUISE_NVIM_ADDRESS", "GUISE_VIM_ADDRESS" }) do
        saved_env[name] = vim.env[name]
        vim.env[name] = nil
    end
    local ok, err = pcall(vim.cmd, string.format("mks! %s | restart source %s", session, session))
    if not ok then
        for name, value in pairs(saved_env) do
            vim.env[name] = value
        end
        error(err, 0)
    end
end, {})
