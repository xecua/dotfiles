;; extends
((comment) @injection.content
  (#set! injection.language "comment")
)

; #gsub!とか使ってまとめられないかなあ
; あと複数のファイルタイプに対応できないかも
(pair
  (bare_key) @bare_key
  (#match? @bare_key "^lua_[a-zA-Z_]+$")
  (string) @injection.content
  (#match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "lua")
)

(pair
  (bare_key) @bare_key
  (#match? @bare_key "^lua_[a-zA-Z_]+$")
  (string) @injection.content
  (#match? @injection.content "^\"[^\"]")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "lua")
)
