;; extends
((comment) @injection.content
  (#set! injection.language "comment")
)

; #gsub!とか使ってまとめられないかなあ
(pair
  (bare_key) @bare_key
  (#any-of? @bare_key
    "hook_add"
    "hook_done_update"
    "hook_post_source"
    "hook_post_update"
    "hook_source"
    "if"
    "on_if")
  (string) @injection.content
  (#match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "vim")
)

(pair
  (bare_key) @bare_key
  (#any-of? @bare_key
    "hook_add"
    "hook_done_update"
    "hook_post_source"
    "hook_post_update"
    "hook_source"
    "if"
    "on_if")
  (string) @injection.content
  (#match? @injection.content "^\"[^\"]")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "vim")
)

(pair
  (bare_key) @bare_key
  (#any-of? @bare_key
    "lua_add"
    "lua_done_update"
    "lua_post_source"
    "lua_post_update"
    "lua_source")
  (string) @injection.content
  (#match? @injection.content "^\"\"\"")
  (#offset! @injection.content 0 3 0 -3)
  (#set! injection.language "lua")
)

(pair
  (bare_key) @bare_key
  (#any-of? @bare_key
    "lua_add"
    "lua_done_update"
    "lua_post_source"
    "lua_post_update"
    "lua_source")
  (string) @injection.content
  (#match? @injection.content "^\"[^\"]")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "lua")
)
