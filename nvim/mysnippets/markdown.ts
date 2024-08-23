import { TSSnippet } from "https://deno.land/x/denippet_vim@v0.6.0/loader.ts";

export const snippets: Record<string, TSSnippet> = {
  today: {
    description: "insert the day(yyyy-mm-dd)",
    body: ["$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE"],
  },
};
