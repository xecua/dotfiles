local M = {}

local dpp_augroup = vim.api.nvim_create_augroup("DppConfig", { clear = true })
local dpp_base_dir = vim.fn.stdpath("cache") .. "/dpp"

local function install_plugin(plugin_name)
    local source_local = string.format("%s/repos/github.com/%s", dpp_base_dir, plugin_name)
    if vim.fn.isdirectory(source_local) == 0 then
        vim.notify("installing " .. plugin_name .. "...")
        local source_remote = string.format("https://github.com/%s", plugin_name)
        vim.fn.execute(string.format("!git clone %s %s", source_remote, source_local))
    end
    vim.opt.rtp:prepend(source_local)
end

vim.api.nvim_create_autocmd("User", {
    group = dpp_augroup,
    pattern = "Dpp:makeStatePost",
    callback = function()
        -- load_stateすればいい感じになるっぽいんだよなあ ただし毎回するとまあまあめんどい
        vim.notify("make_state finished. please restart neovim.")
    end,
})

function M.setup(name)
    vim.env.STD_CONFIG = vim.fn.stdpath("config")
    local dpp_config_path = vim.fn.stdpath("config") .. "/dpp/" .. name .. ".ts"

    vim.api.nvim_create_user_command("DppClearState", function()
        require("dpp").clear_state(name)
    end, {})
    vim.api.nvim_create_user_command("DppMakeState", function()
        require("dpp").make_state(dpp_base_dir, dpp_config_path, name)
    end, {})

    vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", {})
    vim.api.nvim_create_user_command("DppUpdate", function(opts)
        vim.fn["dpp#async_ext_action"]("installer", "update", { names = opts.fargs })
    end, { nargs = "*" })
    vim.api.nvim_create_user_command("DppClean", "call map(dpp#check_clean(), { _, val -> delete(val, 'rf') })", {})

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = dpp_augroup,
        pattern = { "*.lua", "*.toml", "*.ts", "*.vim" },
        callback = function()
            require("dpp").check_files(name)
        end,
    })

    install_plugin("Shougo/dpp.vim")
    if require("dpp").load_state(dpp_base_dir, name) then
        install_plugin("Shougo/dpp-protocol-git")
        install_plugin("Shougo/dpp-ext-installer")
        install_plugin("Shougo/dpp-ext-toml")
        install_plugin("Shougo/dpp-ext-lazy")
        install_plugin("vim-denops/denops.vim")

        vim.fn["denops#server#wait_async"](function()
            -- denopsが立ち上がったらmake_stateする
            require("dpp").make_state(dpp_base_dir, dpp_config_path, name)
        end)
    end

    if vim.v.vim_did_enter == 1 then
        vim.fn["dpp#util#_call_hook"]("post_source")
    else
        vim.api.nvim_create_autocmd("VimEnter", {
            group = dpp_augroup,
            pattern = "*",
            callback = function()
                vim.fn["dpp#util#_call_hook"]("post_source")
            end,
        })
    end
end

return M
