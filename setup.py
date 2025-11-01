#!/usr/bin/env python
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "tomli-w",
# ]
# ///
#

# ↑ PEP 723のinline script metadataってやつ uv runとかで実行すると仮想環境作って入れて実行してくれるらしい

import sys
import os
from pathlib import Path
from typing import Any
# import subprocess
import tomli_w

script_dir = Path(__file__).parent

argv = sys.argv[1:]
force = '--force' in argv

home = Path.home()
config_home = Path(os.getenv("XDG_CONFIG_HOME", home / '.config'))
cache_home = Path(os.getenv("XDG_CACHE_HOME", home / '.cache'))
data_home = Path(os.getenv("XDG_DATA_HOME", home / '.local' / 'share'))
binary_path = home / '.local' / 'bin'
uname = os.uname()


def main():
    make_symlink('dunst', config_home)
    make_symlink('fd', config_home)
    make_symlink('fish', config_home, True)
    make_symlink('fontconfig', config_home)
    make_symlink('ghostty/config', config_home)  # themeをうっかり入れるとライセンス違反になる
    make_symlink('git', config_home)
    make_symlink('gtk-3.0', config_home)
    make_symlink('hypr', config_home)
    make_symlink('hypr/workspaces.conf', config_home,
                 target= script_dir / 'hypr' / 'workspaces' / f'{uname.nodename}')
    make_symlink('ideavim', config_home)
    make_symlink('kanshi/config',
                 config_home,
                 target=script_dir / 'kanshi' / uname.nodename)
    make_symlink('karabiner', config_home, True)
    make_symlink('latexmk', config_home, True)
    make_symlink('lazygit', config_home, True)
    make_symlink('nvim', config_home)
    make_symlink('ripgrep', config_home)
    make_symlink('.satysfi/local/packages',
                 home,
                 target=script_dir / 'satysfi' / 'packages')
    make_symlink('libskk', config_home, True, target=script_dir /'skk' / 'libskk')
    make_symlink('systemd/user', config_home, True)
    make_symlink('tmux', config_home, True)
    make_symlink('walker', config_home, True)
    make_symlink('waybar', config_home)
    make_symlink('xremap', config_home)
    make_symlink('zathura', config_home)

    make_symlink('.bashrc', home)
    make_symlink('.bash_profile', home)
    make_symlink('.clang-format', home)
    make_symlink('.mutagen.yml', home)
    make_symlink('.myclirc', home)
    make_symlink('.profile', home)
    make_symlink('.zprofile', home)
    make_symlink('.zshrc', home)

    make_symlink('fzf-preview.sh', binary_path)
    make_symlink('fzfrc', config_home)
    make_symlink('lesskey', config_home)
    make_symlink('starship.toml', config_home)

    write_file(config_home / 'wgetrc', [
        f'hsts-file = {cache_home / 'wget-hsts'}'
    ])

    write_file(home / '.indentconfig.yaml', [
        f'paths:',
        f'  - {script_dir / 'latexindent' / 'setting.yaml'}'
    ])

    # WSLとかでフォントサイズいじりたいので
    neovide_config: dict[str, Any] = { "fork": True, 'title-hidden': True }
    if uname.sysname == 'Darwin':
        neovide_config['frame'] = 'buttonless'
    write_file(config_home / 'neovide' / 'config.toml', tomli_w.dumps(neovide_config))

    # try:
    #     subprocess.run(['npm', 'set', 'prefix', data_home / 'npm'])
    #     subprocess.run(['npm', 'set', 'cache', cache_home / 'npm'])
    #     subprocess.run([
    #         'npm', 'set', 'init-module',
    #         config_home / 'npm' / 'config' / 'npm-init.js'
    #     ])
    # except:
    #     print("npm does not exist.",
    #           "Please setup manually or run this script again.")


def write_file(path: Path, lines: str | list[str]):
    lines = lines if isinstance(lines, list) else [lines]
    if not path.parent.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        print(f"{path} exists. Skipped.")
        return
    with open(path, 'w') as f:
        print(*lines, sep='\n', file=f)
        print(f"Created: {path}", file=sys.stderr)


def make_symlink(name: str | os.PathLike,
                 link_base: Path,
                 recursive=False,
                 *,
                 target: str | os.PathLike | None = None):
    link = link_base / name
    if not link.parent.exists():
        link.parent.mkdir(parents=True, exist_ok=True)

    if link.exists():
        if link.is_dir(follow_symlinks=False):
            # symlinkでないディレクトリ: recursiveなら中身で判定。そうでなければreturn
            if not recursive:
                print(f"{link} exists. Skipped.")
                return
        elif force:
            # fileかsymlink: forece
            link.unlink()
        else:
            print(f"{link} exists. Skipped.")
            return

    if target is None:
        target = script_dir / name
    else:
        target = Path(target)

    if target.is_dir() and recursive:
        for p in target.iterdir():
            link_path = Path(name, p.name)
            target_path = target / p.name
            make_symlink(link_path, link_base, True, target=target_path)
    else:
        link.symlink_to(target, target_is_directory=True)
        print(f"Linked: {link} -> {target}", file=sys.stderr)


if __name__ == '__main__':
    main()
