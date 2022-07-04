local denite_augroup_id = vim.api.nvim_create_augroup("DeniteMyCnf", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = denite_augroup_id,
  pattern = 'denite',
  callback = function()
    vim.keymap.set("n", "<CR>", function() vim.fn["denite#do_map"]('do_action') end, { silent = true, buffer = true  })
    vim.keymap.set("n", "d", function() vim.fn["denite#do_map"]('do_action', 'delete') end, { silent = true, buffer = true  })
    vim.keymap.set("n", "p", function() vim.fn["denite#do_map"]('do_action', 'preview') end, { silent = true, buffer = true  })
    vim.keymap.set("n", "q", function() vim.fn["denite#do_map"]('quit') end, { silent = true, buffer = true  })
    vim.keymap.set("n", "K", function() vim.fn["denite#do_map"]('move_up_path') end, { silent = true, buffer = true  })
    vim.keymap.set("n", "/", function() vim.fn["denite#do_map"]('open_filter_buffer') end, { silent = true, buffer = true  })
    vim.keymap.set("n", "<Space>", function()
      vim.fn["denite#do_map"]('toggle_select')
      local r, c = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_win_set_cursor(r + 1, c) -- move to next line
    end, { silent = true, buffer = true  })
  end,
})
