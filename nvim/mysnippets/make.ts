import { TSSnippet } from "https://deno.land/x/denippet_vim@v0.6.0/loader.ts";

export const snippets: Record<string, TSSnippet> = {
  help: {
    body: [
      "help: ## このヘルプを表示",
      "# targetの後ろに##でコメントを付けておくと、それらがhelpコマンドで表示されるようになる",
      "# 行頭に##でコメントを付けると、以降のコマンドをグループ化して表示できる",
      `	@grep -h -E '^([a-zA-Z_-]+:.*?)?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; /^##/ {gsub(/^## /, ""); printf "\\n\\033[33m%s\\033[0m\\n", $$0; next}; {printf "\\033[4C\\033[36m%-20s\\033[0m %s\\n", $$1, $$2}`,
    ],
  },
};
