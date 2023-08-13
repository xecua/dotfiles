vim.g.startify_change_to_vcs_root = 1
vim.g.startify_lists = {
  { type = 'files',     header = { '   MRU' } },
  { type = 'bookmarks', header = { '   Bookmarks' } },
  { type = 'sessions',  header = { '   Sessions' } },
}
vim.g.startify_bookmarks = {
  '~',
  '~/.config/nvim',
  require("xecua.utils").get_local_config().obsidian_dir
}
