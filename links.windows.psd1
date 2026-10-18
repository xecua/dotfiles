# Windows 用シンボリックリンクの宣言 (setup.ps1 が読む)
# Unix 用の links.yaml とは別管理。PowerShell 標準の Import-PowerShellDataFile で読めるよう psd1 で書く
#
# Links の各エントリ:
#   Name      : リンクを作成するパス。Base からの相対パス
#   Base      : リンクの起点
#                 Home         ~ (%USERPROFILE%)
#                 AppData      %APPDATA% (Roaming)
#                 LocalAppData %LOCALAPPDATA%
#                 Documents    ドキュメントフォルダ (OneDrive でリダイレクトされていても実際の場所)
#   Target    : リンク先。リポジトリルートからの相対パス。省略時は Name
#   Condition : 'Exists' を指定すると、Target が存在しない場合はスキップする
#
# Env: ユーザー環境変数として登録するもの。値は Links と同じ Base + Path で指定する

@{
    Links = @(
        # Git for Windows は ~/.config/git/config も読む
        @{ Name = '.config\git'; Base = 'Home'; Target = 'git' }

        # ripgrep は既定の設定ファイルを持たないので、Env の RIPGREP_CONFIG_PATH で指す
        @{ Name = '.config\ripgrep'; Base = 'Home'; Target = 'ripgrep' }

        # fd の Windows でのグローバル ignore は %APPDATA%\fd\ignore
        @{ Name = 'fd'; Base = 'AppData' }

        # stdpath('config') は %LOCALAPPDATA%\nvim
        @{ Name = 'nvim'; Base = 'LocalAppData' }

        # starship は Windows でも ~/.config/starship.toml
        @{ Name = '.config\starship.toml'; Base = 'Home'; Target = 'starship.toml' }

        # 設定ダイアログで保存すると config.xml が置き換えられることがある
        @{ Name = 'CorvusSKK\config.xml'; Base = 'AppData'; Target = 'skk\corvusskk\config.xml' }

        # PowerShell 7 の $PROFILE (CurrentUserCurrentHost)
        @{ Name = 'PowerShell\Microsoft.PowerShell_profile.ps1'; Base = 'Documents'; Target = 'Powershell\Microsoft.PowerShell_profile.ps1' }

        # 設定 GUI で保存すると config.toml が書き換えられる
        @{ Name = 'leopardwm\config\config.toml'; Base = 'AppData'; Target = 'leopardwm\config.toml' }
    )

    Env = @{
        RIPGREP_CONFIG_PATH = @{ Base = 'Home'; Path = '.config\ripgrep\ripgreprc' }
    }
}
