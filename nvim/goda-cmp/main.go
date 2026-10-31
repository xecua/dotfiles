package main

import (
	"slices"

	"github.com/Shougo/goda-cmp.vim/cmp"
	"github.com/Shougo/goda-cmp.vim/ext/filter/converterremoveoverlap"
	"github.com/Shougo/goda-cmp.vim/ext/filter/matcherhead"
	"github.com/Shougo/goda-cmp.vim/ext/filter/sorterhead"
	"github.com/Shougo/goda-cmp.vim/ext/filter/sorterrank"
	"github.com/Shougo/goda-cmp.vim/ext/source/around"
	"github.com/Shougo/goda-cmp.vim/ext/source/cmdline"
	"github.com/Shougo/goda-cmp.vim/ext/source/file"
	"github.com/Shougo/goda-cmp.vim/ext/source/input"
	"github.com/Shougo/goda-cmp.vim/ext/source/line"
	"github.com/Shougo/goda-cmp.vim/ext/source/lsp"
	"github.com/Shougo/goda-cmp.vim/ext/source/shellnative"
	"github.com/Shougo/goda-cmp.vim/ext/ui/pum"

	"github.com/Shougo/goda-skk.vim/cmp/source/skk"
	"github.com/Shougo/goda-skk.vim/cmp/source/skkokuri"
)

func main() {
	b := cmp.New()

	b.AddUI(pum.New())

	// TODO: snippet
	b.AddSource(around.New(around.Params{MinLength: 2}))
	b.AddSource(line.New(line.Params{}))
	b.AddSource(file.New(file.Params{}))
	b.AddSource(cmdline.New())
	b.AddSource(input.New())
	b.AddSource(shellnative.New(shellnative.Params{Shell: "zsh"}))

	// TODO: fuzzy
	b.AddFilter(matcherhead.New(matcherhead.Params{}))
	b.AddFilter(sorterrank.New())
	b.AddFilter(sorterhead.New())
	b.AddFilter(converterremoveoverlap.New())

	p := newSkk()
	if p != nil {
		b.AddSource(skk.New(p))
		b.AddSource(skkokuri.New(p))
	}

	configure(b)

	b.Main(p)
}

var (
	sources = []string{"file", "around"}
)

func configure(b *cmp.Builder) {
	b.PatchGlobal(cmp.Config{
		UI:      "pum",
		Sources: sources,
		SourceOptions: map[string]cmp.SourceOption{
			"_": {
				Matchers:   []string{"matcherhead"},
				Sorters:    []string{"sorterrank"},
				Converters: []string{"converterremoveoverlap"},
			},
			"around": {Mark: "A"},
			"skk": {
				Mark:                  "skk",
				Matchers:              []string{},
				Sorters:               []string{},
				Converters:            []string{},
				IsVolatile:            new(true),
				MinAutoCompleteLength: new(1),
			},
			"skkokuri": {
				Mark:       "skk",
				Matchers:   []string{},
				Sorters:    []string{},
				Converters: []string{},
				IsVolatile: new(true),
			},
			"file": {
				Mark:                   "file",
				ForceCompletionPattern: `\S\/\S*`,
			},
			"cmdline": {
				Mark:                   "cmd",
				ForceCompletionPattern: `\S\s*`,
				IsVolatile:             new(true),
			},
			"input": {
				Mark:       "input",
				IsVolatile: new(true),
			},
			"shellnative": {
				Mark:       "sh",
				Matchers:   []string{"matcherhead"},
				IsVolatile: new(true),
			},
		},
		// PostFilters: []string{},
		AutoCompleteDelay: new(150),
		AutoCompleteEvents: []string{
			"InsertEnter",
			"TextChangedI",
			"TextChangedP",
			"CmdlineChanged",
		},
		CmdlineSources: map[string][]string{
			":": {"shellnative", "cmdline", "around"},
			"@": {"input", "file", "around"},
			">": {"input", "file", "around"},
			"/": {"around", "line"},
			"?": {"around", "line"},
			"-": {"around", "line"},
			"=": {"input"},
		},
	})

	configureLsp(b)
}

// LSP: 起動オプションとfiletypeへの紐付け。たぶん別ファイルの方がいい
func configureLsp(b *cmp.Builder) {
	b.AddSource(lsp.New(lsp.Params{
		Name:        "gopls",
		Command:     []string{"gopls"},
		Filetypes:   []string{"go"},
		RootMarkers: []string{".git", "go.mod"},
	}))
	b.PatchFiletype("go", cmp.Config{
		Sources: slices.Concat([]string{"gopls"}, sources),
	})
}
