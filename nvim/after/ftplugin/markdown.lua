vim.opt_local.comments = ""
for _, marker in ipairs({ "+", "-", "*", "1." }) do
  vim.opt_local.comments:prepend({
    "b:" .. marker .. [=[\ [\ ]]=],
    "b:" .. marker .. [=[\ [x]]=],
    "b:" .. marker,
  })
end

vim.opt_local.comments:prepend({ "nb:>" })
