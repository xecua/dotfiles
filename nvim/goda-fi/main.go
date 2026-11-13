package main

import (
	"github.com/Shougo/goda-fi-ext/ext/column/filename"
	"github.com/Shougo/goda-fi-ext/ext/filter/converterhldir"
	"github.com/Shougo/goda-fi-ext/ext/filter/matcherhidden"
	"github.com/Shougo/goda-fi-ext/ext/filter/matchersubstring"
	"github.com/Shougo/goda-fi-ext/ext/filter/sorteralpha"
	kindfile "github.com/Shougo/goda-fi-ext/ext/kind/file"
	"github.com/Shougo/goda-fi-ext/ext/kind/word"
	"github.com/Shougo/goda-fi-ext/ext/source/buffer"
	sourcefile "github.com/Shougo/goda-fi-ext/ext/source/file"
	"github.com/Shougo/goda-fi-ext/ext/source/fileexternal"
	"github.com/Shougo/goda-fi-ext/ext/source/rg"
	"github.com/Shougo/goda-fi-ui-ff.vim/ui/ff"
	"github.com/Shougo/goda-fi-ui-filer.vim/ui/filer"
	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda-pm-ext/ext/fi/pmfi"

	"goda-fi-config/matcherfuzzy"
	"goda-fi-config/sorterfuzzy"
)

func main() {
	b := fi.New()

	b.AddUI(ff.New())
	b.AddUI(filer.New())

	// TODO: lsp symbol
	b.AddSource(rg.New(rg.Params{MaxEnqueSize: 1000, Args: []string{"--json"}}))
	b.AddSource(buffer.New())
	b.AddSource(sourcefile.New(sourcefile.Params{}))
	b.AddSourceAs("fd", fileexternal.New(fileexternal.Params{
		Cmd: []string{"fd", "--type", "file", "--hidden"},
	}))
	b.AddSourceAs("fdall", fileexternal.New(fileexternal.Params{
		Cmd: []string{"fd", "--type", "file", "--hidden", "--no-ignore-vcs"},
	}))
	b.AddSource(pmfi.New())

	// TODO: column(fileicon)
	b.AddFilter(matchersubstring.New(matchersubstring.Params{HighlightMatched: "Search"}))
	b.AddFilter(matcherhidden.New())
	b.AddFilter(matcherfuzzy.New(matcherfuzzy.Params{HighlightMatched: "Search"}))
	b.AddFilter(sorteralpha.New())
	b.AddFilter(sorterfuzzy.New())
	b.AddFilter(converterhldir.New(converterhldir.Params{}))

	b.AddKind(kindfile.New())
	b.AddKind(word.New())

	b.AddColumn(filename.New(filename.DefaultParams()))

	configure(b)

	b.Main()
}

func configure(b *fi.Builder) {
	b.PatchGlobal(fi.Options{
		UI: "ff",
		UIParams: map[string]fi.Params{
			"ff": {
				"previewWidth":        80,
				"previewSplit":        "vertical",
				"overwriteStatusline": false,
				"autoAction": map[string]any{
					"name": "preview",
					"sync": false,
				},
			},
			"filer": {
				"split":               "vertical",
				"splitDirection":      "topleft",
				"winWidth":            "&columns / 6",
				"overwriteStatusline": false,
				"sort":                "natural",
				"sortTreesFirst":      true,
			},
		},
		UIOptions: map[string]fi.UIOptions{
			"filer": {Persist: new(true)},
		},
		SourceOptions: map[string]fi.SourceOptions{
			"_": {
				Matchers: []string{"matcherfuzzy"},
				Sorters:  []string{"sorteralpha", "sorterfuzzy"},
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
	b.PatchLocal("goda-pm", fi.Options{Sources: fi.Sources("goda_pm")})

	b.PatchLocal("filer", fi.Options{
		UI:      "filer",
		Sync:    new(true),
		Sources: fi.Sources("file"),
		SourceOptions: map[string]fi.SourceOptions{
			"file": {
				Matchers: []string{"matcherhidden", "matchersubstring"},
				Sorters:  []string{},
				Columns:  []string{"filename"},
			},
		},
	})

}
