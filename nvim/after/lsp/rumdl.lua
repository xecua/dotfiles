return {
    -- obsidian vault内ではmarkdown_oxideを使うので起動しない
    root_dir = function(bufnr, on_dir)
        if vim.fs.root(bufnr, { ".obsidian", ".moxide.toml" }) then
            return
        end

        -- nvim-lspconfigのデフォルトと同じ
        local root_markers = { ".rumdl.toml", "rumdl.toml", ".config/rumdl.toml", "pyproject.toml", ".git" }
        on_dir(vim.fs.root(bufnr, root_markers))
    end,
}
