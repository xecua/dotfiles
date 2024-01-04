import {
  BaseConfig,
  ConfigArguments,
  ConfigReturn,
  Plugin,
} from "https://deno.land/x/dpp_vim@v0.0.7/types.ts";

type TomlLoadResult = {
  hooks_file?: string;
  ftplugins?: Record<string, string>;
  plugins: Plugin[];
};

type MakeLazyStateResult = {
  plugins: Plugin[];
  stateLines: string[];
};

// make_state expects the class named 'Config' and that has config() method to be exported
export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<ConfigReturn> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    const [context, options] = await args.contextBuilder.get(args.denops);
    const config_base = await args.denops.call("stdpath", "config");
    const tomls = [
      (await args.dpp.extAction(args.denops, context, options, "toml", "load", {
        path: `${config_base}/dein.toml`,
        options: { lazy: false },
      })) as TomlLoadResult,
      (await args.dpp.extAction(args.denops, context, options, "toml", "load", {
        path: `${config_base}/dein_lazy.toml`,
        options: { lazy: true },
      })) as TomlLoadResult,
    ];

    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];
    for (const toml of tomls) {
      for (const plugin of toml.plugins) {
        recordPlugins[plugin.name] = plugin;
      }

      if (toml.ftplugins) {
        for (const filetype of Object.keys(toml.ftplugins)) {
          if (ftplugins[filetype]) {
            ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
          } else {
            ftplugins[filetype] = toml.ftplugins[filetype];
          }
        }
      }

      if (toml.hooks_file) {
        hooksFiles.push(toml.hooks_file);
      }
    }

    // for lazy loading plugins
    const { plugins, stateLines } = (await args.dpp.extAction(
      args.denops,
      context,
      options,
      "lazy",
      "makeState",
      {
        plugins: Object.values(recordPlugins),
      },
    )) as MakeLazyStateResult;

    return {
      ftplugins,
      hooksFiles,
      plugins,
      stateLines,
    };
  }
}
