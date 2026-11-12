package main

import (
	"github.com/Shougo/goda-term-ui-terminal.vim/ext/ui/terminal"
	"github.com/Shougo/goda-term.vim/term"
)

func main() {
	b := term.New()

	b.AddUI(terminal.New())

	b.PatchGlobal(term.Options{
		UI: "terminal",
		UIParams: map[string]term.Params{
			"terminal": {
				"split":       "farright",
				"command":     []string{"zsh"},
				"startInsert": true,
			},
		},
	})

	b.Main()
}
