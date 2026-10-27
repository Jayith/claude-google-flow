# Google Flow for Claude Code

A Claude Code plugin that generates images and videos in [Google Flow](https://flow.google.com) for you. Claude opens Flow in **your own signed-in browser** through [Claude in Chrome](https://claude.ai/chrome), picks the model and settings, attaches reference images, types the prompt, waits for the result, and saves the files to a folder on your machine.

```
/google-flow:generate image "matte black bottle on travertine, studio light" --aspect 1:1 --count 2
/google-flow:generate video "slow push-in, steam rising from the cup" --start ./frame.png --aspect 9:16
```

> **Unofficial.** Not affiliated with or endorsed by Google or Anthropic. It automates Flow's web UI, which Google can change at any time, and automated use may be restricted by Google's terms. You are responsible for how you use it on your account. Generations spend your Flow credits.

## Requirements

- [Claude Code](https://claude.com/claude-code) (CLI, desktop, or IDE)
- A Chrome-based browser (Chrome, Brave, Edge, Arc, Vivaldi) with the **Claude in Chrome** extension, connected to Claude Code and signed in to the same Claude account
- A Google account with access to Flow, signed in in that browser
- macOS, Windows, or Linux. Downloads are collected by a bash script (Windows: the Git Bash that Claude Code already uses). Tested on macOS; Windows and Linux are untested — reports welcome.

## Install

In Claude Code:

```
/plugin marketplace add Jayith/claude-google-flow
/plugin install google-flow@claude-google-flow
```

or from a terminal:

```bash
claude plugin marketplace add Jayith/claude-google-flow
claude plugin install google-flow@claude-google-flow
```

## Setup (one time)

1. **Stop the save dialog.** Flow saves files through a "flow.google.com wants to save" system dialog that Claude can't click. Block that for Flow only, so it falls back to a normal download:
   - open `chrome://settings/content/fileSystemWrite` (Brave: `brave://settings/content/fileSystemWrite`, Edge: `edge://settings/content/fileEditing`)
   - under **Not allowed to edit files**, click **Add** and enter `https://flow.google.com`
2. **Check your download folder.** In the browser's download settings, make sure downloads go to a folder that exists and that **"Ask where to save each file"** is off.
3. Open [flow.google.com](https://flow.google.com) once in that browser and make sure you're signed in.

## Usage

```
/google-flow:generate <image|video> "<prompt>" [options]
```

| Option | Default | Notes |
|---|---|---|
| `image` / `video` | `image` | |
| `--ref <path>` | — | Repeatable. Reference images (image) or ingredients (video) |
| `--start <path>` / `--end <path>` | — | Video start/end frames (Frames mode) |
| `--model <name>` | Flow's default | Loose match: `pro`, `lite`, `fast`, `quality`, … |
| `--aspect` | `16:9` | Images: 16:9, 4:3, 1:1, 3:4, 9:16. Video: 16:9, 9:16 |
| `--count` | `1` | 1–4 outputs |
| `--out <dir>` | `./flow-output` | Where files are saved |
| `--project <title>` | new project | Reuse an existing Flow project |

You can also just ask: *"make a 9:16 Veo clip of a paper boat in the rain with Flow"*.

### Credits and safety

- Claude reads Flow's **"Generating will use N credits"** line and asks before spending any credits (free generations run without asking).
- At most 8 generations per request without asking again.
- It never touches billing, upgrade, sharing, or publish controls, and stops at sign-in pages and CAPTCHAs.

## How it works

The plugin is a single [skill](plugins/google-flow/skills/generate/SKILL.md) — instructions Claude follows using the Claude in Chrome tools — plus two helpers:

- [`reference/ui-map.md`](plugins/google-flow/skills/generate/reference/ui-map.md): where every control in Flow lives, verified against the live site
- [`reference/page-hooks.js`](plugins/google-flow/skills/generate/reference/page-hooks.js): lets Claude attach local files without a native file picker
- [`scripts/collect.sh`](plugins/google-flow/skills/generate/scripts/collect.sh): finds your browser's download folder and moves new results into `--out` with names based on the prompt

## Troubleshooting

| Symptom | Fix |
|---|---|
| "flow.google.com wants to save" dialog appears | Do Setup step 1, then reload Flow |
| `download folder does not exist` | Set a valid download folder in the browser, or run with `FLOW_DOWNLOADS=/path/to/folder` |
| Wrong browser profile detected | Set `FLOW_BROWSER_PROFILE` to the profile folder (the one containing `Preferences`) |
| "Browser extension is not connected" | Open the browser, enable Claude in Chrome, sign in to the same Claude account, restart the browser |
| Claude can't find a button | Flow's UI changed. Claude will try to adapt; please open an issue with what moved |

## License

[MIT](LICENSE)
