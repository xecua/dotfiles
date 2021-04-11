#!/usr/bin/env python3

# Save this script to ~/.i3/toggle-title-bar.py, then add the following to
# your ~/.i3/config file:
# 
#   # toggle title bar
#   bindsym $mod+t exec ~/.i3/toggle-title-bar.py
#
# Author: Leandro Lovisolo <leandro@leandro.me>
#         https://github.com/LeandroLovisolo

from gi.repository import i3ipc

i3 = i3ipc.Connection()

border = i3.get_tree().find_focused().get_property("border")

if border == "normal":
  i3.command("border 1pixel")
else:
  i3.command("border normal")