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


def make_symlink(link: Path, target: Path):
    if not link.parent.exists():
        link.parent.mkdir(exist_ok=True)

    if not target.exists():
        link.symlink_to(target, target_is_directory=True)
        print(f"Linked: {link} -> {target}", file=sys.stderr)
    else:
        print(f"Not linked: {link}", file=sys.stderr)


make_symlink(config_home / 'fish' / 'conf.d', script_dir / 'fish' / 'conf.d')

make_symlink(home / '.profile', script_dir / '.profile')
make_symlink(home / '.bashrc', script_dir / '.bashrc')
make_symlink(home / '.bash_profile', script_dir / '.bash_profile')
make_symlink(home / '.zprofile', script_dir / '.zprofile')
make_symlink(home / '.zshrc', script_dir / '.zshrc')

make_symlink(home / '.mutagen.yml', script_dir / '.mutagen.yml')
make_symlink(home / '.clang-format', script_dir / '.clang-format')

make_symlink(config_home / 'nvim', script_dir / 'nvim')
make_symlink(config_home / 'ideavim', script_dir / 'ideavim')
make_symlink(config_home / 'git', script_dir / 'git')
make_symlink(config_home / 'tig', script_dir / 'tig')
make_symlink(config_home / 'picom', script_dir / 'picom')
make_symlink(config_home / 'ripgrep', script_dir / 'ripgrep')
make_symlink(config_home / 'i3', script_dir / 'i3')
make_symlink(config_home / 'i3status-rust', script_dir / 'i3status-rust')
make_symlink(config_home / 'dunst', script_dir / 'dunst')
make_symlink(config_home / 'sway', script_dir / 'sway')
make_symlink(config_home / 'swaylock', script_dir / 'swaylock')
make_symlink(config_home / 'starship.toml', script_dir / 'starship.toml')

make_symlink(home / '.satysfi' / 'local' / 'packages',
             script_dir / 'satysfi' / 'packages')
make_symlink(config_home / 'latexmk' / 'latexmkrc',
             script_dir / 'latexmk' / 'latexmkrc')
make_symlink(config_home / 'tmux' / 'tmux.conf',
             script_dir / 'tmux' / 'tmux.conf')

make_symlink(config_home / 'ranger' / 'rc.conf',
             script_dir / 'ranger' / 'rc.conf')
make_symlink(config_home / 'ranger' / 'rifle.conf',
             script_dir / 'ranger' / 'rifle.conf')

make_symlink(config_home / 'alacritty', script_dir / 'alacritty')
if not (home / '.alacritty.local.yml').exists():
    # create
    open(home / '.alacritty.local.yml').close()

# Linux only
make_symlink(config_home / 'xremap', script_dir / 'xremap')
make_symlink(config_home / 'kanshi', script_dir / 'kanshi')
make_symlink(config_home / 'fontconfig', script_dir / 'fontconfig')
make_symlink(config_home / 'zathura', script_dir / 'zathura')
make_symlink(config_home / 'libskk' / 'rules',
             script_dir / 'skk' / 'libskk' / 'rules')

if not (config_home / 'rofi').exists():
    setup_sh_path = script_dir / 'rofi' / 'setup.sh'
    setup_sh_path.chmod(0o755)
    subprocess.run(setup_sh_path)
    (script_dir / 'rofi_scripts' / 'rofi_launcher').symlink_to(
        home / '.local' / 'bin' / 'rofi_launcher')
    (script_dir / 'rofi_scripts' / 'rofi_powermenu').symlink_to(
        home / '.local' / 'bin' / 'rofi_powermenu')
    (script_dir / 'rofi_scripts' / 'rofi_screenshot').symlink_to(
        home / '.local' / 'bin' / 'rofi_scripts')
    (script_dir / 'rofi_scripts' / 'rofi_volume').symlink_to(
        home / '.local' / 'bin' / 'rofi_volume')

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

npm_check = subprocess.run(['npm', '-v'],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
if npm_check.returncode == 0:
    subprocess.run(['npm', 'set', 'prefix', data_home / 'npm'])
    subprocess.run(['npm', 'set', 'cache', cache_home / 'npm'])
    subprocess.run([
        'npm', 'set', 'init-module',
        config_home / 'npm' / 'config' / 'npm-init.js'
    ])

# for yarn berry?
# yarn_check = subprocess.run(['yarn', '-v'],
#                             stdout=subprocess.DEVNULL,
#                             stderr=subprocess.DEVNULL)
# if yarn_check.returncode == 0:
#     subprocess.run(['yarn', 'set', 'prefix', data_home / 'yarn'])
