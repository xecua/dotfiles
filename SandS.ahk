SetTitleMatchMode, RegEx
; disable in specific application
#If !WinActive("^Minecraft") && !WinActive("^Danganronpa")

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#InstallKeybdHook
; https://qiita.com/azuwai2/items/e65af02c061ce80ccf91
$Space::
    if SandS_guard = True           ;スペースキーガード
        return
    SandS_guard = True              ;スペースキーにガードをかける
    Send,{Shift Down}               ;シフトキーを仮想的に押し下げる
    ifNotEqual SandS_key            ;既に入力済みの場合は抜ける
        return
    SandS_key=
    Input,SandS_key,L1 V            ;1文字入力を受け付け（入力有無判定用）
    return

$Space up::                         ;スペース解放時
    input                           ;既存のInputコマンドの終了
    if SandS_guard = False          ;ガードがかかってなかった場合（修飾キー＋Spaceのリリース）
        return
    SandS_guard = False             ;スペースキーガードを外す
    Send,{Shift Up}                 ;シフトキー解放
    ifEqual SandS_key               ;SandS文字入力なし
        Send,{Space}                ;スペースを発射
    SandS_key=
    return
