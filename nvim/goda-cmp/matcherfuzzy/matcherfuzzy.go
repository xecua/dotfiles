package matcherfuzzy

import (
	"context"

	"github.com/Shougo/goda-cmp.vim/cmp"
	"github.com/sahilm/fuzzy"
)

type matcherfuzzy struct{}

func New() cmp.Filter { return matcherfuzzy{} }

func (matcherfuzzy) Name() string { return "matcherfuzzy" }

func (m matcherfuzzy) Filter(_ context.Context, in cmp.FilterInput) ([]cmp.Item, error) {
	matches := fuzzy.FindFromNoSort(in.Complete, sourceItem(in.Items))
	out := make([]cmp.Item, 0, len(matches))
	for _, m := range matches {
		out = append(out, in.Items[m.Index])
	}
	return out, nil
}

// wrapper of cmp.Item to implement fuzzy.Source
type sourceItem []cmp.Item

func (s sourceItem) String(i int) string {
	return s[i].Word
}

func (s sourceItem) Len() int {
	return len(s)
}
