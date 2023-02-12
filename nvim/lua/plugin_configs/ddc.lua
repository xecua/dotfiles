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
    matchers = { "matcher_fuzzy" },
    sorters = { "sorter_fuzzy" },
    converters = { "converter_fuzzy" },
  },
  neosnippet = {
    mark = "snip",
    dup = "keep",
  },
  ["nvim-lsp"] = {
    mark = "LSP",
    matchers = { "matcher_fuzzy" },
    sorters = { "sorter_fuzzy" },
    converters = { "converter_fuzzy" },
    forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
  },
  file = {
    mark = "File",
    matchers = { "matcher_fuzzy" },
    sorters = { "sorter_fuzzy" },
    converters = { "converter_fuzzy" },
    forceCompletionPattern = [[\S/\S*]],
  },
  skkeleton = {
    mark = "skk",
    matchers = { "skkeleton" },
    sorters = {},
    isVolatile = true,
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

vim.keymap.set("i", "<Tab>", function()
  if vim.fn["pum#visible"]() then
    return vim.fn["pum#map#insert_relative"](1)
  end
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_char = string.sub(vim.api.nvim_get_current_line(), 0, col)
  if string.match(current_char, "^%s*$") ~= nil then
    return "<Tab>"
  end
  return vim.fn["ddc#map#manual_complete"]()
end, {
  expr = true,
  desc = "Select next entry or start completion. At the head of line, feed <tab>",
})
vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn["pum#visible"]() then
    return "<Cmd>call pum#map#insert_relative(-1)<CR>"
  else
    return "<C-h>"
  end
end, { expr = true, desc = "Select previous entry, or feed <C-h>" })

vim.keymap.set("i", "<C-n>", function()
  if vim.fn["pum#visible"]() then
    vim.fn["pum#map#insert_relative"](1)
  else
    vim.fn["ddc#map#manual_complete"]()
  end
end, { desc = "Select next entry or start completion" })
vim.keymap.set("i", "<C-p>", function()
  if vim.fn["pum#visible"]() then
    vim.fn["pum#map#insert_relative"](-1)
  else
    vim.fn["ddc#map#manual_complete"]()
  end
end, { desc = "Select previous entry or start completion" })
vim.keymap.set("i", "<C-y>", "<Cmd>call pum#map#confirm()<CR>")
vim.keymap.set("i", "<C-c>", "<Cmd>call pum#map#cancel()<CR>")

local ddc_group_id = vim.api.nvim_create_augroup("DdcMyCnf", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "PumCompleteDone",
  group = ddc_group_id,
  callback = function()
    -- https://github.com/neovim/neovim/issues/12310#issuecomment-628269290 closeされたら消してよさそう?
    -- require("notify")(vim.inspect(vim.json.decode(vim.g["pum#completed_item"].user_data.lspitem))) -- tsserverに`additionalTextEdits`があってほしいんだけど
    local completed = vim.g["pum#completed_item"]
    if completed == nil or completed.user_data == nil or completed.user_data.lspitem == nil then
      return
    end

    local lspitem = vim.json.decode(completed.user_data.lspitem)
    if lspitem.additionalTextEdits == nil then
      return
    end

    local lnum, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local bufnr = vim.api.nvim_get_current_buf()
    local edits = vim.tbl_filter(function(t)
      return t.range.start.line ~= (lnum - 1)
    end, lspitem.additionalTextEdits)
    vim.lsp.util.apply_text_edits(edits, bufnr, "utf-8")
  end,
  desc = "Apply additionalTextEdits if exists.",
})

if vim.fn.exists("g:vscode") ~= 1 then
  vim.fn["ddc#enable"]()
end
