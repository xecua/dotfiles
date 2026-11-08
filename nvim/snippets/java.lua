return {
    -- 展開時にファイルのパスからパッケージ名・クラス名を決める
    function()
        local root, package = vim.fn.expand("%:p:h"):match("^(.*src/main/java/?)(.*)$")
        local body = {}
        if root ~= nil and package ~= "" then
            vim.list_extend(body, { "package " .. package:gsub("/", ".") .. ";", "" })
        end
        vim.list_extend(body, {
            "public class " .. vim.fn.expand("%:t:r") .. " {",
            "  public static void main(String[] args) {",
            "    $0",
            "  }",
            "}",
        })
        return {
            prefix = { "public", "main", "template" },
            desc = "boilerplate (public static void main)",
            body = body,
        }
    end,
}
