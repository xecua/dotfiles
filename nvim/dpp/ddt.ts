import { BaseConfig, ConfigArguments } from "@shougo/ddt-vim/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): void {
    args.contextBuilder.patchGlobal({
      ui: "terminal",
      uiParams: {
        terminal: {
          split: "horizontal",
          command: ["zsh"],
          startInsert: true,
          winHeight: 10,
        },
      },
    });
  }
}
