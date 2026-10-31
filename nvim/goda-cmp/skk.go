package main

import (
	"encoding/json"
	"log"
	"os"

	"github.com/Shougo/goda-skk.vim/engine"
)

func newSkk() *engine.Plugin {
	p, err := engine.New(engine.Config{
		KanaTable:    engine.NewKanaTable(azikRules...),
		Dictionaries: dictionaries(),
		Keymaps: map[string]map[string]string{
			"input": {"'": "henkanPoint"},
			"henkan": {
				"X": "", // 既定の purgeCandidate を外す
				"<": "purgeCandidate",
			},
		},
		// 可能ならコマンドラインのときだけ▽を出したい
		MarkerHenkan:        new(""),
		MarkerHenkanSelect:  new(""),
		ShowCandidatesCount: 1,
		LowercaseMap:        map[string]string{":": ";"},
		EggLikeNewline:      true,
		ImmediatelyCancel:   new(false),
		SetUndoPoint:        new(false),
	})
	if err != nil {
		log.Fatal(err)
	}
	return p
}

// dictionaries は環境変数 GODA_SKK_DICTIONARIES (JSON) から辞書を作る。
// 中身は "path" または ["path", "encoding"] の配列 (Lua 側の get_local_config().skk_dictionaries)。
// 辞書の場所はマシンごとに違う (dpp のリポジトリパスや local.lua) ので、Neovim 側で組み立てて渡す。
func dictionaries() []engine.Dictionary {
	raw := os.Getenv("GODA_SKK_DICTIONARIES")
	if raw == "" {
		return nil
	}
	var entries []json.RawMessage
	if err := json.Unmarshal([]byte(raw), &entries); err != nil {
		log.Printf("GODA_SKK_DICTIONARIES: %v", err)
		return nil
	}
	var dicts []engine.Dictionary
	for _, e := range entries {
		var path string
		if json.Unmarshal(e, &path) == nil {
			dicts = append(dicts, engine.NewJisyo(path, ""))
			continue
		}
		var pair []string
		if err := json.Unmarshal(e, &pair); err != nil || len(pair) == 0 {
			log.Printf("GODA_SKK_DICTIONARIES: invalid entry %s", e)
			continue
		}
		enc := ""
		if len(pair) > 1 {
			enc = pair[1]
		}
		dicts = append(dicts, engine.NewJisyo(pair[0], enc))
	}
	return dicts
}
