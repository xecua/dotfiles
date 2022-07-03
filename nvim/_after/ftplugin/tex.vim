" lexima options for TeX
call lexima#add_rule({'char': '(', 'at': '\\\%#', 'input_after': '\)'})
call lexima#add_rule({'char': '[', 'at':'\\\%#', 'input_after': '\]'})
call lexima#add_rule({'char': '`', 'at': '`\%#', 'input_after': ''''''})
call lexima#add_rule({'char': '`', 'at': '`\%#`', 'input': '<right>''''<left><left>'})
