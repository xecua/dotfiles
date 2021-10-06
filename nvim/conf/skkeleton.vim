if dein#is_available('skkeleton')
  " これつけなければ大丈夫かもしれん
  imap <C-j> <Plug>(skkeleton-enable)
  cmap <C-j> <Plug>(skkeleton-enable)
  lmap <C-j> <Plug>(skkeleton-enable)

  let skkeleton_config = {
      \ 'eggLikeNewline': v:true,
      \ 'immediatelyCancel': v:false,
      \ 'showCandidatesCount': 1,
      \ }

  if g:os == 'Windows'
    let skkeleton_config['globalJisyo'] = $HOME..'/.skk-jisyo.L'
    let skkeleton_config['userJisyo'] = $HOME..'/.skk-jisyo'
  endif

  call skkeleton#config(skkeleton_config)

  " AZIK: currently unavailable (https://twitter.com/xecual/status/1445387050660896776)
  " call skkeleton#register_kanatable('rom', {
  "     \ ';': ['', 'っ'],
  "     \ 'b.': ['', 'ぶ'],
  "     \ 'bd': ['', 'べん'],
  "     \ 'bh': ['', 'ぶう'],
  "     \ 'bj': ['', 'ぶん'],
  "     \ 'bk': ['', 'びん'],
  "     \ 'bl': ['', 'ぼん'],
  "     \ 'bn': ['', 'ばん'],
  "     \ 'bp': ['', 'ぼう'],
  "     \ 'bq': ['', 'ばい'],
  "     \ 'br': ['', 'ばら'],
  "     \ 'bt': ['', 'びと'],
  "     \ 'bw': ['', 'べい'],
  "     \ 'bx': ['', 'べい'],
  "     \ 'byd': ['', 'びぇん'],
  "     \ 'byh': ['', 'びゅう'],
  "     \ 'byj': ['', 'びゅん'],
  "     \ 'byl': ['', 'びょん'],
  "     \ 'byn': ['', 'びゃん'],
  "     \ 'byp': ['', 'びょう'],
  "     \ 'byq': ['', 'びゃい'],
  "     \ 'byw': ['', 'びぇい'],
  "     \ 'byz': ['', 'びゃん'],
  "     \ 'bz': ['', 'ばん'],
  "     \ 'ca': ['', 'ちゃ'],
  "     \ 'cc': ['', 'ちゃ'],
  "     \ 'cd': ['', 'ちぇん'],
  "     \ 'ce': ['', 'ちぇ'],
  "     \ 'cf': ['', 'ちぇ'],
  "     \ 'ch': ['', 'ちゅう'],
  "     \ 'ci': ['', 'ち'],
  "     \ 'cj': ['', 'ちゅん'],
  "     \ 'ck': ['', 'ちん'],
  "     \ 'cl': ['', 'ちょん'],
  "     \ 'cn': ['', 'ちゃん'],
  "     \ 'co': ['', 'ちょ'],
  "     \ 'cp': ['', 'ちょう'],
  "     \ 'cq': ['', 'ちゃい'],
  "     \ 'cu': ['', 'ちゅ'],
  "     \ 'cv': ['', 'ちゃい'],
  "     \ 'cw': ['', 'ちぇい'],
  "     \ 'cx': ['', 'ちぇい'],
  "     \ 'cz': ['', 'ちゃん'],
  "     \ 'dch': ['', 'でゅー'],
  "     \ 'dci': ['', 'でぃ'],
  "     \ 'dck': ['', 'でぃん'],
  "     \ 'dcp': ['', 'どぅー'],
  "     \ 'dcu': ['', 'でゅ'],
  "     \ 'dd': ['', 'でん'],
  "     \ 'df': ['', 'で'],
  "     \ 'dg': ['', 'だが'],
  "     \ 'dh': ['', 'づう'],
  "     \ 'dj': ['', 'づん'],
  "     \ 'dk': ['', 'ぢん'],
  "     \ 'dl': ['', 'どん'],
  "     \ 'dm': ['', 'でも'],
  "     \ 'dn': ['', 'だん'],
  "     \ 'dp': ['', 'どう'],
  "     \ 'dq': ['', 'だい'],
  "     \ 'dr': ['', 'である'],
  "     \ 'ds': ['', 'です'],
  "     \ 'dt': ['', 'だち'],
  "     \ 'dv': ['', 'でん'],
  "     \ 'dw': ['', 'でい'],
  "     \ 'dy': ['', 'でぃ'],
  "     \ 'dz': ['', 'だん'],
  "     \ 'fd': ['', 'ふぇん'],
  "     \ 'fh': ['', 'ふう'],
  "     \ 'fj': ['', 'ふん'],
  "     \ 'fk': ['', 'ふぃん'],
  "     \ 'fl': ['', 'ふぉん'],
  "     \ 'fm': ['', 'ふむ'],
  "     \ 'fn': ['', 'ふぁん'],
  "     \ 'fp': ['', 'ふぉー'],
  "     \ 'fq': ['', 'ふぁい'],
  "     \ 'fr': ['', 'ふる'],
  "     \ 'fs': ['', 'ふぁい'],
  "     \ 'fw': ['', 'ふぇい'],
  "     \ 'fz': ['', 'ふぁん'],
  "     \ 'gd': ['', 'げん'],
  "     \ 'gh': ['', 'ぐう'],
  "     \ 'gj': ['', 'ぐん'],
  "     \ 'gk': ['', 'ぎん'],
  "     \ 'gl': ['', 'ごん'],
  "     \ 'gn': ['', 'がん'],
  "     \ 'gp': ['', 'ごう'],
  "     \ 'gq': ['', 'がい'],
  "     \ 'gr': ['', 'がら'],
  "     \ 'gt': ['', 'ごと'],
  "     \ 'gw': ['', 'げい'],
  "     \ 'gyd': ['', 'ぎぇん'],
  "     \ 'gyh': ['', 'ぎゅう'],
  "     \ 'gyj': ['', 'ぎゅん'],
  "     \ 'gyl': ['', 'ぎょん'],
  "     \ 'gyn': ['', 'ぎゃん'],
  "     \ 'gyp': ['', 'ぎょう'],
  "     \ 'gyq': ['', 'ぎゃい'],
  "     \ 'gyw': ['', 'ぎぇい'],
  "     \ 'gyz': ['', 'ぎゃん'],
  "     \ 'gz': ['', 'がん'],
  "     \ 'hd': ['', 'へん'],
  "     \ 'hf': ['', 'ふ'],
  "     \ 'hga': ['', 'ひゃ'],
  "     \ 'hgd': ['', 'ひぇん'],
  "     \ 'hge': ['', 'ひぇ'],
  "     \ 'hgh': ['', 'ひゅう'],
  "     \ 'hgj': ['', 'ひゅん'],
  "     \ 'hgl': ['', 'ひょん'],
  "     \ 'hgn': ['', 'ひゃん'],
  "     \ 'hgo': ['', 'ひょ'],
  "     \ 'hgp': ['', 'ひょう'],
  "     \ 'hgq': ['', 'ひゃい'],
  "     \ 'hgu': ['', 'ひゅ'],
  "     \ 'hgw': ['', 'ひぇい'],
  "     \ 'hgz': ['', 'ひゃん'],
  "     \ 'hh': ['', 'ふう'],
  "     \ 'hj': ['', 'ふん'],
  "     \ 'hk': ['', 'ひん'],
  "     \ 'hl': ['', 'ほん'],
  "     \ 'hn': ['', 'はん'],
  "     \ 'hp': ['', 'ほう'],
  "     \ 'hq': ['', 'はい'],
  "     \ 'ht': ['', 'ひと'],
  "     \ 'hw': ['', 'へい'],
  "     \ 'hyd': ['', 'ひぇん'],
  "     \ 'hyh': ['', 'ひゅう'],
  "     \ 'hyl': ['', 'ひょん'],
  "     \ 'hyp': ['', 'ひょう'],
  "     \ 'hyq': ['', 'ひゃい'],
  "     \ 'hyw': ['', 'ひぇい'],
  "     \ 'hyz': ['', 'ひゃん'],
  "     \ 'hz': ['', 'はん'],
  "     \ 'jd': ['', 'じぇん'],
  "     \ 'jf': ['', 'じゅ'],
  "     \ 'jh': ['', 'じゅう'],
  "     \ 'jj': ['', 'じゅん'],
  "     \ 'jk': ['', 'じん'],
  "     \ 'jl': ['', 'じょん'],
  "     \ 'jn': ['', 'じゃん'],
  "     \ 'jp': ['', 'じょう'],
  "     \ 'jq': ['', 'じゃい'],
  "     \ 'jv': ['', 'じゅう'],
  "     \ 'jw': ['', 'じぇい'],
  "     \ 'jz': ['', 'じゃん'],
  "     \ 'kd': ['', 'けん'],
  "     \ 'kf': ['', 'き'],
  "     \ 'kga': ['', 'きゃ'],
  "     \ 'kgd': ['', 'きぇん'],
  "     \ 'kge': ['', 'きぇ'],
  "     \ 'kgh': ['', 'きゅう'],
  "     \ 'kgl': ['', 'きょん'],
  "     \ 'kgn': ['', 'きゃん'],
  "     \ 'kgo': ['', 'きょ'],
  "     \ 'kgp': ['', 'きょう'],
  "     \ 'kgq': ['', 'きゃい'],
  "     \ 'kgu': ['', 'きゅ'],
  "     \ 'kgw': ['', 'きぇい'],
  "     \ 'kgz': ['', 'きゃん'],
  "     \ 'kh': ['', 'くう'],
  "     \ 'kj': ['', 'くん'],
  "     \ 'kk': ['', 'きん'],
  "     \ 'kl': ['', 'こん'],
  "     \ 'km': ['', 'かも'],
  "     \ 'kn': ['', 'かん'],
  "     \ 'kp': ['', 'こう'],
  "     \ 'kq': ['', 'かい'],
  "     \ 'kr': ['', 'から'],
  "     \ 'kt': ['', 'こと'],
  "     \ 'kv': ['', 'きん'],
  "     \ 'kw': ['', 'けい'],
  "     \ 'kyd': ['', 'きぇん'],
  "     \ 'kyh': ['', 'きゅう'],
  "     \ 'kyj': ['', 'きゅん'],
  "     \ 'kyl': ['', 'きょん'],
  "     \ 'kyn': ['', 'きゃん'],
  "     \ 'kyp': ['', 'きょう'],
  "     \ 'kyq': ['', 'きゃい'],
  "     \ 'kyw': ['', 'きぇい'],
  "     \ 'kyz': ['', 'きゃん'],
  "     \ 'kz': ['', 'かん'],
  "     \ 'm.': ['', 'む'],
  "     \ 'md': ['', 'めん'],
  "     \ 'mf': ['', 'む'],
  "     \ 'mga': ['', 'みゃ'],
  "     \ 'mgd': ['', 'みぇん'],
  "     \ 'mge': ['', 'みぇ'],
  "     \ 'mgh': ['', 'みゅう'],
  "     \ 'mgj': ['', 'みゅん'],
  "     \ 'mgl': ['', 'みょん'],
  "     \ 'mgn': ['', 'みゃん'],
  "     \ 'mgo': ['', 'みょ'],
  "     \ 'mgp': ['', 'みょう'],
  "     \ 'mgq': ['', 'みゃい'],
  "     \ 'mgu': ['', 'みゅ'],
  "     \ 'mgw': ['', 'みぇい'],
  "     \ 'mgz': ['', 'みゃん'],
  "     \ 'mh': ['', 'むう'],
  "     \ 'mj': ['', 'むん'],
  "     \ 'mk': ['', 'みん'],
  "     \ 'ml': ['', 'もん'],
  "     \ 'mn': ['', 'もの'],
  "     \ 'mp': ['', 'もう'],
  "     \ 'mq': ['', 'まい'],
  "     \ 'mr': ['', 'まる'],
  "     \ 'ms': ['', 'ます'],
  "     \ 'mt': ['', 'また'],
  "     \ 'mv': ['', 'むん'],
  "     \ 'mw': ['', 'めい'],
  "     \ 'myd': ['', 'みぇん'],
  "     \ 'myh': ['', 'みゅう'],
  "     \ 'myj': ['', 'みゅん'],
  "     \ 'myl': ['', 'みょん'],
  "     \ 'myn': ['', 'みゃん'],
  "     \ 'myp': ['', 'みょう'],
  "     \ 'myq': ['', 'みゃい'],
  "     \ 'myw': ['', 'みぇい'],
  "     \ 'myz': ['', 'みゃん'],
  "     \ 'mz': ['', 'まん'],
  "     \ 'n.': ['', 'ぬ'],
  "     \ 'nb': ['', 'ねば'],
  "     \ 'nd': ['', 'ねん'],
  "     \ 'nf': ['', 'ぬ'],
  "     \ 'nga': ['', 'にゃ'],
  "     \ 'ngd': ['', 'にぇん'],
  "     \ 'nge': ['', 'にぇ'],
  "     \ 'ngh': ['', 'にゅう'],
  "     \ 'ngj': ['', 'にゅん'],
  "     \ 'ngl': ['', 'にょん'],
  "     \ 'ngn': ['', 'にゃん'],
  "     \ 'ngo': ['', 'にょ'],
  "     \ 'ngp': ['', 'にょう'],
  "     \ 'ngq': ['', 'にゃい'],
  "     \ 'ngu': ['', 'にゅ'],
  "     \ 'ngw': ['', 'にぇい'],
  "     \ 'ngz': ['', 'にゃん'],
  "     \ 'nh': ['', 'ぬう'],
  "     \ 'nj': ['', 'ぬん'],
  "     \ 'nk': ['', 'にん'],
  "     \ 'nl': ['', 'のん'],
  "     \ 'np': ['', 'のう'],
  "     \ 'nq': ['', 'ない'],
  "     \ 'nr': ['', 'なる'],
  "     \ 'nt': ['', 'にち'],
  "     \ 'nv': ['', 'ぬん'],
  "     \ 'nw': ['', 'ねい'],
  "     \ 'nyd': ['', 'にぇん'],
  "     \ 'nyh': ['', 'にゅう'],
  "     \ 'nyj': ['', 'にゅん'],
  "     \ 'nyl': ['', 'にょん'],
  "     \ 'nyn': ['', 'にゃん'],
  "     \ 'nyp': ['', 'にょう'],
  "     \ 'nyq': ['', 'にゃい'],
  "     \ 'nyw': ['', 'にぇい'],
  "     \ 'nyz': ['', 'にゃん'],
  "     \ 'nz': ['', 'なん'],
  "     \ 'pd': ['', 'ぺん'],
  "     \ 'pf': ['', 'ぽん'],
  "     \ 'pga': ['', 'ぴゃ'],
  "     \ 'pgd': ['', 'ぴぇん'],
  "     \ 'pge': ['', 'ぴぇ'],
  "     \ 'pgh': ['', 'ぴゅう'],
  "     \ 'pgj': ['', 'ぴゅん'],
  "     \ 'pgl': ['', 'ぴょん'],
  "     \ 'pgn': ['', 'ぴゃん'],
  "     \ 'pgo': ['', 'ぴょ'],
  "     \ 'pgp': ['', 'ぴょう'],
  "     \ 'pgq': ['', 'ぴゃい'],
  "     \ 'pgu': ['', 'ぴゅ'],
  "     \ 'pgw': ['', 'ぴぇい'],
  "     \ 'pgz': ['', 'ぴゃん'],
  "     \ 'ph': ['', 'ぷう'],
  "     \ 'pj': ['', 'ぷん'],
  "     \ 'pk': ['', 'ぴん'],
  "     \ 'pl': ['', 'ぽん'],
  "     \ 'pn': ['', 'ぱん'],
  "     \ 'pp': ['', 'ぽう'],
  "     \ 'pq': ['', 'ぱい'],
  "     \ 'pv': ['', 'ぽう'],
  "     \ 'pw': ['', 'ぺい'],
  "     \ 'pyd': ['', 'ぴぇん'],
  "     \ 'pyh': ['', 'ぴゅう'],
  "     \ 'pyj': ['', 'ぴゅん'],
  "     \ 'pyl': ['', 'ぴょん'],
  "     \ 'pyn': ['', 'ぴゃん'],
  "     \ 'pyp': ['', 'ぴょう'],
  "     \ 'pyq': ['', 'ぴゃい'],
  "     \ 'pyw': ['', 'ぴぇい'],
  "     \ 'pyz': ['', 'ぴゃん'],
  "     \ 'pz': ['', 'ぱん'],
  "     \ 'q': ['', 'ん'],
  "     \ 'rd': ['', 'れん'],
  "     \ 'rh': ['', 'るう'],
  "     \ 'rj': ['', 'るん'],
  "     \ 'rk': ['', 'りん'],
  "     \ 'rl': ['', 'ろん'],
  "     \ 'rn': ['', 'らん'],
  "     \ 'rp': ['', 'ろう'],
  "     \ 'rq': ['', 'らい'],
  "     \ 'rr': ['', 'られ'],
  "     \ 'rw': ['', 'れい'],
  "     \ 'ryd': ['', 'りぇん'],
  "     \ 'ryh': ['', 'りゅう'],
  "     \ 'ryj': ['', 'りゅん'],
  "     \ 'ryk': ['', 'りょく'],
  "     \ 'ryl': ['', 'りょん'],
  "     \ 'ryn': ['', 'りゃん'],
  "     \ 'ryp': ['', 'りょう'],
  "     \ 'ryq': ['', 'りゃい'],
  "     \ 'ryw': ['', 'りぇい'],
  "     \ 'ryz': ['', 'りゃん'],
  "     \ 'rz': ['', 'らん'],
  "     \ 'sd': ['', 'せん'],
  "     \ 'sf': ['', 'さい'],
  "     \ 'sh': ['', 'すう'],
  "     \ 'sj': ['', 'すん'],
  "     \ 'sk': ['', 'しん'],
  "     \ 'sl': ['', 'そん'],
  "     \ 'sm': ['', 'しも'],
  "     \ 'sn': ['', 'さん'],
  "     \ 'sp': ['', 'そう'],
  "     \ 'sq': ['', 'さい'],
  "     \ 'sr': ['', 'する'],
  "     \ 'ss': ['', 'せい'],
  "     \ 'st': ['', 'した'],
  "     \ 'sv': ['', 'さい'],
  "     \ 'sw': ['', 'せい'],
  "     \ 'syd': ['', 'しぇん'],
  "     \ 'syh': ['', 'しゅう'],
  "     \ 'syj': ['', 'しゅん'],
  "     \ 'syl': ['', 'しょん'],
  "     \ 'syp': ['', 'しょう'],
  "     \ 'syq': ['', 'しゃい'],
  "     \ 'syw': ['', 'しぇい'],
  "     \ 'syz': ['', 'しゃん'],
  "     \ 'sz': ['', 'さん'],
  "     \ 'tU': ['', 'っ'],
  "     \ 'tb': ['', 'たび'],
  "     \ 'td': ['', 'てん'],
  "     \ 'tgh': ['', 'てゅー'],
  "     \ 'tgi': ['', 'てぃ'],
  "     \ 'tgk': ['', 'てぃん'],
  "     \ 'tgp': ['', 'とぅー'],
  "     \ 'tgu': ['', 'てゅ'],
  "     \ 'th': ['', 'つう'],
  "     \ 'tj': ['', 'つん'],
  "     \ 'tk': ['', 'ちん'],
  "     \ 'tl': ['', 'とん'],
  "     \ 'tm': ['', 'ため'],
  "     \ 'tn': ['', 'たん'],
  "     \ 'tp': ['', 'とう'],
  "     \ 'tq': ['', 'たい'],
  "     \ 'tr': ['', 'たら'],
  "     \ 'tsU': ['', 'っ'],
  "     \ 'tsa': ['', 'つぁ'],
  "     \ 'tse': ['', 'つぇ'],
  "     \ 'tsi': ['', 'つぃ'],
  "     \ 'tso': ['', 'つぉ'],
  "     \ 'tt': ['', 'たち'],
  "     \ 'tw': ['', 'てい'],
  "     \ 'tyd': ['', 'ちぇん'],
  "     \ 'tyh': ['', 'ちゅう'],
  "     \ 'tyj': ['', 'ちゅん'],
  "     \ 'tyl': ['', 'ちょん'],
  "     \ 'tyn': ['', 'ちゃん'],
  "     \ 'typ': ['', 'ちょう'],
  "     \ 'tyq': ['', 'ちゃい'],
  "     \ 'tyw': ['', 'ちぇい'],
  "     \ 'tyz': ['', 'ちゃん'],
  "     \ 'tz': ['', 'たん'],
  "     \ 'vd': ['', 'う゛ぇん'],
  "     \ 'vk': ['', 'う゛ぃん'],
  "     \ 'vl': ['', 'う゛ぉん'],
  "     \ 'vn': ['', 'う゛ぁん'],
  "     \ 'vp': ['', 'う゛ぉー'],
  "     \ 'vq': ['', 'う゛ぁい'],
  "     \ 'vw': ['', 'う゛ぇい'],
  "     \ 'vya': ['', 'う゛ゃ'],
  "     \ 'vye': ['', 'う゛ぇ'],
  "     \ 'vyo': ['', 'う゛ょ'],
  "     \ 'vyu': ['', 'う゛ゅ'],
  "     \ 'vz': ['', 'う゛ぁん'],
  "     \ 'wA': ['', 'ゎ'],
  "     \ 'wd': ['', 'うぇん'],
  "     \ 'wf': ['', 'わい'],
  "     \ 'wha': ['', 'うぁ'],
  "     \ 'whe': ['', 'うぇ'],
  "     \ 'whi': ['', 'うぃ'],
  "     \ 'who': ['', 'うぉ'],
  "     \ 'whu': ['', 'う'],
  "     \ 'wk': ['', 'うぃん'],
  "     \ 'wl': ['', 'うぉん'],
  "     \ 'wn': ['', 'わん'],
  "     \ 'wp': ['', 'うぉー'],
  "     \ 'wq': ['', 'わい'],
  "     \ 'wr': ['', 'われ'],
  "     \ 'wso': ['', 'うぉ'],
  "     \ 'wt': ['', 'わた'],
  "     \ 'wz': ['', 'わん'],
  "     \ 'x;': ['', ';'],
  "     \ 'xa': ['', 'しゃ'],
  "     \ 'xc': ['', 'しゃ'],
  "     \ 'xd': ['', 'しぇん'],
  "     \ 'xe': ['', 'しぇ'],
  "     \ 'xf': ['', 'しぇい'],
  "     \ 'xh': ['', 'しゅう'],
  "     \ 'xi': ['', 'し'],
  "     \ 'xj': ['', 'しゅん'],
  "     \ 'xk': ['', 'しん'],
  "     \ 'xl': ['', 'しょん'],
  "     \ 'xn': ['', 'しゃん'],
  "     \ 'xo': ['', 'しょ'],
  "     \ 'xp': ['', 'しょう'],
  "     \ 'xq': ['', 'しゃい'],
  "     \ 'xt': ['', 'しゅつ'],
  "     \ 'xu': ['', 'しゅ'],
  "     \ 'xv': ['', 'しゃい'],
  "     \ 'xw': ['', 'しぇい'],
  "     \ 'xxa': ['', 'ぁ'],
  "     \ 'xxe': ['', 'ぇ'],
  "     \ 'xxh': ['', '←'],
  "     \ 'xxi': ['', 'ぃ'],
  "     \ 'xxj': ['', '↓'],
  "     \ 'xxk': ['', '↑'],
  "     \ 'xxl': ['', '→'],
  "     \ 'xxo': ['', 'ぉ'],
  "     \ 'xxu': ['', 'ぅ'],
  "     \ 'xz': ['', 'しゃん'],
  "     \ 'y<': ['', '←'],
  "     \ 'y>': ['', '→'],
  "     \ 'y^': ['', '↑'],
  "     \ 'yf': ['', 'ゆ'],
  "     \ 'yh': ['', 'ゆう'],
  "     \ 'yi': ['', 'ゐ'],
  "     \ 'yj': ['', 'ゆん'],
  "     \ 'yl': ['', 'よん'],
  "     \ 'yn': ['', 'やん'],
  "     \ 'yp': ['', 'よう'],
  "     \ 'yq': ['', 'やい'],
  "     \ 'yr': ['', 'よる'],
  "     \ 'yv': ['', 'ゆう'],
  "     \ 'yz': ['', 'やん'],
  "     \ 'z.': ['', '…'],
  "     \ 'zc': ['', 'ざ'],
  "     \ 'zd': ['', 'ぜん'],
  "     \ 'zf': ['', 'ぜ'],
  "     \ 'zh': ['', 'ずう'],
  "     \ 'zj': ['', 'ずん'],
  "     \ 'zk': ['', 'じん'],
  "     \ 'zl': ['', 'ぞん'],
  "     \ 'zn': ['', 'ざん'],
  "     \ 'zp': ['', 'ぞう'],
  "     \ 'zq': ['', 'ざい'],
  "     \ 'zr': ['', 'ざる'],
  "     \ 'zv': ['', 'ざい'],
  "     \ 'zw': ['', 'ぜい'],
  "     \ 'zx': ['', 'ぜい'],
  "     \ 'zyd': ['', 'じぇん'],
  "     \ 'zyh': ['', 'じゅう'],
  "     \ 'zyj': ['', 'じゅん'],
  "     \ 'zyl': ['', 'じょん'],
  "     \ 'zyn': ['', 'じゃん'],
  "     \ 'zyp': ['', 'じょう'],
  "     \ 'zyq': ['', 'じゃい'],
  "     \ 'zyw': ['', 'じぇい'],
  "     \ 'zyz': ['', 'じゃん'],
  "     \ 'zz': ['', 'ざん']
  "     \ })
endif
