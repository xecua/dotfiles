package sorterfuzzy

import (
	"context"
	"reflect"
	"testing"

	"github.com/Shougo/goda-cmp.vim/cmp"
)

func TestSorterFuzzy(t *testing.T) {
	f := New()
	run := func(f cmp.Filter, items []cmp.Item, typed string) []string {
		out, _ := f.Filter(context.Background(), cmp.FilterInput{Complete: typed, Items: items})
		var w []string
		for _, i := range out {
			w = append(w, i.Word)
		}
		return w
	}
	if got := run(
		f,
		[]cmp.Item{{Word: "not mathing"}, {Word: "foobar"}, {Word: "fooBar"}},
		"fb",
	); !reflect.DeepEqual(got, []string{"fooBar", "foobar", "not mathing"}) {
		t.Errorf("basic case: %q", got)
	}

	// gopls のように SortText が数字列でも Word / FilterText で照合する
	if got := run(
		f,
		[]cmp.Item{{Word: "Println", SortText: "00001"}, {Word: "Printf", SortText: "00000"}},
		"Prf",
	); !reflect.DeepEqual(got, []string{"Printf", "Println"}) {
		t.Errorf("sortText case: %q", got)
	}

	if got := run(
		f,
		[]cmp.Item{{Word: "a"}, {Word: "b"}},
		"",
	); !reflect.DeepEqual(got, []string{"a", "b"}) {
		t.Errorf("empty input: %q", got)
	}
}
