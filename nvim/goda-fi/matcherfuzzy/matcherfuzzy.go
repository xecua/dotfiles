package matcherfuzzy

import (
	"context"

	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"

	"github.com/sahilm/fuzzy"
)

type Params struct {
	HighlightMatched string `json:"highlightMatched"`
}

type matcherfuzzy struct{ p Params }

func New(p Params) fi.Filter { return matcherfuzzy{p} }

func (matcherfuzzy) Name() string { return "matcherfuzzy" }

func (f matcherfuzzy) Filter(_ context.Context, _ sdk.Host, a fi.FilterArgs) ([]fi.Item, error) {
	if a.Input == "" {
		return a.Items, nil
	}

	p := f.p
	if err := fi.Decode(a.FilterParams, &p); err != nil {
		return nil, err
	}
	matches := fuzzy.FindFromNoSort(a.Input, sourceItem(a.Items))
	out := make([]fi.Item, 0, len(matches))
	for _, m := range matches {
		it := a.Items[m.Index]

		if p.HighlightMatched != "" {
			it = highlight(it, m, p.HighlightMatched)
		}

		out = append(out, it)

	}
	return out, nil
}

// wrapper of fi.Item to implement fuzzy.Source
type sourceItem []fi.Item

func (s sourceItem) String(i int) string {
	return s[i].MatcherKey()
}

func (s sourceItem) Len() int {
	return len(s)
}

func highlight(it fi.Item, m fuzzy.Match, hlgroup string) fi.Item {
	hls := append([]fi.Highlight(nil), it.Highlights...)
	for _, idx := range m.MatchedIndexes {
		hls = append(hls, fi.Highlight{
			Name:    "matched",
			HlGroup: hlgroup,
			Col:     idx + 1,
			Width:   1,
		})
	}
	it.Highlights = hls
	return it
}
