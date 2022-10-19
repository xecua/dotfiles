if (Get-Command "starship" -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# https://blog.mamansoft.net/2020/05/31/windows-terminal-and-power-shell-makes-beautiful/#%E6%96%87%E5%AD%97%E5%8C%96%E3%81%91%E3%82%92%E8%A7%A3%E6%B6%88%E3%81%99%E3%82%8B
# PowerShell CoreでもConsoleのデフォルトエンコーディングはsjisなので必要
[System.Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[System.Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

# git logなどのマルチバイト文字を表示させるため (絵文字含む)
$env:LESSCHARSET = "utf-8"

Set-Alias vim nvim
Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function ViExit
Set-PSReadLineKeyHandler -Key "Ctrl+u" -Function BackwardDeleteLine
Set-PSReadLineKeyHandler -Key "Ctrl+k" -Function ForwardDeleteLine
Set-PSReadLineKeyHandler -Key "Ctrl+a" -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key "Ctrl+e" -Function EndOfLine
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardChar
Set-PSReadLineKeyHandler -Key "Ctrl+e" -Function BackwardChar
