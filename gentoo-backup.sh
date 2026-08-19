#!/bin/bash
# /etc/portage・world・カーネルconfigを hosts/$(hostname)/ に取り込んでcommit & pushする。
# systemdのuser timer (systemd/user/gentoo-backup.timer) から週次で叩かれる。
#
# 重要: このスクリプトはdotfilesリポジトリの中で動く。
#       普段編集しているファイルを巻き込まないよう、
#       git操作の対象は必ず hosts/$(hostname) に限定すること。
set -euo pipefail

repo="$(git -C "$(dirname "$(readlink -f "$0")")" rev-parse --show-toplevel)"
host="$(hostname)"
prefix="hosts/$host"
dest="$repo/$prefix"

git_() { git -C "$repo" "$@"; }

# rebase/merge途中に割り込むと事故るので何もしない
git_dir="$(git_ rev-parse --git-dir)"
if [[ -e "$git_dir/rebase-merge" || -e "$git_dir/rebase-apply" || -e "$git_dir/MERGE_HEAD" ]]; then
  echo "rebase/merge in progress. Backup skipped." >&2
  exit 1
fi

# コピー
mkdir -p "$dest"
# XDGの ~/.config と紛らわしいのでkernel.configという名前で置く
cp /usr/src/linux/.config "$dest/kernel.config"
cp /var/lib/portage/world "$dest/world"
rsync --mkpath -a --delete \
  --exclude=make.profile \
  --exclude=gnupg \
  --exclude='*~' \
  /etc/portage/ "$dest/portage/"

# コミット
git_ add -- "$prefix"
if git_ diff --cached --quiet -- "$prefix"; then
  echo "No changes. Backup skipped."
  exit 0
fi
# --only: 他のパスがステージされていてもこのpathspecだけをcommitする
git_ commit --only --no-gpg-sign -m "backup: $(date '+%Y-%m-%d')" -- "$prefix"

# プッシュ
branch="$(git_ symbolic-ref --quiet --short HEAD || true)"
if [[ -z "$branch" ]]; then
  echo "detached HEAD. Commit created but not pushed." >&2
  exit 1
fi

if git_ push origin "$branch"; then
  exit 0
fi

# リモートが進んでいた場合のみリトライする。
# 作業ツリーが汚れていても壊さないよう--autostash、
# conflictしたら潔く諦める (commitはローカルに残るので次回に持ち越される)
echo "push rejected. trying to rebase onto origin/$branch..." >&2
if ! git_ pull --rebase --autostash origin "$branch"; then
  git_ rebase --abort 2>/dev/null || true
  echo "rebase failed. The backup commit is left locally. Retry next time." >&2
  exit 1
fi
git_ push origin "$branch"
