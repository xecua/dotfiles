import type { Params as FilerParams } from "@shougo/ddu-ui-filer";
import { BaseConfig, ConfigArguments } from "@shougo/ddu-vim/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): void {
    args.setAlias("_", "column", "icon_filename_ff", "icon_filename");

    args.contextBuilder.setLocal("fd-filer", {
      ui: {
        name: "filer",
        options: { toggle: true },
      },
      sync: true,
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
    });

    args.contextBuilder.patchGlobal({
      ui: "filer",
      uiParams: {
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
      },
      filterParams: {
        matcher_fzf: { highlightMatched: "Search" },
      },
      kindOptions: {
        file: { defaultAction: "open" },
        action: { defaultAction: "do" },
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
