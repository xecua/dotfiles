// Portions of this file are derived from uga-rosa/ddu-source-lsp (MIT License).
// Copyright (c) 2023 uga-rosa
// License: https://github.com/uga-rosa/ddu-source-lsp/blob/main/LICENSE

import { BaseFilter, type FilterArguments } from "@shougo/ddu-vim/filter";
import type { DduFilterItems } from "@shougo/ddu-vim/types";

type Params = {};

// quickfix経由のLSP Itemを整形する
// 色とかアイコンとかはhttps://github.com/uga-rosa/ddu-source-lspから拝借するのがいいかなあ(MITだし
export class Filter extends BaseFilter<Params> {
  public override filter(
    {}: FilterArguments<Params>,
  ): DduFilterItems | Promise<DduFilterItems> {
    return [];
  }

  public override params(): Params {
    return {};
  }
}
