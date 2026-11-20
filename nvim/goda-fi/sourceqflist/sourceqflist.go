package sourceqflist

import (
	"context"

	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"

	"goda-fi-config/internal/qflist"
)

type source struct{}

func New() fi.Source { return source{} }

// Name implements [fi.Source].
func (source) Name() string { return "qflist" }

// Kind implements [fi.Source].
func (source) Kind() string { return "file" }

// Gather implements [fi.Source].
func (s source) Gather(ctx context.Context, h sdk.Host, a fi.GatherArgs, emit func([]fi.Item) error) error {
	return qflist.Gather(ctx, h, "getqflist()", emit)
}
