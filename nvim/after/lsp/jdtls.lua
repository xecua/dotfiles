local bundles = {}

local java_debug = vim.env.XDG_DATA_HOME .. "/java-debug"
if vim.uv.fs_stat(java_debug) then
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_debug .. "/server/*.jar"), "\\n"))
end

local java_test = vim.env.XDG_DATA_HOME .. "/java-test"
if vim.uv.fs_stat(java_test) then
    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test .. "/server/*.jar"), "\\n"))
end

return {
    init_options = { bundles = bundles },
}
