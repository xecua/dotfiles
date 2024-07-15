#!/usr/bin/env python

import sys
import os
from pathlib import Path
import subprocess
from textwrap import dedent

script_dir = Path(__file__).parent

home = Path.home()
config_home = Path(os.getenv("XDG_CONFIG_HOME", home / '.config'))
cache_home = Path(os.getenv("XDG_CACHE_HOME", home / '.cache'))
data_home = Path(os.getenv("XDG_DATA_HOME", home / '.local' / 'share'))
# TODO: Windows(cause error below?)
# TODO: macOS(AquaSKK, Brewfile, yabai, skhd)
uname = os.uname().sysname


def make_symlink(link: Path, target: Path | None = None):
    if not link.parent.exists():
        link.parent.mkdir(parents=True, exist_ok=True)

    if target is None:
        target = script_dir / link.name

    if not link.exists():
        link.symlink_to(target, target_is_directory=True)
        print(f"Linked: {link} -> {target}", file=sys.stderr)
    else:
        print(f"Not linked: {link}", file=sys.stderr)


make_symlink(config_home / 'fish' / 'completions',
             script_dir / 'fish' / 'completions')
make_symlink(config_home / 'fish' / 'conf.d', script_dir / 'fish' / 'conf.d')

make_symlink(home / '.profile')
make_symlink(home / '.bashrc')
make_symlink(home / '.bash_profile')
make_symlink(home / '.zprofile')
make_symlink(home / '.zshrc')

make_symlink(home / '.mutagen.yml')
make_symlink(home / '.clang-format')

make_symlink(config_home / 'broot')
make_symlink(config_home / 'nvim')
make_symlink(config_home / 'ideavim')
make_symlink(config_home / 'git')
make_symlink(config_home / 'lazygit' / 'config.yml', script_dir / 'lazygit' / 'config.yml')
make_symlink(config_home / 'fd')
make_symlink(config_home / 'picom')
make_symlink(config_home / 'ripgrep')
make_symlink(config_home / 'i3')
make_symlink(config_home / 'i3status-rust')
make_symlink(config_home / 'i3bar-river')
make_symlink(config_home / 'dunst')
make_symlink(config_home / 'sway')
make_symlink(config_home / 'swaylock')
make_symlink(config_home / 'hypr')
make_symlink(config_home / 'starship.toml')

make_symlink(home / '.satysfi' / 'local' / 'packages',
             script_dir / 'satysfi' / 'packages')
make_symlink(config_home / 'latexmk' / 'latexmkrc',
             script_dir / 'latexmk' / 'latexmkrc')
make_symlink(config_home / 'tmux' / 'tmux.conf',
             script_dir / 'tmux' / 'tmux.conf')
make_symlink(config_home / 'wezterm')

make_symlink(config_home / 'ranger' / 'rc.conf',
             script_dir / 'ranger' / 'rc.conf')
make_symlink(config_home / 'ranger' / 'rifle.conf',
             script_dir / 'ranger' / 'rifle.conf')

make_symlink(config_home / 'alacritty')
if not (home / '.alacritty.local.toml').exists():
    # create
    (home / '.alacritty.local.toml').touch()

# Linux only
make_symlink(config_home / 'xremap')
make_symlink(config_home / 'kanshi')
make_symlink(config_home / 'fontconfig')
make_symlink(config_home / 'zathura')
make_symlink(config_home / 'libskk' / 'rules',
             script_dir / 'skk' / 'libskk' / 'rules')
make_symlink(config_home / 'libcskk' / 'rules',
             script_dir / 'skk' / 'libcskk' / 'rules')

for p in (script_dir / 'systemd' / 'user').iterdir():
    base_name = p.name
    make_symlink(config_home / 'systemd' / 'user' / base_name, p.resolve())

if not (config_home / 'rofi').exists():
    rofi_path = script_dir / 'rofi'
    setup_sh_path = rofi_path / 'setup.sh'
    setup_sh_path.chmod(0o755)
    subprocess.run(setup_sh_path, cwd=rofi_path)
    make_symlink( home / '.local' / 'bin' / 'rofi_launcher', script_dir / 'rofi_scripts' / 'rofi_launcher')
    make_symlink( home / '.local' / 'bin' / 'rofi_powermenu', script_dir / 'rofi_scripts' / 'rofi_powermenu')
    make_symlink( home / '.local' / 'bin' / 'rofi_scripts', script_dir / 'rofi_scripts' / 'rofi_screenshot')
    make_symlink( home / '.local' / 'bin' / 'rofi_volume', script_dir / 'rofi_scripts' / 'rofi_volume')

if not (config_home / 'wgetrc').exists():
    hsts_file_path = cache_home / 'wget-hsts'
    with open(config_home / 'wgetrc', 'w') as f:
        print(f'hsts-file = {hsts_file_path}', file=f)
        print("wget was created.", file=sys.stderr)
else:
    print("wget was not created.", file=sys.stderr)

if not (home / '.indentconfig.yaml').exists():
    with open(home / '.indentconfig.yaml', 'w') as f:
        print(dedent(f"""\
        paths:
          - {script_dir / 'latexindent' / 'setting.yaml'}
        """),
              file=f)
        print("indentconfig.yaml was created.", file=sys.stderr)
else:
    print("indentconfig.yaml was not created.", file=sys.stderr)

try:
    subprocess.run(['npm', 'set', 'prefix', data_home / 'npm'])
    subprocess.run(['npm', 'set', 'cache', cache_home / 'npm'])
    subprocess.run([
        'npm', 'set', 'init-module',
        config_home / 'npm' / 'config' / 'npm-init.js'
    ])
except:
    print("npm does not exist.",
          "Please setup manually or run this script again.")
