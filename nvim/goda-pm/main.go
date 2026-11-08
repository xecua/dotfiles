package main

// 値確認したいときは適当にstdoutとかに吐いとけば:GpLogで読める
import (
	"context"
	"os"
	"slices"

	"github.com/Shougo/goda-pm.vim/ext/installer"
	"github.com/Shougo/goda-pm.vim/ext/lazy"
	"github.com/Shougo/goda-pm.vim/ext/protocol/git"
	"github.com/Shougo/goda-pm.vim/ext/toml"
	"github.com/Shougo/goda-pm.vim/pm"
)

func main() {
	b := pm.New()

	b.AddProtocol(git.New())
	b.AddExt(installer.New())

	b.SetConfig(func(ctx context.Context, c *pm.ConfigArgs) (*pm.ConfigReturn, error) {
		tomls := []string{
			"goda.toml",
			"plugins.toml",
			"common.toml",
		}
		if _, err := os.Stat(os.ExpandEnv("$STD_CONFIG/goda-pm/local.toml")); err == nil {
			tomls = append(tomls, "local.toml")
		}

		var (
			plugins    = []pm.Plugin{}
			ftplugins  = map[string]string{}
			hooksFiles = []string{}
		)

		for _, t := range tomls {
			r, err := toml.Load(ctx, c.Host, "$STD_CONFIG/goda-pm/"+t, nil)
			if err != nil {
				return nil, err
			}
			plugins = slices.Concat(plugins, r.Plugins)

			for ft, lines := range r.Ftplugins {
				if _, ok := ftplugins[ft]; ok {
					ftplugins[ft] = ftplugins[ft] + "\n" + lines
				} else {
					ftplugins[ft] = lines
				}
			}
			if r.HooksFile != "" {
				hooksFiles = append(hooksFiles, r.HooksFile)
			}
		}

		r, err := lazy.MakeState(ctx, c.Host, plugins)
		if err != nil {
			return nil, err
		}
		return &pm.ConfigReturn{
			Plugins:    r.Plugins,
			StateLines: r.StateLines,
			Ftplugins:  ftplugins,
			HooksFiles: hooksFiles,
		}, nil
	})

	b.Main()
}
