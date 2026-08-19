# Gentooまわりのメモ

`hosts/{hostname}/` に `/etc/portage`・`world`・カーネルconfigのバックアップを置いている。
更新は `gentoo-backup.sh` (systemdのuser timerで週次) が自動でやる。

## 原則

入れているもののリストはこのリポジトリ内でどうにかして把握できる状態にしたい。
Gentooであればworldかhome-manager。
OSの標準的なツールを使った方がトラブルの原因になりにくいので、Gentooであればworldの方が望ましい

Nixによって得られる再現性のことはあんまり気にしてない

## 開発に使うもの

プロジェクト単位のflake.nixで管理したいところだが、そうもいかない

- プログラミング言語実行環境(コンパイラ/インタプリタ)
  - portageでのアプリケーションのビルドや実行に必要なことがある。その依存関係として入ってもよい
  - REPLなどを利用したいときがある。そのために入っていてもよい
  - この理屈でいくとtestingにする理由があんまりない 実際ないかも
- プログラミング言語バージョン管理(rustup、fvmなど)
  - そんなに必要になることがないんじゃないか? ということで基本入れたくない
  - 必要になったら原則に基づいてportage->home-managerの優先順位で。
- ビルドツール(uvなど)
  - flake.nixにあるのが一番いい。必要になったときは原則通り。
- LSPサーバ・フォーマッタ・リンタ
  - flake.nixとかpackage.jsonであるべきだよなあ
  - portage -> home-managerなのかなあ
    - styluaはportageで入れると(現時点で)`lsp` featureが有効にできない。nixの方は引数でfeatureを調整できる。とりあえずhome-managerで
      - いうてもNeovimの設定ファイル書くときくらいしか使わんのでdotfilesにflake.nix置いとけばとりあえず解決しそう。そうする(これでもfeatureの上書きは必要だけど)

## portageでもhome-managerでも入らないもの

どうすんの?ここにメモしておくくらいしかない

試してないだけの人もいる

- elio
- neovide
- zlib (kevin/cantwell/zlib)
- xwayland-satellite
- codelldb
- java-debug-adapter
- java-test
- jdtls
- php-debug-adapter
- phpcs
- android sdk?
- jnv
- gup (go update)
- modvendor (go)

## direnv + nix-direnv

nix-direnvはdirenv-stdlibの`use flake`を置換する形で実装されている
単体で入れてもいいけど、~/.nix-profile/share/nix-direnv/direnvrcを~/.config/direnv/direnvrcに置くというめんどくさいことをしないといけない
それくらいならportageじゃなくてhome-managerで入れてもいいかもなあ……の気持ち
