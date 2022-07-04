vim.fn["ddu#custom#patch_global"]({
  ui = "ff",
  sourceOptions = {
    _ = { matchers = { "matcher_substring" } },
    source = { defaultAction = "execute" },
  },
  kindOptions = {
    file = { defaultAction = "open" },
    word = { defaultAction = "append" },
  },
})

local ddu_group_id = vim.api.nvim_create_augroup("DduMyCnf", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = ddu_group_id,
  pattern = "ddu-ff",
  callback = function()
    vim.keymap.set("n", "<CR>", "<Cmd>call ddu#ui#ff#do_action('itemAction')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "/", "<Cmd>call ddu#ui#ff#do_action('openFilterWindow')<CR>", { buffer = true, silent = true })
    vim.keymap.set(
      "n",
      "<Space>",
      "<Cmd>call ddu#ui#ff#do_action('toggleSelectItem')<CR>",
      { buffer = true, silent = true }
    )
    vim.keymap.set("n", "q", "<Cmd>call ddu#ui#ff#do_action('quit')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "e", "<Cmd>call ddu#ui#ff#do_action('edit')<CR>", { buffer = true, silent = true })
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = ddu_group_id,
  pattern = "ddu-ff-filter",
  callback = function()
    vim.keymap.set({ "i", "n" }, "<CR>", "<Cmd>close<CR>", { buffer = true, silent = true })
  end,
})
