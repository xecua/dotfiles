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
	for _, m := range matches {
		out = append(out, a.Items[m.Index])
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
