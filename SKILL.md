---
name: youtube-download
description: Use when the user gives a YouTube link (youtube.com/watch, youtu.be, shorts) or any video URL and wants it downloaded, saved, or converted to mp4 — including a bare link with no other instructions. Also when yt-dlp fails with "HTTP Error 403 Forbidden" or "No supported JavaScript runtime".
---

# YouTube Download (mp4)

## Overview
A bare YouTube link from the user means: download it as an mp4 to `~/Downloads`. Use the bundled script; don't run the system `yt-dlp` (it's root-owned under anaconda, goes stale, and 403s mid-download).

## Steps
1. Run, with a 10-minute timeout (long videos are several hundred MB):
   ```bash
   bash ~/.claude/skills/youtube-download/scripts/download.sh "<url>" [output_dir]
   ```
   Pass the URL unchanged — `&t=5s` timestamps and `&list=` params are fine (`--no-playlist` is set). Output dir defaults to `~/Downloads`; use another only if the user names one.
2. Take the path from the `FILE=` line and verify:
   ```bash
   ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height -of compact "<path>"
   ```
3. Report: full path, resolution, duration, size.

## What the script handles
- Private venv at `~/.local/share/youtube-download/venv`, auto-upgrades yt-dlp every 3 days
- Passes `--js-runtimes deno|node` (YouTube requires a JS runtime)
- Prefers H.264 + AAC so the mp4 plays in QuickTime; merges with ffmpeg

## Common Mistakes
| Symptom | Fix |
|---|---|
| `HTTP Error 403` again | Force upgrade: `~/.local/share/youtube-download/venv/bin/pip install -U "yt-dlp[default]"`, retry |
| "Sign in to confirm you're not a bot" / age-restricted | Add `--cookies-from-browser chrome` (edit script call or run venv yt-dlp directly); ask user first |
| User wants audio only | Run venv yt-dlp with `-x --audio-format mp3` instead of the script |
| Partial `.part` / `.f299.mp4` files left | Delete them before retrying |
