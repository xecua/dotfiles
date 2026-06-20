local function apply_to_lines(fn, opts)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    vim.api.nvim_buf_set_lines(0, opts.line1 - 1, opts.line2, false, vim.tbl_map(fn, lines))
end

-- \uXXXX / \UXXXXXXXX → 実際の文字
local function decode_unicode_escapes(line)
    return (line:gsub("\\[uU](%x+)", function(hex)
        local cp = tonumber(hex, 16)
        return cp and vim.fn.nr2char(cp, true) or ("\\u" .. hex)
    end))
end

-- 非ASCII文字 → \uXXXX / \UXXXXXXXX
local function encode_unicode_escapes(line)
    local result = {}
    local i = 1
    while i <= #line do
        local b = line:byte(i)
        if b < 0x80 then
            result[#result + 1] = line:sub(i, i)
            i = i + 1
        else
            local len = b >= 0xF0 and 4 or b >= 0xE0 and 3 or b >= 0xC0 and 2 or 1
            local cp = vim.fn.char2nr(line:sub(i, i + len - 1), true)
            result[#result + 1] = cp > 0xFFFF
                and string.format("\\U%08X", cp)
                or string.format("\\u%04X", cp)
            i = i + len
        end
    end
    return table.concat(result)
end

-- \xHH の連続をバイト列として収集し返す。マッチしない位置は { char = c } で返す。
local function collect_hex_run(line, i)
    if line:sub(i, i + 1) ~= "\\x" or not line:sub(i + 2, i + 3):match("^%x%x$") then
        return nil
    end
    local bytes = {}
    while line:sub(i, i + 1) == "\\x" and line:sub(i + 2, i + 3):match("^%x%x$") do
        bytes[#bytes + 1] = tonumber(line:sub(i + 2, i + 3), 16)
        i = i + 4
    end
    return bytes, i
end

-- \xHH … → UTF-8 バイト列として解釈（バイトをそのまま結合）
local function decode_hex_utf8(line)
    local result = {}
    local i = 1
    while i <= #line do
        local bytes, next_i = collect_hex_run(line, i)
        if bytes then
            result[#result + 1] = string.char(table.unpack(bytes))
            i = next_i
        else
            result[#result + 1] = line:sub(i, i)
            i = i + 1
        end
    end
    return table.concat(result)
end

-- \xHH … → UTF-16LE のバイト列として解釈
local function decode_hex_utf16(line)
    local result = {}
    local i = 1
    while i <= #line do
        local bytes, next_i = collect_hex_run(line, i)
        if bytes then
            local j = 1
            while j <= #bytes do
                if j + 1 > #bytes then
                    -- 奇数バイトが残った場合はそのまま残す
                    result[#result + 1] = string.format("\\x%02x", bytes[j])
                    j = j + 1
                else
                    local cp = bytes[j + 1] * 256 + bytes[j] -- little-endian
                    j = j + 2
                    -- サロゲートペア処理
                    if cp >= 0xD800 and cp <= 0xDBFF and j + 1 <= #bytes then
                        local low = bytes[j + 1] * 256 + bytes[j]
                        if low >= 0xDC00 and low <= 0xDFFF then
                            cp = 0x10000 + (cp - 0xD800) * 0x400 + (low - 0xDC00)
                            j = j + 2
                        end
                    end
                    result[#result + 1] = vim.fn.nr2char(cp, true)
                end
            end
            i = next_i
        else
            result[#result + 1] = line:sub(i, i)
            i = i + 1
        end
    end
    return table.concat(result)
end

-- 非ASCII文字 → \xHH バイト列（UTF-8エンコード済みバイトをそのまま出力）
local function encode_hex(line)
    local result = {}
    local i = 1
    while i <= #line do
        local b = line:byte(i)
        if b < 0x80 then
            result[#result + 1] = line:sub(i, i)
            i = i + 1
        else
            local len = b >= 0xF0 and 4 or b >= 0xE0 and 3 or b >= 0xC0 and 2 or 1
            for j = i, i + len - 1 do
                result[#result + 1] = string.format("\\x%02x", line:byte(j))
            end
            i = i + len
        end
    end
    return table.concat(result)
end

vim.api.nvim_create_user_command("UnicodeDecode", function(opts)
    apply_to_lines(decode_unicode_escapes, opts)
end, { range = true, desc = [[\uXXXX / \UXXXXXXXX エスケープを実際の文字に変換]] })

vim.api.nvim_create_user_command("UnicodeEncode", function(opts)
    apply_to_lines(encode_unicode_escapes, opts)
end, { range = true, desc = [[非ASCII文字を \uXXXX / \UXXXXXXXX エスケープに変換]] })

vim.api.nvim_create_user_command("HexDecode", function(opts)
    local enc = opts.args ~= "" and opts.args:lower() or "utf8"
    if enc == "utf16" or enc == "utf-16" then
        apply_to_lines(decode_hex_utf16, opts)
    else
        apply_to_lines(decode_hex_utf8, opts)
    end
end, {
    range = true,
    nargs = "?",
    complete = function()
        return { "utf8", "utf16" }
    end,
    desc = [[\xHH バイト列を UTF-8 または UTF-16LE としてデコード (引数: utf8 / utf16)]],
})

vim.api.nvim_create_user_command("HexEncode", function(opts)
    apply_to_lines(encode_hex, opts)
end, { range = true, desc = [[非ASCII文字を \xHH UTF-8バイト列に変換]] })
