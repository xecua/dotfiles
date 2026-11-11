-- lua_source {{{
local cursortab = require("cursortab")

--- @class xecua.cursortab.Provider
--- @field config table cursortabのprovider設定
--- @field modes string[] cursortabを使うモード
--- @field copilot_lsp boolean Copilot LSPを動かすか

--- @type table<string, xecua.cursortab.Provider>
local providers = {
    copilot = { config = { type = "copilot" }, modes = { "normal" }, copilot_lsp = true },
    -- llama-server -hf sweepai/sweep-next-edit-1.5b --port 43482
    sweep = {
        config = { type = "sweep", url = "http://localhost:43482", max_diff_history_tokens = 1024 },
        modes = { "insert", "normal" },
        copilot_lsp = false,
    },
    zeta = {
        config = { type = "zeta-2.1", url = "http://localhost:43482" },
        modes = { "insert", "normal" },
        copilot_lsp = false,
    },
}
local provider_names = vim.tbl_keys(providers)
table.sort(provider_names)

-- Copilot LSPを有効にしているときだけ、providerに合わせて止めたり動かしたりする
local manage_copilot_lsp = vim.lsp.is_enabled("copilot")

-- copilot providerはCopilotが付いていないバッファにも勝手にattachしてしまう
-- オーバーライドしてattachしたくない人はclientがいないことにする
local bridge = require("cursortab.bridge")
function bridge.get_lsp_client(client_names)
    local client = bridge.find_lsp_client(client_names)
    if client and vim.lsp.buf_is_attached(0, client.id) then
        return { { id = client.id } }
    end
    return {}
end

--- @type string?
local current

--- @param name string
--- @return boolean
local function use_provider(name)
    if not providers[name] then
        vim.notify("cursortab: unknown provider: " .. tostring(name), vim.log.levels.ERROR)
        return false
    end
    if name == current then
        return true
    end

    if current then
        -- 前のproviderのdaemonから切断する
        require("cursortab.events").clear_all_completions()
        local chan = require("cursortab.daemon").get_channel_status().channel_id
        if chan then
            pcall(vim.fn.jobstop, chan)
        end
    end
    current = name
    vim.g.cursortab_provider = name

    local provider = providers[name]
    if manage_copilot_lsp then
        -- cleanupはlsp.luaの方でやってる
        vim.lsp.enable("copilot", provider.copilot_lsp)
    end

    -- setupを呼び直すとdaemonに繋ぎ直す
    cursortab.setup({
        -- daemonはstate_dirごとに1つなので、providerごとに分けて他のNeovimと取り合わないようにする
        state_dir = vim.fn.stdpath("state") .. "/cursortab/" .. name,
        keymaps = { accept = false, partial_accept = false },
        behavior = {
            enabled_modes = provider.modes,
            ignore_filetypes = vim.list_extend({ "", "terminal" }, vim.g.no_inline_completion_filetype or {}),
        },
        provider = provider.config,
        ui = { jump = { text = " <C-l> " } },
    })
    return true
end

if not use_provider(vim.g.cursortab_provider or "sweep") then
    use_provider("sweep")
end

vim.api.nvim_create_user_command("CursortabProvider", function(opts)
    if opts.args ~= "" then
        if use_provider(opts.args) then
            vim.notify("cursortab: provider = " .. opts.args)
        end
        return
    end
    vim.ui.select(provider_names, { prompt = "cursortab provider (current: " .. current .. ")" }, function(choice)
        if choice and use_provider(choice) then
            vim.notify("cursortab: provider = " .. choice)
        end
    end)
end, {
    nargs = "?",
    complete = function()
        return provider_names
    end,
    desc = "Switch cursortab provider",
})

vim.keymap.set({ "n", "i" }, "<C-l>", function()
    return cursortab.accept() and "" or "<C-l>"
end, { expr = true, desc = "cursortab: accept" })
vim.keymap.set("n", "<C-c>", function()
    require("cursortab.events").clear_all_completions()
end, { desc = "cursortab: reject" })
-- }}}
