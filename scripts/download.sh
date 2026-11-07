#!/usr/bin/env bash
# Download a YouTube (or any yt-dlp-supported) URL as an H.264/AAC mp4.
# Usage: bash download.sh <url> [output_dir]   (output_dir defaults to ~/Downloads)
# Prints the final file path on the last line as: FILE=<path>
set -euo pipefail

URL="${1:?usage: download.sh <url> [output_dir]}"
OUT_DIR="${2:-$HOME/Downloads}"
VENV="$HOME/.local/share/youtube-download/venv"
STAMP="$VENV/.last-upgrade"

# Own venv: the system/anaconda yt-dlp is root-owned and goes stale, and stale
# yt-dlp fails mid-download with "HTTP Error 403: Forbidden".
if [ ! -x "$VENV/bin/yt-dlp" ]; then
  echo "Creating venv at $VENV ..." >&2
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install -q -U pip "yt-dlp[default]" >&2
  touch "$STAMP"
elif [ -z "$(find "$STAMP" -mtime -3 2>/dev/null)" ]; then
  echo "Upgrading yt-dlp (older than 3 days) ..." >&2
  "$VENV/bin/pip" install -q -U "yt-dlp[default]" >&2 && touch "$STAMP"
fi

command -v ffmpeg >/dev/null || { echo "ffmpeg missing: brew install ffmpeg" >&2; exit 1; }

# YouTube needs a JS runtime to solve challenges; prefer deno, fall back to node.
JS_ARGS=()
if command -v deno >/dev/null; then JS_ARGS=(--js-runtimes deno)
elif command -v node >/dev/null; then JS_ARGS=(--js-runtimes node)
else echo "WARNING: no deno/node found; some formats may be missing" >&2; fi

mkdir -p "$OUT_DIR"
"$VENV/bin/yt-dlp" "${JS_ARGS[@]}" \
  -f "bv*[ext=mp4][vcodec^=avc1]+ba[ext=m4a]/bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/bv*+ba/b" \
  --merge-output-format mp4 \
  --no-playlist --no-update --no-progress \
  -P "$OUT_DIR" -o "%(title)s.%(ext)s" \
  --print after_move:"FILE=%(filepath)s" \
  "$URL"
