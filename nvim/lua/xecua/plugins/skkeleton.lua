-- neovide: use ui
local M = {}

function M.should_use_skkeleton()
  return vim.g.neovide ~= nil or vim.env.DISPLAY == nil
end

if M.should_use_skkeleton() then
  vim.keymap.set({ 'i', 'c', 'l' }, '<C-j>', '<Plug>(skkeleton-enable)')
end

-- TODO: 一般的なazikの挙動に寄せる
vim.fn['skkeleton#register_keymap']('input', "'", 'henkanPoint') -- 暫定処置としてsticky keyを使うといいのでは?
-- + 半角カタカナモードで\を入力したらかなモードに移行する(azik/hankaku-katakana.json)
-- + latin/wide-latinでC-jを入力したらかなモードに移行する(default/(wide-)?latin.json)
--   + モード切り替えがハードコードなので、C-jがマップされたとしても↓には戻せない そうなると一旦disableする方が合理的なのかも(roadmapに直接入力モードあるのでやる気はあるのかもしれない)
--   + insert-charもそうだけど、関数にも引数を与えたい (というPRあるいはissueを立てるのはアリかも?)
vim.fn['skkeleton#register_kanatable']('azik', {
  [' '] = 'henkanFirst',
  ['/'] = 'abbrev',
  ['<s-l>'] = 'zenkaku',
  [';'] = { 'っ' },
  [':'] = 'upper-;',
  ['['] = 'katakana',
  ['x['] = { '「' },
  ['!'] = { '！' },
  ['?'] = { '？' },
  [','] = { '、' },
  ['.'] = { '。' },
  ['-'] = { 'ー' },
  [']'] = { '」' },
  ['l'] = 'disable',
  ['a'] = { 'あ' },
  ['ba'] = { 'ば' },
  ['be'] = { 'べ' },
  ['bi'] = { 'び' },
  ['bo'] = { 'ぼ' },
  ['bu'] = { 'ぶ' },
  ['bya'] = { 'びゃ' },
  ['bye'] = { 'びぇ' },
  ['byi'] = { 'びぃ' },
  ['byo'] = { 'びょ' },
  ['byu'] = { 'びゅ' },
  ['b.'] = { 'ぶ' },
  ['bd'] = { 'べん' },
  ['bh'] = { 'ぶう' },
  ['bj'] = { 'ぶん' },
  ['bk'] = { 'びん' },
  ['bl'] = { 'ぼん' },
  ['bn'] = { 'ばん' },
  ['bp'] = { 'ぼう' },
  ['bq'] = { 'ばい' },
  ['br'] = { 'ばら' },
  ['bt'] = { 'びと' },
  ['bw'] = { 'べい' },
  ['bx'] = { 'べい' },
  ['byd'] = { 'びぇん' },
  ['byh'] = { 'びゅう' },
  ['byj'] = { 'びゅん' },
  ['byl'] = { 'びょん' },
  ['byn'] = { 'びゃん' },
  ['byp'] = { 'びょう' },
  ['byq'] = { 'びゃい' },
  ['byw'] = { 'びぇい' },
  ['byz'] = { 'びゃん' },
  ['bz'] = { 'ばん' },
  ['ca'] = { 'ちゃ' },
  ['cc'] = { 'ちゃ' },
  ['cd'] = { 'ちぇん' },
  ['ce'] = { 'ちぇ' },
  ['cf'] = { 'ちぇ' },
  ['ch'] = { 'ちゅう' },
  ['ci'] = { 'ち' },
  ['cj'] = { 'ちゅん' },
  ['ck'] = { 'ちん' },
  ['cl'] = { 'ちょん' },
  ['cn'] = { 'ちゃん' },
  ['co'] = { 'ちょ' },
  ['cp'] = { 'ちょう' },
  ['cq'] = { 'ちゃい' },
  ['cu'] = { 'ちゅ' },
  ['cv'] = { 'ちゃい' },
  ['cw'] = { 'ちぇい' },
  ['cx'] = { 'ちぇい' },
  ['cz'] = { 'ちゃん' },
  ['cya'] = { 'ちゃ' },
  ['cye'] = { 'ちぇ' },
  ['cyi'] = { 'ちぃ' },
  ['cyo'] = { 'ちょ' },
  ['cyu'] = { 'ちゅ' },
  ['da'] = { 'だ' },
  ['de'] = { 'で' },
  ['di'] = { 'ぢ' },
  ['do'] = { 'ど' },
  ['du'] = { 'づ' },
  ['dya'] = { 'ぢゃ' },
  ['dye'] = { 'ぢぇ' },
  ['dyi'] = { 'ぢぃ' },
  ['dyo'] = { 'ぢょ' },
  ['dyu'] = { 'ぢゅ' },
  ['dd'] = { 'でん' },
  ['df'] = { 'で' },
  ['dg'] = { 'だが' },
  ['dh'] = { 'づう' },
  ['dj'] = { 'づん' },
  ['dk'] = { 'ぢん' },
  ['dl'] = { 'どん' },
  ['dm'] = { 'でも' },
  ['dn'] = { 'だん' },
  ['dp'] = { 'どう' },
  ['dq'] = { 'だい' },
  ['dr'] = { 'である' },
  ['ds'] = { 'です' },
  ['dt'] = { 'だち' },
  ['dv'] = { 'でん' },
  ['dw'] = { 'でい' },
  ['dy'] = { 'でぃ' },
  ['dz'] = { 'だん' },
  ['dch'] = { 'でゅー' },
  ['dci'] = { 'でぃ' },
  ['dck'] = { 'でぃん' },
  ['dcp'] = { 'どぅー' },
  ['dcu'] = { 'でゅ' },
  ['e'] = { 'え' },
  ['fa'] = { 'ふぁ' },
  ['fe'] = { 'ふぇ' },
  ['fi'] = { 'ふぃ' },
  ['fo'] = { 'ふぉ' },
  ['fu'] = { 'ふ' },
  ['fya'] = { 'ふゃ' },
  ['fye'] = { 'ふぇ' },
  ['fyi'] = { 'ふぃ' },
  ['fyo'] = { 'ふょ' },
  ['fyu'] = { 'ふゅ' },
  ['fd'] = { 'ふぇん' },
  ['fh'] = { 'ふう' },
  ['fj'] = { 'ふん' },
  ['fk'] = { 'ふぃん' },
  ['fl'] = { 'ふぉん' },
  ['fm'] = { 'ふむ' },
  ['fn'] = { 'ふぁん' },
  ['fp'] = { 'ふぉー' },
  ['fq'] = { 'ふぁい' },
  ['fr'] = { 'ふる' },
  ['fs'] = { 'ふぁい' },
  ['fw'] = { 'ふぇい' },
  ['fz'] = { 'ふぁん' },
  ['ga'] = { 'が' },
  ['ge'] = { 'げ' },
  ['gi'] = { 'ぎ' },
  ['go'] = { 'ご' },
  ['gu'] = { 'ぐ' },
  ['gya'] = { 'ぎゃ' },
  ['gye'] = { 'ぎぇ' },
  ['gyi'] = { 'ぎぃ' },
  ['gyo'] = { 'ぎょ' },
  ['gyu'] = { 'ぎゅ' },
  ['gd'] = { 'げん' },
  ['gh'] = { 'ぐう' },
  ['gj'] = { 'ぐん' },
  ['gk'] = { 'ぎん' },
  ['gl'] = { 'ごん' },
  ['gn'] = { 'がん' },
  ['gp'] = { 'ごう' },
  ['gq'] = { 'がい' },
  ['gr'] = { 'がら' },
  ['gt'] = { 'ごと' },
  ['gw'] = { 'げい' },
  ['gyd'] = { 'ぎぇん' },
  ['gyh'] = { 'ぎゅう' },
  ['gyj'] = { 'ぎゅん' },
  ['gyl'] = { 'ぎょん' },
  ['gyn'] = { 'ぎゃん' },
  ['gyp'] = { 'ぎょう' },
  ['gyq'] = { 'ぎゃい' },
  ['gyw'] = { 'ぎぇい' },
  ['gyz'] = { 'ぎゃん' },
  ['gz'] = { 'がん' },
  ['ha'] = { 'は' },
  ['he'] = { 'へ' },
  ['hi'] = { 'ひ' },
  ['ho'] = { 'ほ' },
  ['hu'] = { 'ふ' },
  ['hya'] = { 'ひゃ' },
  ['hye'] = { 'ひぇ' },
  ['hyi'] = { 'ひぃ' },
  ['hyo'] = { 'ひょ' },
  ['hyu'] = { 'ひゅ' },
  ['hd'] = { 'へん' },
  ['hf'] = { 'ふ' },
  ['hga'] = { 'ひゃ' },
  ['hgd'] = { 'ひぇん' },
  ['hge'] = { 'ひぇ' },
  ['hgh'] = { 'ひゅう' },
  ['hgj'] = { 'ひゅん' },
  ['hgl'] = { 'ひょん' },
  ['hgn'] = { 'ひゃん' },
  ['hgo'] = { 'ひょ' },
  ['hgp'] = { 'ひょう' },
  ['hgq'] = { 'ひゃい' },
  ['hgu'] = { 'ひゅ' },
  ['hgw'] = { 'ひぇい' },
  ['hgz'] = { 'ひゃん' },
  ['hh'] = { 'ふう' },
  ['hj'] = { 'ふん' },
  ['hk'] = { 'ひん' },
  ['hl'] = { 'ほん' },
  ['hn'] = { 'はん' },
  ['hp'] = { 'ほう' },
  ['hq'] = { 'はい' },
  ['ht'] = { 'ひと' },
  ['hw'] = { 'へい' },
  ['hyd'] = { 'ひぇん' },
  ['hyh'] = { 'ひゅう' },
  ['hyl'] = { 'ひょん' },
  ['hyp'] = { 'ひょう' },
  ['hyq'] = { 'ひゃい' },
  ['hyw'] = { 'ひぇい' },
  ['hyz'] = { 'ひゃん' },
  ['hz'] = { 'はん' },
  ['i'] = { 'い' },
  ['ja'] = { 'じゃ' },
  ['je'] = { 'じぇ' },
  ['ji'] = { 'じ' },
  ['jo'] = { 'じょ' },
  ['ju'] = { 'じゅ' },
  ['jya'] = { 'じゃ' },
  ['jye'] = { 'じぇ' },
  ['jyi'] = { 'じぃ' },
  ['jyo'] = { 'じょ' },
  ['jyu'] = { 'じゅ' },
  ['jd'] = { 'じぇん' },
  ['jf'] = { 'じゅ' },
  ['jh'] = { 'じゅう' },
  ['jj'] = { 'じゅん' },
  ['jk'] = { 'じん' },
  ['jl'] = { 'じょん' },
  ['jn'] = { 'じゃん' },
  ['jp'] = { 'じょう' },
  ['jq'] = { 'じゃい' },
  ['jv'] = { 'じゅう' },
  ['jw'] = { 'じぇい' },
  ['jz'] = { 'じゃん' },
  ['ka'] = { 'か' },
  ['ke'] = { 'け' },
  ['ki'] = { 'き' },
  ['ko'] = { 'こ' },
  ['ku'] = { 'く' },
  ['kya'] = { 'きゃ' },
  ['kye'] = { 'きぇ' },
  ['kyi'] = { 'きぃ' },
  ['kyo'] = { 'きょ' },
  ['kyu'] = { 'きゅ' },
  ['kd'] = { 'けん' },
  ['kf'] = { 'き' },
  ['kga'] = { 'きゃ' },
  ['kgd'] = { 'きぇん' },
  ['kge'] = { 'きぇ' },
  ['kgh'] = { 'きゅう' },
  ['kgl'] = { 'きょん' },
  ['kgn'] = { 'きゃん' },
  ['kgo'] = { 'きょ' },
  ['kgp'] = { 'きょう' },
  ['kgq'] = { 'きゃい' },
  ['kgu'] = { 'きゅ' },
  ['kgw'] = { 'きぇい' },
  ['kgz'] = { 'きゃん' },
  ['kh'] = { 'くう' },
  ['kj'] = { 'くん' },
  ['kk'] = { 'きん' },
  ['kl'] = { 'こん' },
  ['km'] = { 'かも' },
  ['kn'] = { 'かん' },
  ['kp'] = { 'こう' },
  ['kq'] = { 'かい' },
  ['kr'] = { 'から' },
  ['kt'] = { 'こと' },
  ['kv'] = { 'きん' },
  ['kw'] = { 'けい' },
  ['kyd'] = { 'きぇん' },
  ['kyh'] = { 'きゅう' },
  ['kyj'] = { 'きゅん' },
  ['kyl'] = { 'きょん' },
  ['kyn'] = { 'きゃん' },
  ['kyp'] = { 'きょう' },
  ['kyq'] = { 'きゃい' },
  ['kyw'] = { 'きぇい' },
  ['kyz'] = { 'きゃん' },
  ['kz'] = { 'かん' },
  ['ma'] = { 'ま' },
  ['me'] = { 'め' },
  ['mi'] = { 'み' },
  ['mo'] = { 'も' },
  ['mu'] = { 'む' },
  ['mya'] = { 'みゃ' },
  ['mye'] = { 'みぇ' },
  ['myi'] = { 'みぃ' },
  ['myo'] = { 'みょ' },
  ['myu'] = { 'みゅ' },
  ['m.'] = { 'む' },
  ['md'] = { 'めん' },
  ['mf'] = { 'む' },
  ['mga'] = { 'みゃ' },
  ['mgd'] = { 'みぇん' },
  ['mge'] = { 'みぇ' },
  ['mgh'] = { 'みゅう' },
  ['mgj'] = { 'みゅん' },
  ['mgl'] = { 'みょん' },
  ['mgn'] = { 'みゃん' },
  ['mgo'] = { 'みょ' },
  ['mgp'] = { 'みょう' },
  ['mgq'] = { 'みゃい' },
  ['mgu'] = { 'みゅ' },
  ['mgw'] = { 'みぇい' },
  ['mgz'] = { 'みゃん' },
  ['mh'] = { 'むう' },
  ['mj'] = { 'むん' },
  ['mk'] = { 'みん' },
  ['ml'] = { 'もん' },
  ['mn'] = { 'もの' },
  ['mp'] = { 'もう' },
  ['mq'] = { 'まい' },
  ['mr'] = { 'まる' },
  ['ms'] = { 'ます' },
  ['mt'] = { 'また' },
  ['mv'] = { 'むん' },
  ['mw'] = { 'めい' },
  ['myd'] = { 'みぇん' },
  ['myh'] = { 'みゅう' },
  ['myj'] = { 'みゅん' },
  ['myl'] = { 'みょん' },
  ['myn'] = { 'みゃん' },
  ['myp'] = { 'みょう' },
  ['myq'] = { 'みゃい' },
  ['myw'] = { 'みぇい' },
  ['myz'] = { 'みゃん' },
  ['mz'] = { 'まん' },
  ['n'] = { 'ん' },
  ['na'] = { 'な' },
  ['ne'] = { 'ね' },
  ['ni'] = { 'に' },
  ['nn'] = { 'ん' },
  ['no'] = { 'の' },
  ['nu'] = { 'ぬ' },
  ['nya'] = { 'にゃ' },
  ['nye'] = { 'にぇ' },
  ['nyi'] = { 'にぃ' },
  ['nyo'] = { 'にょ' },
  ['nyu'] = { 'にゅ' },
  ['n.'] = { 'ぬ' },
  ['nb'] = { 'ねば' },
  ['nd'] = { 'ねん' },
  ['nf'] = { 'ぬ' },
  ['nga'] = { 'にゃ' },
  ['ngd'] = { 'にぇん' },
  ['nge'] = { 'にぇ' },
  ['ngh'] = { 'にゅう' },
  ['ngj'] = { 'にゅん' },
  ['ngl'] = { 'にょん' },
  ['ngn'] = { 'にゃん' },
  ['ngo'] = { 'にょ' },
  ['ngp'] = { 'にょう' },
  ['ngq'] = { 'にゃい' },
  ['ngu'] = { 'にゅ' },
  ['ngw'] = { 'にぇい' },
  ['ngz'] = { 'にゃん' },
  ['nh'] = { 'ぬう' },
  ['nj'] = { 'ぬん' },
  ['nk'] = { 'にん' },
  ['nl'] = { 'のん' },
  ['np'] = { 'のう' },
  ['nq'] = { 'ない' },
  ['nr'] = { 'なる' },
  ['nt'] = { 'にち' },
  ['nv'] = { 'ぬん' },
  ['nw'] = { 'ねい' },
  ['nyd'] = { 'にぇん' },
  ['nyh'] = { 'にゅう' },
  ['nyj'] = { 'にゅん' },
  ['nyl'] = { 'にょん' },
  ['nyn'] = { 'にゃん' },
  ['nyp'] = { 'にょう' },
  ['nyq'] = { 'にゃい' },
  ['nyw'] = { 'にぇい' },
  ['nyz'] = { 'にゃん' },
  ['nz'] = { 'なん' },
  ['o'] = { 'お' },
  ['pa'] = { 'ぱ' },
  ['pe'] = { 'ぺ' },
  ['pi'] = { 'ぴ' },
  ['po'] = { 'ぽ' },
  ['pu'] = { 'ぷ' },
  ['pya'] = { 'ぴゃ' },
  ['pye'] = { 'ぴぇ' },
  ['pyi'] = { 'ぴぃ' },
  ['pyo'] = { 'ぴょ' },
  ['pyu'] = { 'ぴゅ' },
  ['pd'] = { 'ぺん' },
  ['pf'] = { 'ぽん' },
  ['pga'] = { 'ぴゃ' },
  ['pgd'] = { 'ぴぇん' },
  ['pge'] = { 'ぴぇ' },
  ['pgh'] = { 'ぴゅう' },
  ['pgj'] = { 'ぴゅん' },
  ['pgl'] = { 'ぴょん' },
  ['pgn'] = { 'ぴゃん' },
  ['pgo'] = { 'ぴょ' },
  ['pgp'] = { 'ぴょう' },
  ['pgq'] = { 'ぴゃい' },
  ['pgu'] = { 'ぴゅ' },
  ['pgw'] = { 'ぴぇい' },
  ['pgz'] = { 'ぴゃん' },
  ['ph'] = { 'ぷう' },
  ['pj'] = { 'ぷん' },
  ['pk'] = { 'ぴん' },
  ['pl'] = { 'ぽん' },
  ['pn'] = { 'ぱん' },
  ['pp'] = { 'ぽう' },
  ['pq'] = { 'ぱい' },
  ['pv'] = { 'ぽう' },
  ['pw'] = { 'ぺい' },
  ['pyd'] = { 'ぴぇん' },
  ['pyh'] = { 'ぴゅう' },
  ['pyj'] = { 'ぴゅん' },
  ['pyl'] = { 'ぴょん' },
  ['pyn'] = { 'ぴゃん' },
  ['pyp'] = { 'ぴょう' },
  ['pyq'] = { 'ぴゃい' },
  ['pyw'] = { 'ぴぇい' },
  ['pyz'] = { 'ぴゃん' },
  ['pz'] = { 'ぱん' },
  ['q'] = { 'ん' },
  ['ra'] = { 'ら' },
  ['re'] = { 'れ' },
  ['ri'] = { 'り' },
  ['ro'] = { 'ろ' },
  ['ru'] = { 'る' },
  ['rya'] = { 'りゃ' },
  ['rye'] = { 'りぇ' },
  ['ryi'] = { 'りぃ' },
  ['ryo'] = { 'りょ' },
  ['ryu'] = { 'りゅ' },
  ['rd'] = { 'れん' },
  ['rh'] = { 'るう' },
  ['rj'] = { 'るん' },
  ['rk'] = { 'りん' },
  ['rl'] = { 'ろん' },
  ['rn'] = { 'らん' },
  ['rp'] = { 'ろう' },
  ['rq'] = { 'らい' },
  ['rr'] = { 'られ' },
  ['rw'] = { 'れい' },
  ['ryd'] = { 'りぇん' },
  ['ryh'] = { 'りゅう' },
  ['ryj'] = { 'りゅん' },
  ['ryk'] = { 'りょく' },
  ['ryl'] = { 'りょん' },
  ['ryn'] = { 'りゃん' },
  ['ryp'] = { 'りょう' },
  ['ryq'] = { 'りゃい' },
  ['ryw'] = { 'りぇい' },
  ['ryz'] = { 'りゃん' },
  ['rz'] = { 'らん' },
  ['sa'] = { 'さ' },
  ['se'] = { 'せ' },
  ['si'] = { 'し' },
  ['so'] = { 'そ' },
  ['su'] = { 'す' },
  ['sya'] = { 'しゃ' },
  ['sye'] = { 'しぇ' },
  ['syi'] = { 'しぃ' },
  ['syo'] = { 'しょ' },
  ['syu'] = { 'しゅ' },
  ['sd'] = { 'せん' },
  ['sf'] = { 'さい' },
  ['sh'] = { 'すう' },
  ['sj'] = { 'すん' },
  ['sk'] = { 'しん' },
  ['sl'] = { 'そん' },
  ['sm'] = { 'しも' },
  ['sn'] = { 'さん' },
  ['sp'] = { 'そう' },
  ['sq'] = { 'さい' },
  ['sr'] = { 'する' },
  ['ss'] = { 'せい' },
  ['st'] = { 'した' },
  ['sv'] = { 'さい' },
  ['sw'] = { 'せい' },
  ['syd'] = { 'しぇん' },
  ['syh'] = { 'しゅう' },
  ['syj'] = { 'しゅん' },
  ['syl'] = { 'しょん' },
  ['syp'] = { 'しょう' },
  ['syq'] = { 'しゃい' },
  ['syw'] = { 'しぇい' },
  ['syz'] = { 'しゃん' },
  ['sz'] = { 'さん' },
  ['ta'] = { 'た' },
  ['te'] = { 'て' },
  ['ti'] = { 'ち' },
  ['to'] = { 'と' },
  ['tsu'] = { 'つ' },
  ['tu'] = { 'つ' },
  ['tya'] = { 'ちゃ' },
  ['tye'] = { 'ちぇ' },
  ['tyi'] = { 'ちぃ' },
  ['tyo'] = { 'ちょ' },
  ['tyu'] = { 'ちゅ' },
  ['tb'] = { 'たび' },
  ['td'] = { 'てん' },
  ['tgh'] = { 'てゅー' },
  ['tgi'] = { 'てぃ' },
  ['tgk'] = { 'てぃん' },
  ['tgp'] = { 'とぅー' },
  ['tgu'] = { 'てゅ' },
  ['th'] = { 'つう' },
  ['tj'] = { 'つん' },
  ['tk'] = { 'ちん' },
  ['tl'] = { 'とん' },
  ['tm'] = { 'ため' },
  ['tn'] = { 'たん' },
  ['tp'] = { 'とう' },
  ['tq'] = { 'たい' },
  ['tr'] = { 'たら' },
  ['tsa'] = { 'つぁ' },
  ['tse'] = { 'つぇ' },
  ['tsi'] = { 'つぃ' },
  ['tso'] = { 'つぉ' },
  ['tt'] = { 'たち' },
  ['tw'] = { 'てい' },
  ['tyd'] = { 'ちぇん' },
  ['tyh'] = { 'ちゅう' },
  ['tyj'] = { 'ちゅん' },
  ['tyl'] = { 'ちょん' },
  ['tyn'] = { 'ちゃん' },
  ['typ'] = { 'ちょう' },
  ['tyq'] = { 'ちゃい' },
  ['tyw'] = { 'ちぇい' },
  ['tyz'] = { 'ちゃん' },
  ['tz'] = { 'たん' },
  ['u'] = { 'う' },
  ['va'] = { 'う゛ぁ' },
  ['ve'] = { 'う゛ぇ' },
  ['vi'] = { 'う゛ぃ' },
  ['vo'] = { 'う゛ぉ' },
  ['vu'] = { 'う゛' },
  ['vd'] = { 'う゛ぇん' },
  ['vk'] = { 'う゛ぃん' },
  ['vl'] = { 'う゛ぉん' },
  ['vn'] = { 'う゛ぁん' },
  ['vp'] = { 'う゛ぉー' },
  ['vq'] = { 'う゛ぁい' },
  ['vw'] = { 'う゛ぇい' },
  ['vya'] = { 'う゛ゃ' },
  ['vye'] = { 'う゛ぇ' },
  ['vyo'] = { 'う゛ょ' },
  ['vyu'] = { 'う゛ゅ' },
  ['vz'] = { 'う゛ぁん' },
  ['wa'] = { 'わ' },
  ['we'] = { 'うぇ' },
  ['wi'] = { 'うぃ' },
  ['wo'] = { 'を' },
  ['wu'] = { 'う' },
  ['wd'] = { 'うぇん' },
  ['wf'] = { 'わい' },
  ['wha'] = { 'うぁ' },
  ['whe'] = { 'うぇ' },
  ['whi'] = { 'うぃ' },
  ['who'] = { 'うぉ' },
  ['whu'] = { 'う' },
  ['wk'] = { 'うぃん' },
  ['wl'] = { 'うぉん' },
  ['wn'] = { 'わん' },
  ['wp'] = { 'うぉー' },
  ['wq'] = { 'わい' },
  ['wr'] = { 'われ' },
  ['wso'] = { 'うぉ' },
  ['wt'] = { 'わた' },
  ['wz'] = { 'わん' },
  ['xtsu'] = { 'っ' },
  ['xtu'] = { 'っ' },
  ['xwa'] = { 'ゎ' },
  ['xwe'] = { 'ゑ' },
  ['xwi'] = { 'ゐ' },
  ['xya'] = { 'ゃ' },
  ['xyo'] = { 'ょ' },
  ['xyu'] = { 'ゅ' },
  ['x;'] = { ';' },
  ['xa'] = { 'しゃ' },
  ['xc'] = { 'しゃ' },
  ['xd'] = { 'しぇん' },
  ['xe'] = { 'しぇ' },
  ['xf'] = { 'しぇい' },
  ['xh'] = { 'しゅう' },
  ['xi'] = { 'し' },
  ['xj'] = { 'しゅん' },
  ['xk'] = { 'しん' },
  ['xl'] = { 'しょん' },
  ['xn'] = { 'しゃん' },
  ['xo'] = { 'しょ' },
  ['xp'] = { 'しょう' },
  ['xq'] = { 'しゃい' },
  ['xt'] = { 'しゅつ' },
  ['xu'] = { 'しゅ' },
  ['xv'] = { 'しゃい' },
  ['xw'] = { 'しぇい' },
  ['xxa'] = { 'ぁ' },
  ['xxe'] = { 'ぇ' },
  ['xxh'] = { '←' },
  ['xxi'] = { 'ぃ' },
  ['xxj'] = { '↓' },
  ['xxk'] = { '↑' },
  ['xxl'] = { '→' },
  ['xxo'] = { 'ぉ' },
  ['xxu'] = { 'ぅ' },
  ['xz'] = { 'しゃん' },
  ['ya'] = { 'や' },
  ['ye'] = { 'いぇ' },
  ['yo'] = { 'よ' },
  ['yu'] = { 'ゆ' },
  ['y<'] = { '←' },
  ['y>'] = { '→' },
  ['y^'] = { '↑' },
  ['yf'] = { 'ゆ' },
  ['yh'] = { 'ゆう' },
  ['yi'] = { 'ゐ' },
  ['yj'] = { 'ゆん' },
  ['yl'] = { 'よん' },
  ['yn'] = { 'やん' },
  ['yp'] = { 'よう' },
  ['yq'] = { 'やい' },
  ['yr'] = { 'よる' },
  ['yv'] = { 'ゆう' },
  ['yz'] = { 'やん' },
  ['z '] = { '　' },
  ['z*'] = { '※' },
  ['z,'] = { '‥' },
  ['z-'] = { '〜' },
  ['z.'] = { '…' },
  ['z/'] = { '・' },
  ['z0'] = { '○' },
  ['z:'] = { '゜' },
  ['z;'] = { '゛' },
  ['z@'] = { '◎' },
  ['z['] = { '『' },
  ['z]'] = { '』' },
  ['z{'] = { '【' },
  ['z}'] = { '】' },
  ['z('] = { '（' },
  ['z)'] = { '）' },
  ['za'] = { 'ざ' },
  ['ze'] = { 'ぜ' },
  ['zi'] = { 'じ' },
  ['zo'] = { 'ぞ' },
  ['zu'] = { 'ず' },
  ['zya'] = { 'じゃ' },
  ['zye'] = { 'じぇ' },
  ['zyi'] = { 'じぃ' },
  ['zyo'] = { 'じょ' },
  ['zyu'] = { 'じゅ' },
  ['zc'] = { 'ざ' },
  ['zd'] = { 'ぜん' },
  ['zf'] = { 'ぜ' },
  ['zh'] = { 'ずう' },
  ['zj'] = { 'ずん' },
  ['zk'] = { 'じん' },
  ['zl'] = { 'ぞん' },
  ['zn'] = { 'ざん' },
  ['zp'] = { 'ぞう' },
  ['zq'] = { 'ざい' },
  ['zr'] = { 'ざる' },
  ['zv'] = { 'ざい' },
  ['zw'] = { 'ぜい' },
  ['zx'] = { 'ぜい' },
  ['zyd'] = { 'じぇん' },
  ['zyh'] = { 'じゅう' },
  ['zyj'] = { 'じゅん' },
  ['zyl'] = { 'じょん' },
  ['zyn'] = { 'じゃん' },
  ['zyp'] = { 'じょう' },
  ['zyq'] = { 'じゃい' },
  ['zyw'] = { 'じぇい' },
  ['zyz'] = { 'じゃん' },
  ['zz'] = { 'ざん' },
}, true)

vim.fn['skkeleton#config']({
  eggLikeNewline = true,
  immediatelyCancel = false,
  showCandidatesCount = 1,
  kanaTable = 'azik',
  globalDictionaries = require('xecua.utils').get_local_config().skkeleton_dictionaries,
})

vim.fn['skkeleton#initialize']()

return M
