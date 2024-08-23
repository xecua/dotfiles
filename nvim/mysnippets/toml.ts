import { TSSnippet } from "https://deno.land/x/denippet_vim@v0.6.0/loader.ts";

export const snippets: Record<string, TSSnippet> = {
  plugins: {
    description: "Plugin template for dark-powered plugin manager",
    body: ["[[plugins]]", "repo = '${VIM:getreg('+')}'", "${0}"],
  },
};
