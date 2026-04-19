-- lua_source {{{
if vim.g.started_by_firenvim then
    return
end

local function fileformat()
    -- lualine's fileformat only shows icon *or* text
    -- when nvim-web-devicons becomes to have this, then replace with it.
    return vim.bo.fileformat .. " " .. vim.fn.WebDevIconsGetFileFormatSymbol()
end

local function shiftwidth()
    -- インデントがタブかどうか、タブ幅はどうか(expandtabとtabstopしかいじらないようにしてるのでその2つで判別可能)
    local indentation = vim.o.expandtab and "Space" or "Tab"
    local width = vim.o.tabstop
    return indentation .. ":" .. width
end

local function ddu()
    if vim.o.ft:find("^ddu") == nil then
        return ""
    end

    local status = vim.w.ddu_ui_ff_status -- { name = "default", input = "aaa", done = true, maxItems = 30 }

    return string.format("[%s-%s] %d/%d", vim.o.ft, status.name, vim.fn.line("$"), status.maxItems)
end

local mcp_hub = {
    function()
        -- Check if MCPHub is loaded
        if not vim.g.loaded_mcphub then
            return "󰐻 -"
        end

        local count = vim.g.mcphub_servers_count or 0
        local status = vim.g.mcphub_status or "stopped"
        local executing = vim.g.mcphub_executing

        -- Show "-" when stopped
        if status == "stopped" then
            return "󰐻 -"
        end

        -- Show spinner when executing, starting, or restarting
        if executing or status == "starting" or status == "restarting" then
            local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            local frame = math.floor(vim.loop.now() / 100) % #frames + 1
            return "󰐻 " .. frames[frame]
        end

        return "󰐻 " .. count
    end,
    color = function()
        if not vim.g.loaded_mcphub then
            return { fg = "#6c7086" } -- Gray for not loaded
        end

        local status = vim.g.mcphub_status or "stopped"
        if status == "ready" or status == "restarted" then
            return { fg = "#50fa7b" } -- Green for connected
        elseif status == "starting" or status == "restarting" then
            return { fg = "#ffb86c" } -- Orange for connecting
        else
            return { fg = "#ff5555" } -- Red for error/stopped
        end
    end,
}

local function navic_fallback()
    local navic = require("nvim-navic")
    if navic.is_available() then
        local location = navic.get_location({ click = true, lazy_update_context = true })
        if location and location ~= "" then
            return location
        end
    end
    return " " -- これやっとかないとまっしろになる
end

require("lualine").setup({
    options = {
        theme = "wombat",
        globalstatus = true,
        disabled_filetypes = {
            winbar = {
                "dap-repl",
                "dap-view",
                "dap-view-term",
                "dap-view-help",
            },
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {
            { "branch", icon = { "" } }, -- 0xe702 (devicons)
        },
        lualine_c = { ddu },
        lualine_x = {
            "searchcount",
            "diagnostics",
            { "lsp_status", ignore_lsp = { "efm", "GitHub Copilot" } },
            mcp_hub,
        },
        lualine_y = { fileformat, shiftwidth, "encoding", "filetype" },
        lualine_z = { "location" },
    },
    tabline = {
        lualine_a = {
            {
                "tabs",
                max_length = function()
                    return vim.o.columns * 2 / 3
                end,
                mode = 2,
            },
        },
    },
    winbar = {
        lualine_b = {
            { "filename", path = 1, symbols = { readonly = "[readonly]" } },
        },
        lualine_c = { navic_fallback },
    },
    inactive_winbar = {
        lualine_b = { { "filename", path = 1, symbols = { readonly = "[readonly]" } } },
    },
    extensions = { "fern", "man", "quickfix", "trouble", "fugitive", "avante", "mason" },
})
-- }}}
