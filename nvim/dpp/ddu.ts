import { BaseConfig, ConfigArguments } from "@shougo/ddu-vim/config";
import type { Params as FFParams } from "@shougo/ddu-ui-ff";
import type { Params as FilerParams } from "@shougo/ddu-ui-filer";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): void {
    args.setAlias("_", "column", "icon_filename_ff", "icon_filename");

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
          winWidth: "&columns / 6", // これでいいらしい
        } satisfies Partial<FilerParams>,
      },
      uiOptions: {
        filer: { toggle: true },
      },
      sourceParams: {
        file_external: { cmd: ["fd", ".", "-t", "f", "-H"] },
        rg: { maxEnqueSize: 1000, args: ["--json"] },
      },
      sourceOptions: {
        _: { matchers: ["matcher_fzf"], sorters: ["sorter_fzf"] },
        file_external: {
          // columns : ["icon_filename_ff"] ,
          converters: ["converter_hl_dir"],
        },
        buffer: {
          // columns : ["icon_filename_ff"] ,
          converters: ["converter_hl_dir"],
        },
        source: { defaultAction: "execute" },
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
