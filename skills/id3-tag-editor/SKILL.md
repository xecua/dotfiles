---
name: id3-tag-editor
description: Collect album/track metadata (title, artist, album, album artist, genre, year, track number, cover artwork) from multiple sources — filename/folder inference, online lookup (e.g. MusicBrainz), and asking the user — then batch-write it into ID3v2.4/UTF-8 tags across a whole album folder of mp3 files. Use this whenever the user wants to tag, retag, fix, organize, or fill in metadata for mp3 files, an album folder, or a music library, or mentions ID3 tags, missing/wrong track info, or embedding cover art into mp3s. Always use this skill instead of writing ad hoc tag-editing code from scratch.
---

# ID3 Tag Editor

Collects ID3 metadata for an album of mp3 files from several sources, reconciles it into a single
manifest, and batch-writes ID3v2.4 (UTF-8) tags — including embedded cover art — with a verification
pass at the end.

## Workflow

Work album-by-album (one folder of mp3 files = one album). For each album:

### 1. Set up
Use a virtual environment rather than installing into the system Python:
```bash
python3 -m venv .venv                 # once per project/session, if not already created
.venv/bin/pip install -q mutagen
```
Then run the script through that interpreter, e.g. `.venv/bin/python3 scripts/manage_id3.py ...`
(all example commands below assume this; substitute `.venv/bin/python3` for `python3`, or activate
the venv first with `source .venv/bin/activate`).

### 2. Inspect what's already there
```bash
.venv/bin/python3 scripts/manage_id3.py inspect "<album directory>"
```
This dumps existing tags per file as JSON. Use it to see what's already correct and what's missing —
don't ask the user for things that are already tagged correctly, and don't silently overwrite tags
the user didn't ask to change unless they're clearly wrong (e.g. mismatched with the actual track).

### 3. Collect metadata (combine sources — this is the core of the skill)
Gather album title, album artist, genre, year, and per-track title/artist/track number using
**whichever combination of sources fits the situation**, roughly in this order of reliability:

1. **User-provided ground truth first.** If the user already told you the album/artist/tracklist in
   the conversation, or uploaded something with it, use that directly — don't re-derive it.
2. **Filename/folder inference.** Parse patterns like `01 - Track Name.mp3`, `01. Track Name.mp3`,
   or a bare `Track Name.mp3` with track order taken from filename sort order. The parent folder
   name is often `Artist - Album` or just `Album`; the grandparent folder is often the artist. Treat
   this as a first draft, not ground truth — filenames are frequently abbreviated, mis-romanized, or
   missing diacritics/kanji.
3. **Online lookup to fill gaps and correct the draft.** Use `web_search` (and `web_fetch` on the
   most likely result, e.g. a MusicBrainz release page) with the artist + album name to find the
   canonical tracklist, release year, genre, and album artist. Cross-check the track count and order
   against what's actually in the folder before trusting it — a search result for the wrong edition
   (different region/reissue) will have a different tracklist. For cover art, do the same via
   `image_search`, but only use it if the user hasn't already supplied artwork — see step 4.
   Note: search/fetch tools operate outside this skill's own scripts; don't try to curl these from
   bash_tool since the sandboxed network doesn't reach music databases.
4. **Ask the user to confirm and fill remaining gaps.** After steps 2–3, present the *draft* tag set
   (a short table or list is fine) and ask the user to confirm it or correct specific fields — rather
   than asking them to dictate everything from scratch. Use `ask_user_input_v0` for genuinely
   ambiguous single choices (e.g. which of two similarly-named releases), and plain conversation for
   open-ended corrections (spellings, kanji, feat. credits).

Never fabricate a plausible-sounding tracklist, year, or genre and present it as fact — every field
in the final manifest should trace back to one of: the user, the filenames, or a fetched source. If a
field genuinely can't be determined from any source, leave it blank and flag it to the user rather
than guessing.

### 4. Handle artwork
- If the user has a local cover image, use its path directly as `"artwork"` in the manifest.
- If not, and the user wants artwork embedded, `image_search` for the official album cover, then
  download it into the working directory (e.g. via `web_fetch` on the image URL, or ask the user to
  upload the image) before referencing its local path in the manifest — the script embeds from a
  local file, not a URL.
- Supported formats: JPEG and PNG (anything else, convert first).

### 5. Build the manifest
Generate a scaffold, then fill it in with everything gathered in steps 3–4 (either by editing the
JSON directly or writing it out programmatically):
```bash
.venv/bin/python3 scripts/manage_id3.py template "<album directory>" -o manifest.json
```
Manifest shape — album-level fields are defaults; any field can be overridden per-track by setting
the same key inside a track entry (e.g. a compilation where each track has a different artist):
```json
{
  "directory": "/absolute/path/to/album",
  "album": "Album Title",
  "album_artist": "Album Artist",
  "genre": "Genre",
  "year": "2024",
  "track_total": "12",
  "artwork": "/absolute/path/to/cover.jpg",
  "tracks": [
    {"file": "01 Track One.mp3", "title": "Track One", "artist": "Artist", "track_number": "1"}
  ]
}
```
`"file"` must match the actual filename in `directory` exactly (case-sensitive on Linux).

### 6. Apply
```bash
.venv/bin/python3 scripts/manage_id3.py apply manifest.json
```
Writes ID3v2.4 tags with UTF-8 text encoding (correct choice for Japanese/CJK and other non-Latin
text; this is a fixed behavior of the script, not user-configurable per run) to every file listed,
embedding the artwork image into each one if `"artwork"` is set. Reports per-file success/failure.

### 7. Verify
```bash
.venv/bin/python3 scripts/manage_id3.py verify manifest.json
```
Re-reads the tags straight back off disk and prints them. Compare against the manifest and show the
result to the user as confirmation — don't just report "done" without this check, since a silent
mismatch (wrong file mapped to wrong track, encoding issue, etc.) is exactly the kind of error this
step catches.

## Notes
- The script only ever touches ID3v2.4/UTF-8 — this was chosen for modern player/OS compatibility
  and correct CJK text handling. If a user specifically needs ID3v2.3 (e.g. for an old car stereo or
  hardware DAP with weak v2.4 support), don't use this script's `apply` command as-is; say so and
  either adjust the `v2_version`/encoding in a copy of `scripts/manage_id3.py` or advise accordingly.
- `inspect` and `verify` never modify files — safe to run anytime.
- For very large libraries (many albums), loop the whole workflow per album folder rather than trying
  to build one giant manifest across albums — keeps each apply/verify pass easy to check.
