local forward_search_config = {}

local os_string = require("xecua.utils").get_os_string()
if os_string == "Linux" then
    forward_search_config = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
    }
elseif os_string == "Windows" then
    forward_search_config = {
        executable = "SumatraPDF.exe", -- PATHに入れちゃうのがいいかなあ
        args = { "-reuse-instance", "%p", "-forward-search", "%f", "%l" },
    }
elseif os_string == "Darwin" then
    forward_search_config = {
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
        args = { "%l", "%p", "%f" },
    }
end

return {
    settings = {
        texlab = {
            auxDirectory = "./out",
            build = { args = {} },
            forwardSearch = forward_search_config,
        },
    },
}
