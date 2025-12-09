import { BaseConfig, ConfigArguments } from "@shougo/ddc-vim/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): void {
    const default_sources = ["lsp", "file", "around", "denippet"];

    args.contextBuilder.patchGlobal({
      ui: "pum",
      sources: default_sources,
      sourceOptions: {
        _: {
          matchers: ["matcher_fuzzy"],
          sorters: ["sorter_fuzzy"],
          converters: ["converter_fuzzy", "converter_remove_overlap"],
          ignoreCase: true,
        },
        around: { mark: "A" },
        denippet: {
          mark: "snip",
          dup: "keep",
          matchers: ["matcher_head"],
          sorters: ["sorter_rank"],
          converters: [],
        },
        lsp: {
          mark: "LSP",
          dup: "force",
          sorters: ["sorter_fuzzy", "sorter_lsp_kind"],
          forceCompletionPattern: String.raw`\.\w*|:\w*|->\w*`,
          isVolatile: true,
        },
        file: {
          mark: "file",
          forceCompletionPattern: String.raw`\S\/\S*`,
        },
        cmdline: {
          mark: "cmd",
          forceCompletionPattern: String.raw`\S\s*`,
          isVolatile: true,
        },
        ["cmdline-history"]: {
          mark: "cmd-hist",
          matchers: ["matcher_head"],
          sorters: ["sorter_rank"],
          converters: [],
        },
        input: { mark: "input", isVolatile: true },
        line: { mark: "line" },
      },
      sourceParams: {
        lsp: {
          // snippetEngine : vim.fn["denops#callback#register"](function(body)
          //     vim.fn["denippet#anonymous"](body)
          // end),
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
          enableDisplayDetail: true,
          confirmBehavior: "replace",
        },
      },
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
        "CmdlineChanged",
      ],
      cmdlineSources: {
        [":"]: ["cmdline", "cmdline_history", "around"],
        ["@"]: ["cmdline_history", "input", "file", "arund"],
        [">"]: ["cmdline_history", "input", "file", "around"],
        ["/"]: ["around", "line"],
        ["?"]: ["around", "line"],
        ["-"]: ["around", "line"],
        ["="]: ["input"],
      },
    });

    for (const ft of ["ps1", "dosbatch", "autohotkey", "registry"]) {
      args.contextBuilder.patchFiletype(ft, {
        sourceOptions: {
          file: { forceCompletionPattern: String.raw`\S\\\S*` },
        },
        sourceParams: { file: { mode: "win32" } },
      });
    }
  }
}
