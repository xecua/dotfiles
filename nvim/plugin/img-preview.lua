-- 画像ファイルを開いたときにvim.ui.imgで描画する(PNGのみ常に可。それ以外は、`magick` が使えるときだけPNGに変換してから)

local M = {}

local defaults = {
  magick_formats = { 'jpg', 'jpeg', 'gif', 'webp', 'avif', 'bmp', 'tif', 'tiff' },
  -- セル 1 つの縦横ピクセル比(高さ / 幅)。アスペクト比を保つ計算に使う。一般的な端末は 2 前後。
  cell_aspect = 2.0,
}

local PNG_SIGNATURE = '\137PNG\r\n\26\n'

---@type table<integer, { bytes: string, px_w?: integer, px_h?: integer, id?: integer }>
local state = {}
local cfg = vim.deepcopy(defaults)

local function be32(s, i)
  local a, b, c, d = s:byte(i, i + 3)
  return ((a * 256 + b) * 256 + c) * 256 + d
end

--- PNG の IHDR から画素数の幅・高さを取り出す。PNG でなければ nil。
local function png_size(bytes)
  if #bytes < 24 or bytes:sub(1, 8) ~= PNG_SIGNATURE then
    return nil
  end
  return be32(bytes, 17), be32(bytes, 21)
end

local function read_file(path)
  local f = io.open(path, 'rb')
  if not f then
    return nil
  end
  local data = f:read('*a')
  f:close()
  return data
end

--- magick で PNG に変換する。複数フレームの画像(GIF など)は先頭フレームを使う。失敗時は nil。
local function convert_with_magick(path)
  local res = vim.system({ 'magick', path .. '[0]', '-auto-orient', 'png:-' }, { text = false }):wait(10000)
  if res.code ~= 0 or not res.stdout or #res.stdout == 0 then
    return nil
  end
  return res.stdout
end

local function ext_of(path)
  local ext = path:match('%.([^./\\]+)$')
  return ext and ext:lower() or ''
end

--- ウィンドウ内に、アスペクト比を保って中央に収まる配置を計算する。
local function geometry(st, win)
  local pos = vim.fn.win_screenpos(win) -- { row, col }(1 始まり)
  local W = vim.api.nvim_win_get_width(win)
  local H = vim.api.nvim_win_get_height(win)
  local w, h = W, H
  if st.px_w and st.px_h and st.px_w > 0 then
    local rows_per_col = (st.px_h / st.px_w) / cfg.cell_aspect
    h = math.floor(W * rows_per_col + 0.5)
    if h > H then
      h = H
      w = math.floor(H / rows_per_col + 0.5)
    end
    w = math.max(1, math.min(w, W))
    h = math.max(1, math.min(h, H))
  end
  return {
    row = pos[1] + math.floor((H - h) / 2),
    col = pos[2] + math.floor((W - w) / 2),
    width = w,
    height = h,
  }
end

local function hide(st)
  if st.id then
    pcall(vim.ui.img.del, st.id)
    st.id = nil
  end
end

--- 現在のタブページで、そのバッファを表示しているウィンドウを返す(現在のウィンドウを優先)。
local function visible_win(buf)
  local tab = vim.api.nvim_get_current_tabpage()
  local cur = vim.api.nvim_get_current_win()
  local found
  for _, w in ipairs(vim.fn.win_findbuf(buf)) do
    if vim.api.nvim_win_get_tabpage(w) == tab then
      if w == cur then
        return w
      end
      found = found or w
    end
  end
  return found
end

local function refresh_all()
  for buf, st in pairs(state) do
    local win = vim.api.nvim_buf_is_valid(buf) and visible_win(buf) or nil
    if win then
      local geom = geometry(st, win)
      if st.id then
        vim.ui.img.set(st.id, geom)
      else
        st.id = vim.ui.img.set(st.bytes, geom)
      end
    else
      hide(st)
    end
  end
end

local scheduled = false
--- レイアウトが落ち着いてから 1 回だけ再描画する。
local function schedule_refresh()
  if scheduled then
    return
  end
  scheduled = true
  vim.schedule(function()
    scheduled = false
    refresh_all()
  end)
end

local function on_read(ev)
  local buf = ev.buf
  local path = vim.fn.fnamemodify(ev.file, ':p')

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false

  local bytes
  if ext_of(path) == 'png' then
    bytes = read_file(path)
  else
    bytes = convert_with_magick(path)
  end
  if not bytes then
    return
  end

  local px_w, px_h = png_size(bytes)
  state[buf] = { bytes = bytes, px_w = px_w, px_h = px_h }
  schedule_refresh()
end

function M.setup(opts)
  if not vim.ui or not vim.ui.img then
    return -- Neovim 0.13 未満
  end

  cfg = vim.tbl_deep_extend('force', defaults, opts or {})

  local exts = { 'png' }
  if vim.fn.executable('magick') == 1 then
    vim.list_extend(exts, cfg.magick_formats)
  end

  local patterns = {}
  for _, ext in ipairs(exts) do
    table.insert(patterns, '*.' .. ext)
    table.insert(patterns, '*.' .. ext:upper())
  end

  local group = vim.api.nvim_create_augroup('img_viewer', { clear = true })

  vim.api.nvim_create_autocmd('BufReadCmd', {
    group = group,
    pattern = patterns,
    callback = on_read,
  })

  vim.api.nvim_create_autocmd(
    { 'BufWinEnter', 'BufWinLeave', 'WinEnter', 'WinClosed', 'WinResized', 'VimResized', 'TabEnter' },
    { group = group, callback = schedule_refresh }
  )

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(ev)
      local st = state[ev.buf]
      if st then
        hide(st)
        state[ev.buf] = nil
      end
    end,
  })
end

return M
