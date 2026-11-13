package matcherfuzzy

import (
	"context"
	"unicode/utf8"

	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"

	"github.com/delphinus/goda-cmp-ext-fuzzy.vim/fuzzy"
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
	pat, fold := []rune(a.Input), fuzzy.Fold(a.Input)
	out := make([]fi.Item, 0, len(a.Items))
	for _, it := range a.Items {
		text := []rune(it.MatcherKey())
		_, pos, ok := fuzzy.Match(text, pat, fold)
		if !ok {
			continue
		}
		if p.HighlightMatched != "" {
			it = highlight(it, text, pos, p.HighlightMatched)
		}
		out = append(out, it)
	}
	return out, nil
}

// fuzzy.Match はrune単位の位置を返すが、fi.Highlight はバイト単位なので変換する
func highlight(it fi.Item, text []rune, pos []int, hlgroup string) fi.Item {
	hls := append([]fi.Highlight(nil), it.Highlights...)
	col, ri := 0, 0
	for _, idx := range pos {
		for ; ri < idx; ri++ {
			col += utf8.RuneLen(text[ri])
		}
		hls = append(hls, fi.Highlight{
			Name:    "matched",
			HlGroup: hlgroup,
			Col:     col + 1,
			Width:   utf8.RuneLen(text[idx]),
		})
	}
	it.Highlights = hls
	return it
}
