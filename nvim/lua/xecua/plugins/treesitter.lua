-- lua_add {{{
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- fold block by treesitter
-- }}}
-- lua_source {{{
local treesitter_parsers_dir = vim.fn.stdpath("cache") .. "/parsers"
vim.opt.rtp:prepend(treesitter_parsers_dir)
require("nvim-treesitter.configs").setup({
    parser_install_dir = treesitter_parsers_dir,
    highlight = {
        enable = true,
        disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100kB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
    },
    auto_install = true,
    ignore_install = {
        "fish", -- seems to have some problem https://github.com/ram02z/tree-sitter-fish/issues/17
    },
    indent = { enable = true },
})
-- }}}
