# Windows 用のシンボリックリンクを links.windows.psd1 に従って作成する
# Unix 環境では setup.py + links.yaml を使う
#
# 使い方: pwsh -File setup.ps1 [-Force]
#   -Force: 別の場所を指すリンクは張り直し、実体のファイル / ディレクトリは <name>.bak-<日時> に退避してから張る
#
# シンボリックリンクの作成には次のどちらかが必要
#   - 開発者モードを有効にして PowerShell 7 で実行する (Windows PowerShell 5.1 は開発者モードだけでは作れない)
#   - 管理者として実行する

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$repoRoot = $PSScriptRoot
$spec = Import-PowerShellDataFile -LiteralPath (Join-Path $repoRoot 'links.windows.psd1')

$bases = @{
    Home         = $HOME
    AppData      = $env:APPDATA
    LocalAppData = $env:LOCALAPPDATA
    Documents    = [Environment]::GetFolderPath('MyDocuments')
}

function Resolve-BasePath([string]$Base, [string]$Path) {
    if (-not $bases.ContainsKey($Base)) {
        throw "Unknown Base: $Base"
    }
    if ([string]::IsNullOrEmpty($bases[$Base])) {
        throw "Base '$Base' could not be resolved"
    }
    return [System.IO.Path]::GetFullPath((Join-Path $bases[$Base] $Path))
}

# リンク自体の属性を返す (リンク先はたどらない)。存在しなければ $null
function Get-LinkAttributes([string]$Path) {
    try {
        return [System.IO.File]::GetAttributes($Path)
    } catch {
        return $null
    }
}

function Remove-Link([string]$Path, [System.IO.FileAttributes]$Attributes) {
    # Remove-Item はディレクトリへのリンクで中身を消しにいくことがあるので .NET で消す
    if ($Attributes -band [System.IO.FileAttributes]::Directory) {
        [System.IO.Directory]::Delete($Path, $false)
    } else {
        [System.IO.File]::Delete($Path)
    }
}

$failed = $false

foreach ($entry in $spec.Links) {
    $targetRel = if ($entry.Target) { $entry.Target } else { $entry.Name }
    $target = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $targetRel))
    try {
        $link = Resolve-BasePath $entry.Base $entry.Name
    } catch {
        Write-Error -ErrorAction Continue "Skipped $($entry.Name): $($_.Exception.Message)"
        $failed = $true
        continue
    }

    if (-not (Test-Path -LiteralPath $target)) {
        if ($entry.Condition -ne 'Exists') {
            Write-Warning "Target not found: $target"
        }
        continue
    }

    $attr = Get-LinkAttributes $link
    if ($null -ne $attr) {
        if ($attr -band [System.IO.FileAttributes]::ReparsePoint) {
            $current = $null
            try { $current = (Get-Item -LiteralPath $link -Force).Target } catch {}
            if ($current -is [array]) { $current = $current[0] }
            if ($current -and [System.IO.Path]::GetFullPath($current) -eq $target) {
                Write-Host "$link is already linked. Skipped."
                continue
            }
            if (-not $Force) {
                Write-Host "$link is a link to another location ($current). Skipped."
                continue
            }
            Remove-Link $link $attr
        } else {
            if (-not $Force) {
                Write-Warning "$link exists but is not a symlink. Skipped."
                continue
            }
            $backup = "$link.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item -LiteralPath $link -Destination $backup
            Write-Host "Moved: $link -> $backup"
        }
    }

    $parent = Split-Path -Parent $link
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
        Write-Host "Linked: $link -> $target"
    } catch {
        Write-Error -ErrorAction Continue "Failed to link $link -> ${target}: $($_.Exception.Message)"
        $failed = $true
    }
}

if ($spec.Env) {
    foreach ($name in $spec.Env.Keys) {
        $value = Resolve-BasePath $spec.Env[$name].Base $spec.Env[$name].Path
        if ([Environment]::GetEnvironmentVariable($name, 'User') -eq $value) {
            Write-Host "Env $name is already set. Skipped."
        } else {
            [Environment]::SetEnvironmentVariable($name, $value, 'User')
            Write-Host "Env: $name = $value"
        }
        # 以降このセッションでも使えるように
        Set-Item -Path "Env:$name" -Value $value
    }
}

if ($failed) {
    Write-Host ''
    Write-Host '失敗したものがあります (上のエラーを参照)。'
    Write-Host 'シンボリックリンクの作成で失敗した場合は、開発者モードを有効にして PowerShell 7 で実行するか、管理者として実行してください。'
    exit 1
}
