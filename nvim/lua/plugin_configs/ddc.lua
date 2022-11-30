vim.fn["ddc#custom#patch_global"]("ui", "pum")
vim.fn["ddc#custom#patch_global"]("sources", {
  "nvim-lsp",
  "neosnippet",
  "around",
  "file",
  "skkeleton",
})
vim.fn["ddc#custom#patch_global"]("sourceOptions", {
  _ = {
    matchers = { "matcher_head" },
    sorters = { "sorter_rank" },
  },
  around = {
    mark = "A",
  },
  neosnippet = {
    dup = true,
    mark = "snip",
  },
  ["nvim-lsp"] = {
    mark = "LSP",
    forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
  },
  file = {
    mark = "F",
    forceCompletionPattern = [[\S/\S*]],
  },
  skkeleton = {
    mark = "skk",
    matchers = { "skkeleton" },
    sorters = {},
  },
})

-- ddc-file (windows)
vim.fn["ddc#custom#patch_filetype"]({ "ps1", "dosbatch", "autohotkey", "registry" }, {
  sourceOptions = {
    file = {
      forceCompletionPattern = [[\S\\\S*]],
    },
  },
  sourceParams = {
    file = {
      mode = "win32",
    },
  },
})

vim.cmd([[
inoremap <silent><expr> <TAB>
  \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
  \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
  \ '<TAB>' : ddc#map#manual_complete()
inoremap <silent><expr> <S-Tab>
  \ pum#visible() ? '<Cmd>call pum#map#insert_relative(-1)<CR>' :
  \ '<C-h>'
]])
-- vim.keymap.set("i", "<Tab>", function()
--   if vim.fn["pum#visible"]() == 1 then
--     return "<Cmd>call pum#map#insert_relative(+1)<CR>"
--   end
--   local _, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local current_char = string.sub(vim.api.nvim_get_current_line(), col - 1, col)
--   if col <= 1 or string.match(current_char, "%s") ~= nil then
--     return "<Tab>"
--   end
--   return vim.fn["ddc#map#manual_complete"]() -- not working...?
-- end, {
--   expr = true,
--   desc = "if pum.vim visible then select next entry, otherwise insert Tab or Start completion depending on current position.",
-- })
-- vim.keymap.set("i", "<S-Tab>", function()
--   if vim.fn["pum#visible"]() == 1 then
--     return "<Cmd>call pum#map#insert_relative(-1)<CR>"
--   else
--     return "<C-h>"
--   end
-- end, { expr = true, desc = "if pum.vim visible then select previous entry, otherwise backspace" })

vim.keymap.set("i", "<C-n>", "<Cmd>call pum#map#insert_relative(+1)<CR>")
vim.keymap.set("i", "<C-p>", "<Cmd>call pum#map#insert_relative(-1)<CR>")
vim.keymap.set("i", "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
vim.keymap.set("i", "<C-e>", "<Cmd>call pum#map#cancel()<CR>")

local ddc_group_id = vim.api.nvim_create_augroup("DdcMyCnf", { clear = true })
vim.api.nvim_create_autocmd("CompleteDone", { group = ddc_group_id, command = "silent! pclose!" })

if vim.fn.exists("g:vscode") ~= 1 then
  vim.fn["ddc#enable"]()
end
