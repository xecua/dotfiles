import type { Params as FFParams } from "@shougo/ddu-ui-ff";
import type { Params as FilerParams } from "@shougo/ddu-ui-filer";
import { BaseConfig, ConfigArguments } from "@shougo/ddu-vim/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): void {
    args.setAlias("_", "column", "icon_filename_ff", "icon_filename");

    args.contextBuilder.setLocal("rg-live", {
      ui: "ff",
      sources: [{
        name: "rg",
        options: { volatile: true, matchers: [], sorters: [] },
      }],
    });

    args.contextBuilder.setLocal("document-symbol", {
      ui: { name: "ff", params: { displayTree: true } },
      sources: ["lsp_documentSymbol"],
    });

    args.contextBuilder.setLocal("workspace-symbol", {
      ui: { name: "ff", params: { displayTree: true } },
      sources: [{ name: "lsp_workspaceSymbol", options: { volatile: true } }],
    });

    args.contextBuilder.setLocal("dpp", {
      ui: "ff",
      sources: ["dpp"],
      kindOptions: { file: { defaultAction: "cd" } },
    });

    args.contextBuilder.setLocal("fd", {
      ui: "ff",
      sources: [{
        name: "file_external",
        params: {
          cmd: ["fd", "--type", "file", "--hidden"],
        },
      }],
    });
    args.contextBuilder.setLocal("fd-all", {
      ui: "ff",
      sources: [{
        name: "file_external",
        params: {
          cmd: ["fd", "--type", "file", "--hidden", "--no-ignore-vcs"],
        },
      }],
    });

    args.contextBuilder.setLocal("fd-filer", {
      ui: {
        name: "filer",
        options: { toggle: true },
      },
      sources: [{
        name: "file_external",
        params: { cmd: ["fd", "--max-depth", "1", "--unrestricted"] },
      }],
      sourceOptions: {
        // sourcesと分けとかないとupdateOptionsしても効かなさそう
        file_external: {
          matchers: ["matcher_hidden", "matcher_substring"],
          columns: ["icon_filename"],
        },
      },
      actionOptions: { _: { quit: false } },
    });

    args.contextBuilder.patchGlobal({
      ui: "ff",
      uiParams: {
        ff: {
          previewWidth: 80,
          previewSplit: "vertical",
          // startAutoAction : true,
          overwriteStatusline: false,
          autoAction: { name: "preview", sync: false },
        } satisfies Partial<FFParams>,
        filer: {
          split: "vertical",
          splitDirection: "topleft",
          winWidth: "&columns / 6",
          overwriteStatusline: false,
          sort: "natural",
          sortTreesFirst: true,
        } satisfies Partial<FilerParams>,
      },
      sourceParams: {
        rg: { maxEnqueSize: 1000, args: ["--json"] },
      },
      sourceOptions: {
        _: {
          matchers: ["matcher_fzf"],
          sorters: ["sorter_alpha", "sorter_fzf"],
        },
        file_external: {
          // columns : ["icon_filename_ff"] ,
          converters: ["converter_hl_dir"],
        },
        buffer: {
          // columns : ["icon_filename_ff"] ,
          converters: ["converter_hl_dir"],
        },
        dpp: { defaultAction: "cd" },
        lsp_documentSymbol: { converters: ["converter_lsp_symbol"] },
        lsp_workspaceSymbol: { converters: ["converter_lsp_symbol"] },
      },
      filterParams: {
        matcher_fzf: { highlightMatched: "Search" },
      },
      kindOptions: {
        file: { defaultAction: "open" },
        word: { defaultAction: "append" },
        action: { defaultAction: "do" },
        command_history: { defaultAction: "edit" },
        command: { defaultAction: "edit" },
        help: { defaultAction: "open" },
        readme_viewer: { defaultAction: "open" },
        lsp: { defaultAction: "open" },
        lsp_codeAction: { defaultAction: "apply" },
        ui_select: { defaultAction: "select" },
      },
      columnParams: {
        icon_filename: {
          defaultIcon: { icon: "" },
        },
        icon_filename_ff: {
          defaultIcon: { icon: "" },
          padding: 0,
          pathDisplayOption: "relative",
        },
      },
    });
  }
}
