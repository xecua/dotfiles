package sorterfuzzy

import (
	"cmp"
	"context"
	"slices"

	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"

	"github.com/delphinus/goda-cmp-ext-fuzzy.vim/fuzzy"
)

type sorterfuzzy struct{}

func New() sorterfuzzy { return sorterfuzzy{} }

func (sorterfuzzy) Name() string { return "sorterfuzzy" }

func (sorterfuzzy) Filter(_ context.Context, _ sdk.Host, a fi.FilterArgs) ([]fi.Item, error) {
	if a.Input == "" {
		return a.Items, nil
	}
	pat, fold := []rune(a.Input), fuzzy.Fold(a.Input)

	type scored struct {
		it    fi.Item
		score int
		n     int
	}
	matched := make([]scored, 0, len(a.Items))
	var unmatched []fi.Item
	for _, it := range a.Items {
		text := []rune(it.Word)
		if s, ok := fuzzy.Score(text, pat, fold); ok {
			matched = append(matched, scored{it, s, len(text)})
		} else {
			unmatched = append(unmatched, it)
		}
	}
	// スコアの高い順、同点なら短い順 (それも同じなら元の順序を保つ)
	slices.SortStableFunc(matched, func(x, y scored) int {
		return cmp.Or(cmp.Compare(y.score, x.score), cmp.Compare(x.n, y.n))
	})

	out := make([]fi.Item, 0, len(a.Items))
	for _, s := range matched {
		out = append(out, s.it)
	}
	// 一致しなかった候補は後ろに回す
	return append(out, unmatched...), nil
}
