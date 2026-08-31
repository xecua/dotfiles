#!/usr/bin/env python3
"""
manage_id3.py — Read, template, and write ID3v2.4 (UTF-8) tags for mp3 files.

Subcommands:
  inspect  <dir>                 Dump current tags for every .mp3 in a directory (sorted by filename).
  template <dir> [-o manifest.json]
                                  Generate a manifest.json scaffold, one entry per .mp3 file in the
                                  directory (sorted by filename), with empty fields to fill in.
  apply    <manifest.json>       Write tags (and optional artwork) described in the manifest to disk.
  verify   <manifest.json>       Re-read the files listed in the manifest and print their tags so the
                                  result can be checked against what was intended.

Manifest format (JSON):
{
  "directory": "/path/to/album/folder",   // all "file" entries below are relative to this
  "album": "Album Title",
  "album_artist": "Album Artist",
  "genre": "Genre",
  "year": "2024",
  "artwork": "/path/to/cover.jpg",        // optional; embedded into every track if present
  "tracks": [
    {"file": "01 Track One.mp3", "title": "Track One", "artist": "Artist", "track_number": "1"},
    {"file": "02 Track Two.mp3", "title": "Track Two", "artist": "Artist", "track_number": "2"}
  ]
}

Only "file" is required per track; any of title/artist/track_number/genre/year/album/album_artist
can also be set per-track to override the album-level default for that one file.
"""
import argparse
import json
import os
import sys

from mutagen.id3 import (
    ID3,
    ID3NoHeaderError,
    TIT2,  # title
    TPE1,  # artist
    TPE2,  # album artist
    TALB,  # album
    TRCK,  # track number
    TCON,  # genre
    TDRC,  # year / recording date (ID3v2.4)
    APIC,  # embedded artwork
)

UTF8 = 3  # mutagen text-encoding constant for UTF-8


def load_or_new_id3(path):
    try:
        return ID3(path)
    except ID3NoHeaderError:
        return ID3()


def dump_tags(path):
    try:
        tags = ID3(path)
    except ID3NoHeaderError:
        return {"file": os.path.basename(path), "tags": None, "note": "no ID3 tag present"}
    out = {"file": os.path.basename(path)}
    frame_map = {
        "title": "TIT2",
        "artist": "TPE1",
        "album_artist": "TPE2",
        "album": "TALB",
        "track_number": "TRCK",
        "genre": "TCON",
        "year": "TDRC",
    }
    for label, frame_id in frame_map.items():
        frame = tags.get(frame_id)
        out[label] = str(frame.text[0]) if frame and frame.text else None
    apics = tags.getall("APIC")
    out["artwork"] = f"{len(apics)} image(s), {apics[0].mime}" if apics else None
    return out


def cmd_inspect(args):
    mp3_files = sorted(f for f in os.listdir(args.directory) if f.lower().endswith(".mp3"))
    if not mp3_files:
        print(f"No .mp3 files found in {args.directory}", file=sys.stderr)
        sys.exit(1)
    results = [dump_tags(os.path.join(args.directory, f)) for f in mp3_files]
    print(json.dumps(results, ensure_ascii=False, indent=2))


