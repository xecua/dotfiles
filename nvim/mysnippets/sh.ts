import { TSSnippet } from "https://deno.land/x/denippet_vim@v0.6.0/loader.ts";

export const snippets: Record<string, TSSnippet> = {
  dirname: {
    body: [
      '$0=\\$(cd "\\$(realpath \\$(dirname \\$0))"; pwd)',
    ],
  },
};
