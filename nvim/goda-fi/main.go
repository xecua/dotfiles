package main

import (
	"github.com/Shougo/goda-fi.vim/ext/filter/converterhldir"
	"github.com/Shougo/goda-fi.vim/ext/filter/matchersubstring"
	"github.com/Shougo/goda-fi.vim/ext/filter/sorteralpha"
	kindfile "github.com/Shougo/goda-fi.vim/ext/kind/file"
	kindword "github.com/Shougo/goda-fi.vim/ext/kind/word"
	"github.com/Shougo/goda-fi.vim/ext/source/buffer"
	"github.com/Shougo/goda-fi.vim/ext/source/fileexternal"
	"github.com/Shougo/goda-fi.vim/ext/source/rg"
	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda-fi.vim/ui/ff"
)

func main() {
	b := fi.New()

	// TODO: filer
	b.AddUI(ff.New())

	// TODO: lsp symbol
	b.AddSource(rg.New(rg.Params{MaxEnqueSize: 1000, Args: []string{"--json"}}))
	b.AddSource(buffer.New())
	b.AddSourceAs("fd", fileexternal.New(fileexternal.Params{
		Cmd: []string{"fd", "--type", "file", "--hidden"},
	}))
	b.AddSourceAs("fdall", fileexternal.New(fileexternal.Params{
		Cmd: []string{"fd", "--type", "file", "--hidden", "--no-ignore-vcs"},
	}))

	// TODO: fuzzy, column(fileicon)
	b.AddFilter(matchersubstring.New(matchersubstring.Params{HighlightMatched: "Search"}))
	b.AddFilter(sorteralpha.New())
	b.AddFilter(converterhldir.New(converterhldir.Params{}))

	b.AddKind(kindfile.New())
	b.AddKind(kindword.New())

	b.PatchGlobal(fi.Options{
		UI: "ff",
		UIParams: map[string]fi.Params{
			"ff": {
				"previewWidth":        80,
				"previewSplit":        "vertical",
				"overwriteStatusline": false,
				"autoAction":          map[string]any{"name": "preview", "sync": false},
			},
		},
		SourceOptions: map[string]fi.SourceOptions{
			"_": {
				Matchers: []string{"matchersubstring"},
				Sorters:  []string{"sorteralpha"},
			},
			"fd":     {Converters: []string{"converterhldir"}},
			"fdall":  {Converters: []string{"converterhldir"}},
			"buffer": {Converters: []string{"converterhldir"}},
		},
		KindOptions: map[string]fi.KindOptions{
			"file": {DefaultAction: "open"},
			"word": {DefaultAction: "append"},
		},
	})

	b.PatchLocal("rg-live", fi.Options{
		Sources: []fi.SourceSpec{{
			Name:    "rg",
			Options: &fi.SourceOptions{Matchers: []string{}, Sorters: []string{}, Volatile: new(true)},
		}},
	})
	b.PatchLocal("rg", fi.Options{
		Sources: []fi.SourceSpec{{
			Name:    "rg",
			Options: &fi.SourceOptions{Matchers: []string{}, Sorters: []string{}},
		}},
	})

	b.PatchLocal("fd", fi.Options{Sources: fi.Sources("fd")})
	b.PatchLocal("fd-all", fi.Options{Sources: fi.Sources("fdall")})
	b.PatchLocal("buffer", fi.Options{Sources: fi.Sources("buffer")})

	b.Main()
}
