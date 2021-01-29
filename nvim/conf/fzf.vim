" fzf integration
if isdirectory('/usr/local/opt/fzf')
  " installed with homebrew
  set rtp+=/usr/local/opt/fzf
endif

nnoremap <silent> <Leader>c :Commands<CR>

" パクってきた 多すぎるしやっぱForkするか…?
let s:TYPE = {'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}
let s:min_version = '0.23.0'
let s:checked = 0

function! s:version_requirement(val, min)
  let val = split(a:val, '\.')
  let min = split(a:min, '\.')
  for idx in range(0, len(min) - 1)
    let v = get(val, idx, 0)
    if     v < min[idx] | return 0
    elseif v > min[idx] | return 1
    endif
  endfor
  return 1
endfunction


function! s:wrap(name, opts, bang)
  " fzf#wrap does not append --expect if sink or sink* is found
  let opts = copy(a:opts)
  let options = ''
  if has_key(opts, 'options')
    let options = type(opts.options) == s:TYPE.list ? join(opts.options) : opts.options
  endif
  " expectがない、かつsink*がある?
  " →一回sinkを省いてexpectをつけさせた上でsinkを戻す?
  if options !~ '--expect' && has_key(opts, 'sink*')
    let Sink = remove(opts, 'sink*')
    let wrapped = fzf#wrap(a:name, opts, a:bang)
    let wrapped['sink*'] = Sink
  else
    let wrapped = fzf#wrap(a:name, opts, a:bang)
  endif
  return wrapped
endfunction

function! s:check_requirements()
  if s:checked
    return
  endif

  if !exists('*fzf#run')
    throw "fzf#run function not found. You also need Vim plugin from the main fzf repository (i.e. junegunn/fzf *and* junegunn/fzf.vim)"
  endif
  if !exists('*fzf#exec')
    throw "fzf#exec function not found. You need to upgrade Vim plugin from the main fzf repository ('junegunn/fzf')"
  endif
  let exec = fzf#exec()
  let output = split(system(exec . ' --version'), "\n")
  if v:shell_error || empty(output)
    throw 'Failed to run "fzf --version": ' . string(output)
  endif
  let fzf_version = matchstr(output[-1], '[0-9.]\+')

  if s:version_requirement(fzf_version, s:min_version)
    let s:checked = 1
    return
  end
  throw printf('You need to upgrade fzf. Found: %s (%s). Required: %s or above.', fzf_version, exec, s:min_version)
endfunction

function! s:merge_opts(dict, eopts)
  return s:extend_opts(a:dict, a:eopts, 0)
endfunction

function! s:extend_opts(dict, eopts, prepend)
  if empty(a:eopts)
    return
  endif
  if has_key(a:dict, 'options')
    if type(a:dict.options) == s:TYPE.list && type(a:eopts) == s:TYPE.list
      if a:prepend
        let a:dict.options = extend(copy(a:eopts), a:dict.options)
      else
        call extend(a:dict.options, a:eopts)
      endif
    else
      let all_opts = a:prepend ? [a:eopts, a:dict.options] : [a:dict.options, a:eopts]
      let a:dict.options = join(map(all_opts, 'type(v:val) == s:TYPE.list ? join(map(copy(v:val), "fzf#shellescape(v:val)")) : v:val'))
    endif
  else
    let a:dict.options = a:eopts
  endif
endfunction

function! s:strip(str)
  return substitute(a:str, '^\s*\|\s*$', '', 'g')
endfunction

let s:ansi = {'black': 30, 'red': 31, 'green': 32, 'yellow': 33, 'blue': 34, 'magenta': 35, 'cyan': 36}

function! s:get_color(attr, ...)
  let gui = has('termguicolors') && &termguicolors
  let fam = gui ? 'gui' : 'cterm'
  let pat = gui ? '^#[a-f0-9]\+' : '^[0-9]\+$'
  for group in a:000
    let code = synIDattr(synIDtrans(hlID(group)), a:attr, fam)
    if code =~? pat
      return code
    endif
  endfor
  return ''
endfunction

function! s:csi(color, fg)
  let prefix = a:fg ? '38;' : '48;'
  if a:color[0] == '#'
    return prefix.'2;'.join(map([a:color[1:2], a:color[3:4], a:color[5:6]], 'str2nr(v:val, 16)'), ';')
  endif
  return prefix.'5;'.a:color
endfunction

function! s:ansi(str, group, default, ...)
  let fg = s:get_color('fg', a:group)
  let bg = s:get_color('bg', a:group)
  let color = (empty(fg) ? s:ansi[a:default] : s:csi(fg, 1)) .
      \ (empty(bg) ? '' : ';'.s:csi(bg, 0))
  return printf("\x1b[%s%sm%s\x1b[m", color, a:0 ? ';1' : '', a:str)
endfunction

for s:color_name in keys(s:ansi)
  execute "function! s:".s:color_name."(str, ...)\n"
      \ "  return s:ansi(a:str, get(a:, 1, ''), '".s:color_name."')\n"
      \ "endfunction"
endfor

let s:nbs = nr2char(0x2007)

function! s:fzf(name, opts, extra)
  call s:check_requirements()

  let [extra, bang] = [{}, 0]
  if len(a:extra) <= 1
    let first = get(a:extra, 0, 0)
    if type(first) == s:TYPE.dict
      let extra = first
    else
      let bang = first
    endif
  elseif len(a:extra) == 2
    let [extra, bang] = a:extra
  else
    throw 'invalid number of arguments'
  endif

  let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
  let merged = extend(copy(a:opts), extra)
  call s:merge_opts(merged, eopts)
  return fzf#run(s:wrap(a:name, merged, bang))
endfunction

" ここまで

function! s:command_sink(lines)
  if len(a:lines) < 2 " nothing select
    return
  endif
  let cmd = matchstr(a:lines[1], s:nbs.'\zs\S*\ze'.s:nbs)
  if empty(a:lines[0])
    " callつけるか…?
    call feedkeys(':call '.cmd.'(')
  " else
  "   call histadd(':call ', cmd)
  "   execute cmd
  endif
endfunction

function! s:format_func(line)
  let match = matchlist(a:line, 'function \(<SNR>\)\@!\(.*\)(\(.*\))\( abort\)\?')
  " なんかできるならやりたいけど
  " if empty(match[3])
  "   " no argument
  " else
  "   " have some argument
  " endif
  if !empty(match)
    return printf('   '.s:yellow('%-64s', 'Function').'%s', s:nbs.match[2].s:nbs, s:strip(match[0]))
  else
    return ''
  endif
endfunction

let s:exfunc_pattern =  '^\t\(\S\+\)()\t\+\(.*\)$'
function! s:format_exfuncs(ex)
  let match = matchlist(a:ex, s:exfunc_pattern)
  return printf('   '.s:blue('%-38s', 'Statement').'%s', s:nbs.match[1].s:nbs, s:strip(match[2]))
endfunction

" :commandで出てくるのはユーザーが:commandで定義したやつだけなのでdoc/index.txtにある組み込みコマンドを追加するのがs:excmds()
" :functionも組み込みのは出てこないのでdoc/eval.txtからひっこぬいてくる
" なんかオリジナルめちゃくちゃ回りくどくないか?
" (最初からだったっぽい(ref: https://github.com/junegunn/fzf.vim/commit/eec4a667d8f04e85035238bf3ca5c17a31b77cb2))
function! s:exfuncs()
  let help = globpath($VIMRUNTIME, 'doc/usr_41.txt')
  if empty(help)
    return []
  endif

  let functions = []
  for line in readfile(help)
    if line =~ s:exfunc_pattern
      call add(functions, s:format_exfuncs(line))
    endif
  endfor
  return functions

endfunction

function! s:functions(...)
  redir => cout
  silent function
  redir END
  let function_list = split(cout, "\n")
  return s:fzf('commands', {
      \ 'source':  extend(filter(map(function_list, 's:format_func(v:val)'), '!empty(v:val)'), s:exfuncs()),
      \ 'sink*':   function('s:command_sink'),
      \ 'options': '--ansi --expect '.get(g:, 'fzf_commands_expect', 'ctrl-x').
      \            ' --tiebreak=index --prompt "Functions> " -n2,3,2..3 -d'.s:nbs}, a:000)
endfunction

command! -bar -bang Functions :call <SID>functions(<bang>0)

