package main

import (
	"github.com/Shougo/goda-cmp.vim/cmp"
	"github.com/Shougo/goda-cmp.vim/ext/filter/matcherhead"
	"github.com/Shougo/goda-cmp.vim/ext/filter/sorterlength"
	"github.com/Shougo/goda-cmp.vim/ext/filter/truncateabbr"
	"github.com/Shougo/goda-cmp.vim/ext/source/around"
)

func main() {
	b := cmp.New()

	// Extensions: anything implementing cmp.Source / cmp.Filter / cmp.UI,
	// from this repository or from your own modules.
	b.AddSource(around.New(around.Params{MinLength: 2}))
	b.AddFilter(matcherhead.New(matcherhead.Params{}))
	b.AddFilter(sorterlength.New())
	b.AddFilter(truncateabbr.New(truncateabbr.Params{MaxWidth: 40}))

	configure(b)
	b.Main()
}

func configure(b *cmp.Builder) {
	b.PatchGlobal(cmp.Config{
		UI:      "pum",
		Sources: []string{"around"},
		SourceOptions: map[string]cmp.SourceOption{
			"_": {
				Matchers:   []string{"matcher_head"},
				Sorters:    []string{"sorter_length"},
				Converters: []string{"converter_truncate_abbr"},
			},
			"around": {Mark: "A"},
		},
		AutoCompleteDelay: cmp.Ptr(10),
	})

	// Per filetype, laid over the global settings.
	b.PatchFiletype("markdown", cmp.Config{
		SourceOptions: map[string]cmp.SourceOption{
			"around": {MinAutoCompleteLength: cmp.Ptr(3)},
		},
	})
	b.PatchFiletypes([]string{"gitcommit", "text"}, cmp.Config{
		AutoCompleteDelay: cmp.Ptr(100),
	})
}
