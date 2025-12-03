import {
  BaseConfig,
  type ConfigArguments,
  type ConfigReturn,
} from "@shougo/dpp-vim/config";
import { type Plugin } from "@shougo/dpp-vim/types";
import { existsSync } from "@std/fs";

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
    async function loadToml(
      path: string,
      loadOptions?: Partial<Plugin>,
    ): Promise<TomlLoadResult> {
      return (await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        { path, loadOptions },
      )) as TomlLoadResult;
    }

    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    const [context, options] = await args.contextBuilder.get(args.denops);
    const config_base = await args.denops.call("stdpath", "config");
    const tomls = [
      loadToml(`${config_base}/dpp/denops.toml`),
      loadToml(`${config_base}/dpp/dpp.toml`),
      loadToml(`${config_base}/dpp/common.toml`),
      loadToml(`${config_base}/dpp/ddu.toml`),
      loadToml(`${config_base}/dpp/ddc.toml`),
      loadToml(`${config_base}/dpp/plugins.toml`),
    ];

    if (existsSync(`${config_base}/dpp/local.toml`)) {
      tomls.push(loadToml(`${config_base}/dpp/local.toml`));
    }

    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];
    for (const toml of await Promise.all(tomls)) {
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

    const groups = {
      ddc: {
        depends: "denops.vim",
        on_source: "ddc.vim",
      },
      ddu: {
        depends: "denops.vim",
        // on_source: "ddu.vim",
      },
    };

    return {
      ftplugins,
      hooksFiles,
      groups,
      plugins,
      stateLines,
    };
  }
}
