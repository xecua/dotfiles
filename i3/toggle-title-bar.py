#!/usr/bin/env python3

# Save this script to ~/.i3/toggle-title-bar.py, then add the following to
# your ~/.i3/config file:
#
#   # toggle title bar
#   bindsym $mod+t exec ~/.i3/toggle-title-bar.py
#
# Author: Leandro Lovisolo <leandro@leandro.me>
#         https://github.com/LeandroLovisolo

# Original: https://gist.github.com/LeandroLovisolo/7d25271504283543f305
# Edit: use `i3ipc` instead of `i3ipc-glib`

from i3ipc import Connection

i3 = Connection()

border = i3.get_tree().find_focused().border

if border == "normal":
    i3.command("border pixel 1")
else:
    i3.command("border normal")
