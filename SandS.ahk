#Requires AutoHotkey v2.0
; https://gist.github.com/eihigh/41fefcf7c9e8f2a6f1e47a3c7d7a6df5

press := 0     ; スペースキーを押しているかどうか。
shifted := 0   ; スペースキー押下中に何かの印字可能文字を押したかどうか。
pressedAt := 0 ; スペースキーを押した時間（msec）。
timeout := 300 ; pressedAt からこの時間が経過したら、もはや離したときにもスペースを発射しない。

hook := InputHook() ; スペースキー押下中に何かの印字可能文字を押したかどうか捕捉するフック。

$*Space:: {
	global
	SendInput "{Shift Down}"
	if (press = 1) {
		return
	}
	shifted := 0
	press := 1
	pressedAt := A_TickCount

	; 何かのキーが押されたことを検知する
	; L1 はフックする文字数の上限を 1 にする
	; V はフックした入力をブロックしない
	; デフォルトで印字可能文字のみフックされる
	hook := InputHook("L1 V")

	; 一文字待機し、待機中にスペースを離したとき以外、
	; シフト済みにする
	hook.Start()
	if (hook.Wait() != "Stopped") {
		shifted := 1
	}
}

$*Space up:: {
	global
	SendInput "{Shift Up}"
	press := 0

	; 待機キャンセル
	hook.Stop()

	; 一定時間経過していたらスペースを発射しない
	if (A_TickCount - pressedAt > timeout) {
		return
	}

	; シフト済みでなければスペースを発射する
	; 先に押してあるモディファイアキーと組み合わせられるように {Blind} をつける
	if (shifted == 0) {
		SendInput "{Blind}{Space}"
	}
}

; スペース押しっぱなしが欲しいときのために RShift で代用する
; $RShift::Space
