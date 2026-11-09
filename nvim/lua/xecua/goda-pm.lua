local M = {}

vim.env.STD_CONFIG = vim.fn.stdpath("config")

local goda_pm_base_dir = vim.fn.stdpath("cache") .. "/goda-pm"
local function install_plugin(plugin_name)
    local source_local = string.format("%s/repos/github.com/%s", goda_pm_base_dir, plugin_name)
    if vim.fn.isdirectory(source_local) == 0 then
        vim.notify("installing " .. plugin_name .. "...")
        local source_remote = string.format("https://github.com/%s", plugin_name)
        vim.system({ "git", "clone", source_remote, source_local }):wait()
    end
    vim.opt.rtp:prepend(source_local)
end

local goda_pm_augroup = vim.api.nvim_create_augroup("GodaPmConfig", { clear = true })
vim.api.nvim_create_autocmd("User", {
    group = goda_pm_augroup,
    pattern = "GodaPm:makeStatePost",
    callback = function()
        vim.notify("make_state finished. please restart neovim.")
    end,
})

function M.setup(name)
    -- nil を渡すと goda-pm 側の既定値 (v:progname) が効かず、base_dir 直下に state が作られてしまう
    name = name or vim.fn.fnamemodify(vim.v.progname, ":r")
    vim.api.nvim_create_user_command("GpClearState", function()
        require("goda_pm").clear_state(name)
    end, {})
    vim.api.nvim_create_user_command("GpMakeState", function()
        require("goda_pm").make_state(goda_pm_base_dir, name)
    end, {})

    vim.api.nvim_create_user_command("GpInstall", "call goda_pm#async_ext_action('installer', 'install')", {})
    vim.api.nvim_create_user_command("GpUpdate", function(opts)
        vim.fn["goda_pm#async_ext_action"]("installer", "update", { names = opts.fargs })
    end, { nargs = "*" })
    vim.api.nvim_create_user_command("GpClean", "call map(goda_pm#check_clean(), { _, val -> delete(val, 'rf') })", {})
    vim.api.nvim_create_user_command("GpLog", function()
        local lines = vim.fn["goda#log"]("pm")
        for _, line in ipairs(lines) do
            vim.print(line)
        end
    end, {})

    install_plugin("Shougo/goda.vim")
    install_plugin("Shougo/goda-pm.vim")
    install_plugin("Shougo/goda-pm-ext-lazy.vim")

    if require("goda_pm").load_state(goda_pm_base_dir, name) then
        vim.api.nvim_create_autocmd("VimEnter", {
            group = goda_pm_augroup,
            once = true,
            pattern = "*",
            callback = function()
                require("goda_pm").make_state(goda_pm_base_dir, name)
            end,
        })
    end
end

return M
