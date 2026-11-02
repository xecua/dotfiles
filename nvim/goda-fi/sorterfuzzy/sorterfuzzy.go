package sorterfuzzy

import (
	"context"

	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"
	"github.com/sahilm/fuzzy"
)

type sorterfuzzy struct{}

func New() sorterfuzzy { return sorterfuzzy{} }

func (sorterfuzzy) Name() string { return "sorterfuzzy" }

func (sorterfuzzy) Filter(_ context.Context, _ sdk.Host, a fi.FilterArgs) ([]fi.Item, error) {
	if a.Input == "" {
		return a.Items, nil
	}
	matches := fuzzy.FindFrom(a.Input, sourceItem(a.Items))

	out := make([]fi.Item, 0, len(matches))
	seen := make([]bool, len(a.Items))
	for _, m := range matches {
		out = append(out, a.Items[m.Index])
		seen[m.Index] = true
	}
	// 一致しなかった候補は後ろに回す
	for i, it := range a.Items {
		if !seen[i] {
			out = append(out, it)
		}
	}
	return out, nil
}

// wrapper of fi.Item to implement fuzzy.Source
type sourceItem []fi.Item

func (s sourceItem) String(i int) string {
	return s[i].Word
}

func (s sourceItem) Len() int {
	return len(s)
}
