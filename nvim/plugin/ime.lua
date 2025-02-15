local augroup = vim.api.nvim_create_augroup("IMSwitch", { clear = true })

local function switch_im_function(enable)
    return function()
        -- disable IME
        local os_string = require("xecua.utils").get_os_string()
        local command = nil
        if os_string == "Linux" then
            local c = nil
            if vim.fn.executable("fcitx5-remote") then
                c = "fcitx5-remote"
            elseif vim.fn.executable("fcitx-remote") then
                c = "fcitx-remote"
            end
            if c then
                -- test fcitx is running (e.g. in GUI session)
                local result = vim.system({ c }, { text = true }):wait()
                if result.code ~= 0 then
                    error(result.stderr)
                end
                if result.stdout ~= "0\n" then
                    if enable then
                        command = { c, "-o" }
                    else
                        command = { c, "-c" }
                    end
                end
            end
        elseif os_string == "Darwin" then
            if vim.fn.executable("macism") then
                if enable then
                    command = { "macism", "net.mtgto.inputmethod.macSKK.ascii" }
                else
                    command = { "macism", "com.apple.keylayout.ABC" }
                end
            end
        end
        if command then
            local result = vim.system(command, { text = true }):wait()
            if result.code ~= 0 then
                error(result.stderr)
            end
        end
    end
end

vim.api.nvim_create_autocmd({ "FocusGained", "VimEnter" }, {
    group = augroup,
    pattern = "*",
    callback = switch_im_function(false),
})
vim.api.nvim_create_autocmd({ "FocusLost", "VimLeave" }, {
    group = augroup,
    pattern = "*",
    callback = switch_im_function(true),
})
