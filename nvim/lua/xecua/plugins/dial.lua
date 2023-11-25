local map = require('dial.map')
local config = require('dial.config')
local augend = require('dial.augend')

vim.keymap.set('n', '<C-a>', map.inc_normal(), { noremap = true })
vim.keymap.set('n', '<C-x>', map.dec_normal(), { noremap = true })
vim.keymap.set('n', 'g<C-a>', map.inc_gnormal(), { noremap = true })
vim.keymap.set('n', 'g<C-x>', map.dec_gnormal(), { noremap = true })
vim.keymap.set('v', '<C-a>', map.inc_visual(), { noremap = true })
vim.keymap.set('v', '<C-x>', map.dec_visual(), { noremap = true })
vim.keymap.set('v', 'g<C-a>', map.inc_gvisual(), { noremap = true })
vim.keymap.set('v', 'g<C-x>', map.dec_gvisual(), { noremap = true })

local Bool = augend.constant.new({
  elements = { 'True', 'False' },
  word = true,
  cyclic = true,
})

config.augends:register_group({
  default = {
    augend.integer.alias.decimal_int,
    augend.integer.alias.hex,
    augend.date.alias['%Y/%m/%d'],
    augend.date.alias['%Y-%m-%d'],
    augend.date.alias['%m/%d'],
    augend.date.alias['%H:%M'],
    augend.constant.alias.bool,
    Bool,
    augend.constant.alias.alpha,
    augend.constant.alias.Alpha,
    augend.constant.alias.ja_weekday_full,
  },
})
