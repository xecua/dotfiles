import { TSSnippet } from "https://deno.land/x/denippet_vim@v0.6.0/loader.ts";

export const snippets: Record<string, TSSnippet> = {
  stdjareport: {
    body: [
      "@require: stdjareport",
      "@require: azmath/azmath",
      "@require: mylib/common",
      "",
      "document(|",
      "  title={${1:#:title}};",
      "  author={${2:#:author}};",
      "|) '<",
      "  ${0}",
      ">",
    ],
  },
  slidify: {
    body: [
      "@require: class-slydifi/theme/hakodate-custom",
      "SlydifiHakodate.document(|",
      "  draft-mode = false;",
      "|) '<",
      "  +frame{${1:#:フレームのタイトル}} <",
      "    ${0}",
      "  >",
      ">",
    ],
  },
  jlreq: {
    body: [
      "@require: class-jlreq/jlreq",
      "@require: azmath/azmath",
      "@require: mylib/common",
      "",
      "document(|",
      "  title={${1:#:title}};",
      "  author={${2:#:author}};",
      "  date = {${3:#:date}};",
      "  show-title = true;",
      "  show-toc = false;",
      "|) '<",
      "  ${0}",
      ">",
    ],
  },
};
