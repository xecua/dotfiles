package main

import (
	"slices"

	"github.com/Shougo/goda-cmp-ext/ext/filter/converterremoveoverlap"
	"github.com/Shougo/goda-cmp-ext/ext/filter/matcherhead"
	"github.com/Shougo/goda-cmp-ext/ext/filter/sorterhead"
	"github.com/Shougo/goda-cmp-ext/ext/filter/sorterrank"
	"github.com/Shougo/goda-cmp-ext/ext/source/around"
	"github.com/Shougo/goda-cmp-ext/ext/source/cmdline"
	"github.com/Shougo/goda-cmp-ext/ext/source/file"
	"github.com/Shougo/goda-cmp-ext/ext/source/input"
	"github.com/Shougo/goda-cmp-ext/ext/source/line"
	"github.com/Shougo/goda-cmp-ext/ext/source/lsp"
	"github.com/Shougo/goda-cmp-ext/ext/source/shellnative"
	"github.com/Shougo/goda-cmp-ext/ext/ui/none"
	"github.com/Shougo/goda-cmp-ui-pum.vim/ext/ui/pum"
	"github.com/Shougo/goda-cmp.vim/cmp"

	"github.com/Shougo/goda-skk.vim/cmp/source/skk"
	"github.com/Shougo/goda-skk.vim/cmp/source/skkokuri"

	"github.com/delphinus/goda-cmp-ext-fuzzy.vim/ext/filter/matcherfuzzy"
	"github.com/delphinus/goda-cmp-ext-fuzzy.vim/ext/filter/sorterfuzzy"
	"github.com/delphinus/goda-cmp-ext-fuzzy.vim/ext/filter/sorterglobal"
)

func main() {
	b := cmp.New()

	b.AddUI(pum.New())
	b.AddUI(none.New())

	// TODO: snippet
	b.AddSource(around.New(around.Params{MinLength: 2}))
	b.AddSource(line.New(line.Params{}))
	b.AddSource(file.New(file.Params{}))
	b.AddSource(cmdline.New())
	b.AddSource(input.New())
	b.AddSource(shellnative.New(shellnative.Params{Shell: "zsh"}))

	b.AddFilter(matcherhead.New(matcherhead.Params{}))
	b.AddFilter(matcherfuzzy.New())
	b.AddFilter(sorterrank.New())
	b.AddFilter(sorterhead.New())
	b.AddFilter(sorterfuzzy.New())
	b.AddFilter(sorterglobal.New(map[string]int{}))
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
		UI:          "pum",
		Sources:     sources,
		PostFilters: []string{"sorterglobal"},
		SourceOptions: map[string]cmp.SourceOption{
			"_": {
				Matchers:   []string{"matcherfuzzy"},
				Sorters:    []string{"sorterfuzzy"},
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

func makeLspSourceOptions(name string) map[string]cmp.SourceOption {
	return map[string]cmp.SourceOption{
		name: {
			Mark:                   "LSP",
			IsVolatile:             new(true),
			Dup:                    "force",
			ForceCompletionPattern: `\.\w*|:\w*|->\w*`,
			HideTimeout:            new(2000),
		},
	}
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
		Sources:       slices.Concat([]string{"gopls"}, sources),
		SourceOptions: makeLspSourceOptions("gopls"),
	})

	b.AddSource(lsp.New(lsp.Params{
		Name:        "intelephense",
		Command:     []string{"intelephense", "--stdio"},
		Filetypes:   []string{"php"},
		RootMarkers: []string{".git", "composer.json"},
	}))
	b.PatchFiletype("php", cmp.Config{
		Sources:       slices.Concat([]string{"intelephense"}, sources),
		SourceOptions: makeLspSourceOptions("intelephense"),
	})

	b.AddSource(lsp.New(lsp.Params{
		Name:        "nil_ls",
		Command:     []string{"nil", "--stdio"},
		Filetypes:   []string{"nix"},
		RootMarkers: []string{".git", "flake.nix"},
	}))
	b.PatchFiletype("nix", cmp.Config{
		Sources:       slices.Concat([]string{"nil_ls"}, sources),
		SourceOptions: makeLspSourceOptions("nil_ls"),
	})

	b.AddSource(lsp.New(lsp.Params{
		Name:        "markdown_oxide",
		Command:     []string{"markdown-oxide"},
		Filetypes:   []string{"markdown"},
		RootMarkers: []string{".git", ".obsidian"},
	}))
	b.PatchFiletype("markdown", cmp.Config{
		Sources:       slices.Concat([]string{"markdown_oxide"}, sources),
		SourceOptions: makeLspSourceOptions("markdown_oxide"),
	})

	b.AddSource(lsp.New(lsp.Params{
		Name:        "rust_analyzer",
		Command:     []string{"rust-analyzer"},
		Filetypes:   []string{"rust"},
		RootMarkers: []string{".git", "Cargo.toml"},
	}))
	b.PatchFiletype("rust", cmp.Config{
		Sources:       slices.Concat([]string{"rust_analyzer"}, sources),
		SourceOptions: makeLspSourceOptions("rust_analyzer"),
	})

	// denoは使わなくなるかなあ……
	b.AddSource(lsp.New(lsp.Params{
		Name:        "typescript",
		Command:     []string{"tsc", "--lsp", "--stdio"},
		Filetypes:   []string{"javascript", "javascriptreact", "typescript", "typescriptreact"},
		RootMarkers: []string{".git", "package.json", "tsconfig.json"},
	}))
	b.PatchFiletypes(
		[]string{"javascript", "javascriptreact", "typescript", "typescriptreact"},
		cmp.Config{
			Sources:       slices.Concat([]string{"typescript"}, sources),
			SourceOptions: makeLspSourceOptions("typescript"),
		},
	)

	b.AddSource(lsp.New(lsp.Params{
		Name:        "ty",
		Command:     []string{"ty", "server"},
		Filetypes:   []string{"python"},
		RootMarkers: []string{".git", "pyproject.toml"},
	}))
	b.PatchFiletype("python", cmp.Config{
		Sources:       slices.Concat([]string{"ty"}, sources),
		SourceOptions: makeLspSourceOptions("ty"),
	})
}
