package main

import (
	"context"
	"fmt"

	"github.com/Shougo/goda-cmp.vim/cmp"
	"github.com/Shougo/goda.vim/sdk"
)

// mini.snippets のスニペット候補
type snippetSource struct{}

type snippetData struct {
	prefix string
	body   string
}

func (snippetSource) Name() string { return "snippet" }

func (snippetSource) Gather(ctx context.Context, h sdk.Host, c *cmp.Context) (cmp.Gathered, error) {
	start := c.KeywordStart()
	if c.Mode != "i" {
		return cmp.Gathered{Start: start}, nil
	}
	v, err := h.Call(ctx, "luaeval", "require('xecua.snippets').items()")
	if err != nil {
		return cmp.Gathered{Start: start}, err
	}
	// 空のテーブルは {} (dict) で返ってくることがある
	list, _ := v.([]any)
	items := make([]cmp.Item, 0, len(list))
	for _, x := range list {
		m, ok := x.(map[string]any)
		if !ok {
			continue
		}
		prefix, body := fmt.Sprint(m["prefix"]), fmt.Sprint(m["body"])
		desc, _ := m["desc"].(string)
		if desc == prefix { // 説明の無いスニペットは prefix が入っている
			desc = ""
		}
		items = append(items, cmp.Item{
			Word:     prefix,
			Menu:     desc,
			Kind:     "Snippet",
			Info:     body,
			Dup:      1,
			UserData: snippetData{prefix: prefix, body: body},
		})
	}
	return cmp.Gathered{Start: start, Items: items}, nil
}

func (snippetSource) OnCompleteDone(ctx context.Context, h sdk.Host, a cmp.DoneArgs) error {
	d, ok := a.Item.UserData.(snippetData)
	if !ok {
		return nil
	}
	_, err := h.Call(ctx, "luaeval", "require('xecua.snippets').expand(_A[1], _A[2])", []any{d.prefix, d.body})
	return err
}
