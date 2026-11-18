vim.opt_local.formatoptions = "jonqrB" -- ftplugin
vim.opt_local.comments = ""
for _, marker in ipairs({ "+", "-", "*", "1." }) do
    vim.opt_local.comments:prepend({
        "b:" .. marker .. [=[\ [\ ]]=],
        "b:" .. marker .. [=[\ [x]]=],
        "b:" .. marker,
    })
end

vim.opt_local.comments:prepend({ "nb:>" })

-- Markdown をリッチテキストとしてクリップボードにコピーする
-- Wayland: pandoc で HTML にして wl-copy (text/html)
-- macOS: pandoc で RTF にして pbcopy (先頭が {\rtf なら RTF として扱われる)
-- Windows: pandoc で RTF にして PowerShell 経由で Clipboard.SetText(..., Rtf)
local function copy_rich(lines)
    if vim.fn.executable("pandoc") == 0 then
        vim.notify("pandoc not found", vim.log.levels.INFO)
        return
    end

    local to, copy
    if vim.env.WAYLAND_DISPLAY and vim.fn.executable("wl-copy") == 1 then
        to, copy = "html", { "wl-copy", "--type", "text/html" }
    elseif vim.fn.executable("pbcopy") == 1 then
        to, copy = "rtf", { "pbcopy" }
    elseif vim.fn.has("win32") == 1 then
        -- pandoc の RTF は非 ASCII を \uN? でエスケープするので、標準入力の文字コードに依存しない
        to, copy =
            "rtf", {
                "powershell.exe",
                "-NoProfile",
                "-STA",
                "-Command",
                "Add-Type -AssemblyName System.Windows.Forms; [Windows.Forms.Clipboard]::SetText([Console]::In.ReadToEnd(), 'Rtf')",
            }
    else
        vim.notify("no clipboard tool for rich text (wl-copy / pbcopy / powershell)", vim.log.levels.INFO)
        return
    end

    local conv = vim.system({ "pandoc", "-f", "gfm", "-t", to, "--standalone" }, { stdin = lines }):wait()
    if conv.code ~= 0 then
        vim.notify("pandoc failed: " .. conv.stderr, vim.log.levels.ERROR)
        return
    end
    vim.system(copy, { stdin = conv.stdout }):wait()
end

vim.keymap.set("n", "gy", function()
    copy_rich(vim.api.nvim_buf_get_lines(0, 0, -1, false))
end, { buffer = true, desc = "Copy buffer as rich text" })

vim.keymap.set("x", "gy", function()
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    copy_rich(lines)
end, { buffer = true, desc = "Copy selection as rich text" })
