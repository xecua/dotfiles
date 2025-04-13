return {
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local util = require("lspconfig.util")
        on_dir(util.root_pattern("deno.json", "deno.jsonc", "denops")(fname))
    end,
}
