#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pyyaml",
# ]
# ///
#

# ↑ PEP 723のinline script metadataってやつ uv runとかで実行すると仮想環境作って入れて実行してくれるらしい

import sys
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

# import subprocess
import yaml

script_dir = Path(__file__).parent

argv = sys.argv[1:]
force = "--force" in argv

home = Path.home()
config_home = Path(os.getenv("XDG_CONFIG_HOME", home / ".config"))
cache_home = Path(os.getenv("XDG_CACHE_HOME", home / ".cache"))
data_home = Path(os.getenv("XDG_DATA_HOME", home / ".local" / "share"))
binary_path = home / ".local" / "bin"
uname = os.uname()


LINK_BASES = {"config": config_home, "home": home, "bin": binary_path}


@dataclass
class LinkSpec:
    name: str
    link_base: Path
    recursive: bool
    target: Path | None


def load_links(path: Path) -> list[LinkSpec]:
    with open(path) as f:
        data = yaml.safe_load(f)

    specs = []
    for entry in data["links"]:
        target = entry.get("target")
        target_path = (
            script_dir / target.replace("{hostname}", uname.nodename)
            if target is not None
            else None
        )

        if entry.get("condition") == "exists":
            check_path = target_path if target_path is not None else script_dir / entry["name"]
            if not check_path.exists():
                continue

        specs.append(
            LinkSpec(
                name=entry["name"],
                link_base=LINK_BASES[entry["base"]],
                recursive=entry.get("recursive", False),
                target=target_path,
            )
        )
    return specs


def main():
    for spec in load_links(script_dir / "links.yaml"):
        make_symlink(spec.name, spec.link_base, spec.recursive, target=spec.target)

    write_file(config_home / "wgetrc", [f"hsts-file = {cache_home / 'wget-hsts'}"])

    write_file(
        home / ".indentconfig.yaml",
        [f"paths:", f"  - {script_dir / 'latexindent' / 'setting.yaml'}"],
    )


def write_file(path: Path, lines: str | list[str]):
    lines = lines if isinstance(lines, list) else [lines]
    if not path.parent.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        print(f"{path} already exists. Skipped.")
        return
    with open(path, "w") as f:
        print(*lines, sep="\n", file=f)
        print(f"Created: {path}", file=sys.stderr)


def make_symlink(
    name: str | os.PathLike,
    link_base: Path,
    recursive=False,
    *,
    target: str | os.PathLike | None = None,
):
    link = link_base / name
    if not link.parent.exists():
        link.parent.mkdir(parents=True, exist_ok=True)

    if link.exists():
        if link.is_dir(follow_symlinks=False):
            # symlinkでないディレクトリ: recursiveなら中身で判定。そうでなければreturn
            if not recursive:
                print(f"{link} already exists. Skipped.")
                return
        elif force:
            # fileかsymlink: forece
            link.unlink()
        else:
            if link.is_symlink():
                print(f"{link} is already symlink. Skipped.")
            else:
                print(f"{link} exists and but is not a symlink.", file=sys.stderr)
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


if __name__ == "__main__":
    main()
