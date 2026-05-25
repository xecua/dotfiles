import type { ActionData } from "@shougo/ddu-kind-file";
import { BaseSource } from "@shougo/ddu-vim/source";
import type { GatherArguments } from "@shougo/ddu-vim/source";
import type { Item } from "@shougo/ddu-vim/types";
import * as fn from "@denops/std/function";

type QfItem = {
  bufnr: number;
  col: number;
  end_col: number;
  end_lnum: number;
  lnum: number;
  module: string;
  nr: number;
  pattern: string;
  text: string;
  type: string;
  valid: number;
  vcol: number;
  user_data: unknown;
};

type FileGroup = {
  bufnr: number;
  items: QfItem[];
};

type Params = {
  // Passed directly to getqflist()/getloclist() to select which list
  // (e.g. { id: 0 } for current, { nr: 2 } for 2nd list, {} for default)
  what: Record<string, unknown>;
  isLoclist: boolean;
  winid: number; // window id/nr for getloclist (0 = current window)
};

export class Source extends BaseSource<Params> {
  override gather(
    { denops, sourceParams, parent }: GatherArguments<Params>,
  ): ReadableStream<Item<ActionData>[]> {
    return new ReadableStream({
      async start(controller) {
        try {
          if (parent != null) {
            // Expansion: return children stored in parent.data
            const group = parent.data as FileGroup;
            const parentPath = String(parent.treePath ?? "");

            controller.enqueue(
              group.items.map((qfItem, idx): Item<ActionData> => {
                const typeStr = qfItem.type
                  ? `[${qfItem.type}${qfItem.nr > 0 ? qfItem.nr : ""}] `
                  : "";
                const posStr = `${qfItem.lnum}:${qfItem.col}`;
                const prefix = qfItem.valid === 0 ? "~" : "";

                return {
                  word: `${prefix}${typeStr}${posStr} ${qfItem.text}`,
                  treePath: `${parentPath}\0${idx}`,
                  action: {
                    path: parentPath,
                    lineNr: qfItem.lnum,
                    col: qfItem.col,
                    text: qfItem.text,
                  },
                };
              }),
            );
            return;
          }

          // Root: fetch from quickfix/loclist and group by file
          const { what, isLoclist, winid } = sourceParams;

          const result = (
            isLoclist
              ? await fn.getloclist(denops, winid, { ...what, items: 1 })
              : await fn.getqflist(denops, { ...what, items: 1 })
          ) as { items?: QfItem[] };

          const qfItems = result.items ?? [];

          // Batch-resolve bufnr → filename in parallel
          const uniqueBufnrs = [
            ...new Set(qfItems.map((i) => i.bufnr).filter((n) => n > 0)),
          ];
          const bufnrToName = new Map(
            await Promise.all(
              uniqueBufnrs.map(async (bufnr) =>
                [bufnr, await fn.bufname(denops, bufnr)] as const
              ),
            ),
          );

          // Group by filename, preserving first-occurrence order
          const fileOrder: string[] = [];
          const fileMap = new Map<string, FileGroup>();

          for (const item of qfItems) {
            const fname = item.bufnr > 0
              ? (bufnrToName.get(item.bufnr) ?? `[buf:${item.bufnr}]`)
              : "[No File]";

            if (!fileMap.has(fname)) {
              fileOrder.push(fname);
              fileMap.set(fname, { bufnr: item.bufnr, items: [] });
            }
            fileMap.get(fname)!.items.push(item);
          }

          controller.enqueue(
            fileOrder.map((fname): Item<ActionData> => {
              const group = fileMap.get(fname)!;
              const counts = (
                [
                  ["E", group.items.filter((i) => i.type === "E").length],
                  ["W", group.items.filter((i) => i.type === "W").length],
                ] as [string, number][]
              )
                .filter(([, n]) => n > 0)
                .map(([t, n]) => `${t}:${n}`)
                .join(" ");

              return {
                word: counts ? `${fname} [${counts}]` : fname,
                isTree: true,
                treePath: fname,
                data: group,
                action: {
                  path: fname !== "[No File]" ? fname : undefined,
                  bufNr: group.bufnr > 0 ? group.bufnr : undefined,
                },
              };
            }),
          );
        } finally {
          controller.close();
        }
      },
    });
  }

  override params(): Params {
    return {
      what: {},
      isLoclist: false,
      winid: 0,
    };
  }
}
