vim.fn["ddu#custom#patch_global"]({
  ui = "ff",
  uiParams = {
    ff = {
      previewWidth = 80,
      previewVertical = true,
      autoAction = { name = "preview" },
    },
    filer = {
      winWidth = vim.o.columns / 8,
      split = "vertical",
      splitDirection = "topleft",
    },
  },
  souces = { "file_rec" },
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
    vim.keymap.set("n", "p", "<Cmd>call ddu#ui#ff#do_action('preview')<CR>", { buffer = true, silent = true })
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
    vim.keymap.set({ "n" }, "q", "<Esc><Cmd>call ddu#ui#ff#close()<CR>", { buffer = true, silent = true })
    vim.keymap.set({ "i", "n" }, "<CR>", "<Esc><Cmd>call ddu#ui#ff#close()<CR>", { buffer = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = ddu_group_id,
  callback = function()
    -- そのまま書くとプラグインの方に上書きされてしまうのでVimEnterで上書き
    vim.api.nvim_create_user_command("DduRg", function(opts)
      vim.fn["ddu#start"]({
        volatile = opts.args == "",
        sources = { {
          name = "rg",
          params = { input = opts.args },
        } },
        uiParams = { ff = { ignoreEmpty = false, autoResize = false } },
      })
    end, { nargs = "?" })
  end,
})

vim.api.nvim_create_user_command("DduFiler", function()
  vim.fn["ddu#start"]({
    ui = "filer",
    sources = {
      { name = "file", params = {}, options = {
        columns = { "icon_filename" },
      } },
    },
    actionOptions = {
      narrow = { quit = false },
    },
  })
end, {})

vim.api.nvim_create_autocmd("FileType", {
  group = ddu_group_id,
  pattern = "ddu-filer",
  callback = function()
    vim.keymap.set("n", "<CR>", function()
      if vim.fn["ddu#ui#filer#is_directory"]() then
        return "<Cmd>call ddu#ui#filer#do_action('itemAction', {'name': 'narrow'})<CR>"
      else
        return "<Cmd>call ddu#ui#filer#do_action('itemAction', {'name': 'open'})<CR>"
      end
    end, { expr = true, buffer = true, silent = true })
    vim.keymap.set(
      "n",
      "<BS>",
      "<Cmd>call ddu#ui#filer#do_action('itemAction', {'name': 'narrow', 'params': {'path': '..'}})<CR>",
      { buffer = true, silent = true }
    )
    vim.keymap.set("n", "q", "<Cmd>call ddu#ui#filer#do_action('quit')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-n>", "<Cmd>call ddu#ui#filer#do_action('quit')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "l", "<Cmd>call ddu#ui#filer#do_action('expandItem')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "h", "<Cmd>call ddu#ui#filer#do_action('collapseItem')<CR>", { buffer = true, silent = true })
    vim.keymap.set(
      "n",
      "o",
      "<Cmd>call ddu#ui#filer#do_action('expandItem', {'mode': 'toggle'})<CR>",
      { buffer = true, silent = true }
    )
    vim.keymap.set("n", "n", "<Cmd>call ddu#ui#filer#do_action('newFile')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "r", "<Cmd>call ddu#ui#filer#do_action('rename')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "y", "<Cmd>call ddu#ui#filer#do_action('copy')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "m", "<Cmd>call ddu#ui#filer#do_action('move')<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "p", "<Cmd>call ddu#ui#filer#do_action('paste')<CR>", { buffer = true, silent = true })
    vim.keymap.set(
      "n",
      "<Space>",
      "<Cmd>call ddu#ui#filer#do_action('toggleSelectItem')<CR>",
      { buffer = true, silent = true }
    )
    -- toggle hidden files
    vim.keymap.set("n", "!", function()
      local current = vim.fn["ddu#custom#get_current"](vim.b.ddu_ui_name)
      local source_options = current and current["sourceOptions"] or nil
      local source_options_all = source_options and source_options["_"] or nil
      local matchers = source_options_all and source_options_all["matchers"] or {}
      local new_matchers = (#matchers == 0) and { "matcher_hidden" } or {}
      vim.fn["ddu#ui#filer#do_action"]("updateOptions", {
        sourceOptions = {
          _ = {
            matchers = new_matchers,
          },
        },
      })
    end, { buffer = true, silent = true })
  end,
})