def cmd_template(args):
    mp3_files = sorted(f for f in os.listdir(args.directory) if f.lower().endswith(".mp3"))
    if not mp3_files:
        print(f"No .mp3 files found in {args.directory}", file=sys.stderr)
        sys.exit(1)
    manifest = {
        "directory": os.path.abspath(args.directory),
        "album": "",
        "album_artist": "",
        "genre": "",
        "year": "",
        "artwork": "",
        "tracks": [
            {"file": f, "title": "", "artist": "", "track_number": str(i + 1)}
            for i, f in enumerate(mp3_files)
        ],
    }
    out_path = args.output or os.path.join(args.directory, "manifest.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)
    print(f"Wrote scaffold for {len(mp3_files)} file(s) to {out_path}")


def resolve_field(track, manifest, key):
    """Per-track value wins; otherwise fall back to the album-level default."""
    val = track.get(key)
    if val not in (None, ""):
        return val
    return manifest.get(key) or None


def apply_track(path, track, manifest, artwork_bytes, artwork_mime):
    tags = load_or_new_id3(path)

    def set_text(frame_cls, frame_id, key):
        value = resolve_field(track, manifest, key)
        if value is None:
            return
        tags.setall(frame_id, [frame_cls(encoding=UTF8, text=[str(value)])])

    set_text(TIT2, "TIT2", "title")
    set_text(TPE1, "TPE1", "artist")
    set_text(TPE2, "TPE2", "album_artist")
    set_text(TALB, "TALB", "album")
    set_text(TCON, "TCON", "genre")
    set_text(TDRC, "TDRC", "year")

    track_number = resolve_field(track, manifest, "track_number")
    if track_number is not None:
        total = manifest.get("track_total")
        text = f"{track_number}/{total}" if total else str(track_number)
        tags.setall("TRCK", [TRCK(encoding=UTF8, text=[text])])

    if artwork_bytes is not None:
        tags.delall("APIC")
        tags.add(
            APIC(
                encoding=UTF8,
                mime=artwork_mime,
                type=3,  # front cover
                desc="Cover",
                data=artwork_bytes,
            )
        )

    tags.save(path, v2_version=4)  # ID3v2.4, UTF-8-capable


def load_artwork(manifest):
    artwork_path = manifest.get("artwork")
    if not artwork_path:
        return None, None
    if not os.path.isfile(artwork_path):
        print(f"WARNING: artwork file not found, skipping: {artwork_path}", file=sys.stderr)
        return None, None
    ext = os.path.splitext(artwork_path)[1].lower()
    mime = "image/png" if ext == ".png" else "image/jpeg"
    with open(artwork_path, "rb") as fh:
        return fh.read(), mime


def cmd_apply(args):
    with open(args.manifest, "r", encoding="utf-8") as fh:
        manifest = json.load(fh)

    directory = manifest.get("directory", os.path.dirname(os.path.abspath(args.manifest)))
    tracks = manifest.get("tracks", [])
    if not tracks:
        print("Manifest has no tracks listed.", file=sys.stderr)
        sys.exit(1)

    artwork_bytes, artwork_mime = load_artwork(manifest)

    errors = []
    for track in tracks:
        path = os.path.join(directory, track["file"])
        if not os.path.isfile(path):
            errors.append(f"missing file: {path}")
            continue
        try:
            apply_track(path, track, manifest, artwork_bytes, artwork_mime)
            print(f"OK: {track['file']}")
        except Exception as exc:  # noqa: BLE001
            errors.append(f"{track['file']}: {exc}")

    if errors:
        print("\nCompleted with errors:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)
    print(f"\nDone. {len(tracks)} file(s) tagged (ID3v2.4, UTF-8).")


def cmd_verify(args):
    with open(args.manifest, "r", encoding="utf-8") as fh:
        manifest = json.load(fh)
    directory = manifest.get("directory", os.path.dirname(os.path.abspath(args.manifest)))
    results = [
        dump_tags(os.path.join(directory, t["file"]))
        for t in manifest.get("tracks", [])
        if os.path.isfile(os.path.join(directory, t["file"]))
    ]
    print(json.dumps(results, ensure_ascii=False, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    p_inspect = sub.add_parser("inspect", help="Dump current tags for all mp3s in a directory")
    p_inspect.add_argument("directory")
    p_inspect.set_defaults(func=cmd_inspect)

    p_template = sub.add_parser("template", help="Generate a manifest.json scaffold from a directory of mp3s")
    p_template.add_argument("directory")
    p_template.add_argument("-o", "--output", help="Output path (default: <directory>/manifest.json)")
    p_template.set_defaults(func=cmd_template)

    p_apply = sub.add_parser("apply", help="Apply a manifest.json to its mp3 files")
    p_apply.add_argument("manifest")
    p_apply.set_defaults(func=cmd_apply)

    p_verify = sub.add_parser("verify", help="Re-read tags for files listed in a manifest")
    p_verify.add_argument("manifest")
    p_verify.set_defaults(func=cmd_verify)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
