(call
  function: (identifier) @identifier
  (#eq? @identifier "gql")
  arguments: (argument_list
   (string
     (string_start)
     (string_content) @injection.content
     (string_end)))
  (#set! injection.language "graphql")
  )
