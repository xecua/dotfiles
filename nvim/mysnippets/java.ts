import { TSSnippet } from "https://deno.land/x/denippet_vim@v0.6.0/loader.ts";
import { fn } from "https://deno.land/x/denippet_vim@v0.6.0/deps/denops.ts";

export const snippets: Record<string, TSSnippet> = {
  template: {
    prefix: ["public", "main", "template"],
    description: "voilerplate (public static void main)",
    body: async (denops) => {
      const filePath = (await fn.expand(denops, "%:p:h")) as string;
      const matches = /(^.*src\/main\/java\/?)(.*)/.exec(filePath);
      const packageName = matches?.[2].replaceAll("/", ".") ?? "";
      const className = (await fn.expand(denops, "%:t:r")) as string;

      const body = [];
      if (matches?.[1] != null && packageName !== "") {
        // プロジェクトではないときmatches[1]はnull
        body.push(`package ${packageName}`, "");
      }

      body.push(
        `public class ${className} {`,
        "  public static void main(String[] args) {",
        "    $0",
        "  }",
        "}",
      );

      return body;
    },
  },
};
