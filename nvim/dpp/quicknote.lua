-- TODO (やりたいこと)
-- OpenをFloating Windowで
-- NewNoteAtCurrentBuffer
-- Listをvim.ui.selectで出してjumpできるようにする
-- Listでファイルの最初の1行を表示する

-- lua_add {{{
local function call_func_map(name)
    return "<Cmd>lua require('quicknote')." .. name .. "()<CR>"
end
vim.keymap.set("n", "<Leader>nn", call_func_map("ToggleNoteSigns"))
-- current line/buffer
vim.keymap.set("n", "<Leader>ne", call_func_map("NewNoteAtCurrentLine")) -- すでにあったらそっち開くみたい
vim.keymap.set("n", "<Leader>nd", call_func_map("DeleteNoteAtCurrentLine"))
vim.keymap.set("n", "<Leader>nl", call_func_map("ListNotesForCurrentBuffer"))
-- cwd
vim.keymap.set("n", "<Leader>nwe", call_func_map("NewNoteAtCWD"))
vim.keymap.set("n", "<Leader>nwd", call_func_map("DeleteNoteAtCWD"))
vim.keymap.set("n", "<Leader>nwl", call_func_map("ListNotesForCWD"))
-- }}}

-- lua_source {{{
local quicknote = require("quicknote")
quicknote.setup({
    mode = "resident",
})
quicknote.ShowNoteSigns()
-- }}}
