package sorterfuzzy

import (
	"context"

	"github.com/Shougo/goda-cmp.vim/cmp"
	"github.com/sahilm/fuzzy"
)

type sorterfuzzy struct{}

func New() cmp.Filter { return sorterfuzzy{} }

func (sorterfuzzy) Name() string { return "sorterfuzzy" }

func (m sorterfuzzy) Filter(_ context.Context, in cmp.FilterInput) ([]cmp.Item, error) {
	if in.Complete == "" {
		return in.Items, nil
	}
	// スコアをmatcherから持ち運べると無駄がないんだけど
	matches := fuzzy.FindFrom(in.Complete, sourceItem(in.Items))
	out := make([]cmp.Item, 0, len(in.Items))
	seen := make([]bool, len(in.Items))
	for _, m := range matches {
		out = append(out, in.Items[m.Index])
		seen[m.Index] = true
	}
	// 一致しなかった候補は後ろに回す
	for i, it := range in.Items {
		if !seen[i] {
			out = append(out, it)
		}
	}
	return out, nil
}

// wrapper of cmp.Item to implement fuzzy.Source
type sourceItem []cmp.Item

func (s sourceItem) String(i int) string {
	// Sort()じゃない方がいいみたい (goplsだと"00001"とかになる)
	return s[i].Word
}

func (s sourceItem) Len() int {
	return len(s)
}
