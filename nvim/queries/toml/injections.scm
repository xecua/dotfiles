((comment) @injection.content
  (#set! injection.language "comment")
)

(pair
  (bare_key) @bare_key
  (#any-of? @bare_key
    "hook_add"
    "hook_done_update"
    "hook_post_source"
    "hook_post_update"
    "hook_source")
  (string) @injection.content
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
  (#set! injection.language "lua")
)
