vim.g.quickrun_no_default_key_mappings = 1
vim.g.quickrun_config = {
  _ = {
    runner = "vimproc",
    ["runner/vimproc/updatetime"] = 40,
    outputter = "error",
    ["outputter/error/error"] = "quickfix",
    ["outputter/quickfix/into"] = 1,
  },
  cpp = { command = "g++" },
  tex = { command = "latexmk" },
  satysfi = { command = "satysfi" },
  rust = { type = "rust/cargo" },
}

vim.fn["quickrun#module#register"]({
  name = "close_quickfix_on_success",
  kind = "hook",
  on_success = function(_, _)
    vim.api.nvim_command("cclose")
  end,
}, 1)

vim.keymap.set("n", "<F5>", "<Cmd>QuickRun -mode n<CR>", { silent = true })
vim.keymap.set("v", "<F5>", "<Cmd>QuickRun -mode v<CR>", { silent = true })
