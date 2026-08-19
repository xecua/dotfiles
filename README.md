# dotfiles

設定ファイル置き場。home-managerの設定 (`home.nix`) と、
Gentooのシステム情報のバックアップ (`hosts/`) も同居している。

## 構成

| パス | 中身 |
| --- | --- |
| ツール名のディレクトリ | 設定ファイル本体 |
| `links.yaml` | シンボリックリンクの宣言的定義。書式は先頭のコメント参照 |
| `setup.py` | `links.yaml` を読んでシンボリックリンクを張る |
| `flake.nix` / `home.nix` | home-managerの設定と、設定ファイルを書くとき用のdevShell |
| `hosts/{hostname}/` | `/etc/portage`・`world`・カーネルconfigのバックアップ |
| `gentoo-backup.sh` | 上記を更新してcommit & pushする (週次) |
| `docs/` | メモ |

## セットアップ

```sh
git clone --recursive https://github.com/xecua/dotfiles \
    ~/Documents/repos/github.com/xecua/dotfiles
cd ~/Documents/repos/github.com/xecua/dotfiles
./setup.py  # --force で既存のファイルを上書きする
```

`setup.py` はPEP 723のinline script metadataを使っているので `uv run setup.py` でもよい。

### home-manager

```sh
nix run home-manager/release-26.05 -- switch --flake ".#xecua@$(hostname)"
```

以降は `nh home switch` で。`programs.nh.homeFlake` がこのリポジトリを指している。

### Gentooのバックアップ (Gentooの実機のみ)

`gentoo-backup.sh` とunitは `setup.py` がリンク済みなので、有効化するだけ。

```sh
git config --local credential.helper libsecret  # timerから非対話でpushするため
systemctl --user enable --now gentoo-backup.timer
```

週次で `hosts/$(hostname)/` を更新してcommit & pushする。
git操作は `hosts/$(hostname)` に限定してあるので、
編集中のファイルを巻き込むことはない。

`systemd/system/` 以下 (portage-sync、man-db) はシステム側のunitなので、
必要なら手動で `/etc/systemd/system/` に置く。

## メモ

- [Gentooまわり](docs/gentoo.md) — 何をportage / home-manager / flakeで入れるかの方針
