package matcherfuzzy

import (
	"context"
	"reflect"
	"testing"

	"github.com/Shougo/goda-cmp.vim/cmp"
)

func TestMatcherFuzzy(t *testing.T) {
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
	); !reflect.DeepEqual(got, []string{"foobar", "fooBar"}) {
		t.Errorf("basic case: %q", got)
	}
}
