// Package qflist is the core shared by the sources qflist and loclist.
package qflist

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"github.com/Shougo/goda-fi-ext/ext/kind/file"
	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"
)

// Gather evaluates list (getqflist() / getloclist(...)) with the file name
// of each entry added, in one call to Vim, and emits the items.
func Gather(ctx context.Context, h sdk.Host, list string, emit func([]fi.Item) error) error {
	expr := fmt.Sprintf(
		"map(%s, {_, v -> extend(v, {'filename': v.bufnr > 0 ? fnamemodify(bufname(v.bufnr), ':~:.') : ''})})",
		list,
	)
	r, err := h.Eval(ctx, expr)
	if err != nil {
		return err
	}
	entries, _ := r.([]any)
	return emit(parse(entries))
}

func hl(hls []fi.Highlight, name, group string, col, width int) []fi.Highlight {
	if width <= 0 {
		return hls
	}
	return append(hls, fi.Highlight{Name: name, HlGroup: group, Col: col, Width: width})
}

// parse makes items of the entries of a quickfix / location list:
// "path:lnum:col: text", as the source rg.
func parse(entries []any) []fi.Item {
	items := make([]fi.Item, 0, len(entries))
	for _, entry := range entries {
		e, ok := entry.(map[string]any)
		if !ok {
			continue
		}
		bufNr, _ := e["bufnr"].(int64)
		lineNr, _ := e["lnum"].(int64)
		col, _ := e["col"].(int64)
		name, _ := e["filename"].(string)
		text, _ := e["text"].(string)
		text = strings.TrimSpace(text)

		var header string
		var hls []fi.Highlight
		if name != "" {
			lnum := strconv.FormatInt(lineNr, 10)
			header = name + ":" + lnum
			if col > 0 {
				header += ":" + strconv.FormatInt(col, 10)
			}
			header += ": "
			hls = hl(hls, "path", "Directory", 1, len(name))
			hls = hl(hls, "lineNr", "LineNr", len(name)+2, len(lnum))
		}

		items = append(items, fi.Item{
			Word:       header + text,
			Highlights: hls,
			Action: file.ActionData{
				BufNr:  int(bufNr),
				LineNr: int(lineNr),
				Col:    int(col),
				Text:   text,
			},
		})
	}
	return items
}
