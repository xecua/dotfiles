#! /bin/bash
# copyright: https://qiita.com/tayusa/items/3f44673c1493ae352fc0

set -euCo pipefail

function main() {
  # 表示したい項目と実際に実行するコマンドを連想配列として定義する。
  local -Ar menu=(
    ['Lock']='loginctl lock-session'
    ['Logout']='i3-msg exit'
    ['Suspend']='systemctl suspend'
    ['Hibernate']='systemctl hibernate'
    ['Poweroff']='systemctl poweroff'
    ['Reboot']='systemctl reboot'
  )

  local -r IFS=$'\n'
  # 引数があるなら$1に対応するコマンドを実行する。
  # 引数がないなら連想配列のkeyを表示する。
  [[ $# -ne 0 ]] && eval "${menu[$1]}" || echo "${!menu[*]}"
}

main $@
