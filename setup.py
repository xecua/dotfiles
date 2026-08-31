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
from pathlib import Path, PurePath
from typing import Any

# import subprocess
import yaml

script_dir = Path(__file__).parent

argv = sys.argv[1:]
force = "--force" in argv or "-f" in argv

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


GLOB_CHARS = ("*", "?", "[")


def has_glob(pattern: str) -> bool:
    return any(c in pattern for c in GLOB_CHARS)


def static_depth(pattern: str) -> int:
    """パターン先頭の、glob文字を含まないパス要素の数"""
    parts = PurePath(pattern).parts
    for i, part in enumerate(parts):
        if has_glob(part):
            return i
    return len(parts)


def expand_glob(pattern: str, name: str | None) -> list[tuple[str, Path]]:
    """globパターンを展開し、(リンク名, リンク先) の組を返す

    name が None (= target 省略時、name 自体がパターン) の場合は、
    リポジトリルートからの相対パスがそのままリンク名になる。
    name がある場合は、パターン先頭の固定部分 (glob文字を含まないパス要素) を
    取り除いた残りを name の下にぶら下げる。
    """
    depth = static_depth(pattern)
    results = []
    for matched in sorted(script_dir.glob(pattern)):
        rel = matched.relative_to(script_dir)
        link_name = rel if name is None else PurePath(name, *rel.parts[depth:])
        results.append((str(link_name), matched))
    return results


def load_links(path: Path) -> list[LinkSpec]:
    with open(path) as f:
        data = yaml.safe_load(f)

    specs = []
    for entry in data["links"]:
        name = entry["name"]
        link_base = LINK_BASES[entry["base"]]
        recursive = entry.get("recursive", False)
        target = entry.get("target")
        source = (
            target.replace("{hostname}", uname.nodename) if target is not None else name
        )

        if has_glob(source):
            # マッチが0件ならそのエントリはスキップされる (condition: exists 相当)
            matches = expand_glob(source, name if target is not None else None)
            if not matches and entry.get("condition") != "exists":
                print(f"No match for pattern: {source}", file=sys.stderr)
            for link_name, target_path in matches:
                specs.append(
                    LinkSpec(
                        name=link_name,
                        link_base=link_base,
                        recursive=recursive,
                        target=target_path,
                    )
                )
            continue

        target_path = script_dir / source if target is not None else None

        if entry.get("condition") == "exists":
            check_path = target_path if target_path is not None else script_dir / name
            if not check_path.exists():
                continue

        specs.append(
            LinkSpec(
                name=name,
                link_base=link_base,
                recursive=recursive,
                target=target_path,
            )
        )
    return specs


def main():
    for spec in load_links(script_dir / "links.yaml"):
        make_symlink(spec.name, spec.link_base, spec.recursive, target=spec.target)


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
            # symlinkでないディレクトリ: recursiveでないなら何もしない
            if not recursive:
                print(f"{link} already exists. Skipped.")
                return
        elif force:
            # fileかsymlink
            link.unlink()
        else:
            if link.is_symlink():
                print(f"{link} is already symlink. Skipped.")
            else:
                print(f"{link} exists and but is not a symlink.", file=sys.stderr)
            return
    elif link.is_symlink() and force:
        # broken symlink
        link.unlink(missing_ok=True)

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
