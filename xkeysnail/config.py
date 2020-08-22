# configuration file for xkeysnail(https://github.com/mooz/xkeysnail)
# daemonize using systemd: https://ohmyenter.com/how-to-install-and-autostart-xkeysnail/#%E8%87%AA%E5%8B%95%E8%B5%B7%E5%8B%95
# note: arch linux need load uinput kernel module by adding file written 'uinput' to /etc/modules-load.d
import re
from xkeysnail.transform import *

# multipurpose timeout
define_timeout(2)

# mapping Left Super to Muhenkan and Right Super to Henkan
# by which you can switch IME by simply pushing these keys
# with input method configuration which maps Muhenkan to "disable IME" and Henkan to "enable IME,"
define_multipurpose_modmap({
    Key.LEFT_META: [Key.MUHENKAN, Key.LEFT_META],
    Key.RIGHT_META: [Key.HENKAN, Key.RIGHT_META],
    # SandS
    Key.SPACE: [Key.SPACE, Key.LEFT_SHIFT]
})


