# youtube-download

A [Claude Code](https://claude.com/claude-code) skill: paste a YouTube link and Claude downloads it as an mp4 (H.264 + AAC) to `~/Downloads`.

## Install

```bash
git clone https://github.com/davidklett/youtube-download-skill.git ~/.claude/skills/youtube-download
```

Requires `python3`, `ffmpeg`, and `node` or `deno` (YouTube needs a JS runtime to solve challenges).

## How it works

`scripts/download.sh` keeps its own yt-dlp in a venv at `~/.local/share/youtube-download/venv`, upgrading it every 3 days. Stale yt-dlp versions fail mid-download with `HTTP Error 403: Forbidden`.

Use it without Claude:

```bash
bash scripts/download.sh "https://www.youtube.com/watch?v=..." [output_dir]
```
