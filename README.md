# 🎬 Google Flow for Claude Code

**Tell Claude what to make. It goes to [Google Flow](https://flow.google.com), makes it, and drops the files on your computer.**

```
/google-flow:generate image "a corgi astronaut floating past Saturn, cinematic" --count 2
```

…and a minute later:

```
✨ Fresh out of the oven:
   flow-output/a-corgi-astronaut-floating-past-saturn-20261027-214059-1.jpg
   flow-output/a-corgi-astronaut-floating-past-saturn-20261027-214059-2.jpg
```

Images with Nano Banana, videos with Veo, reference images, start and end frames: Claude clicks through all of it in **your own signed-in browser** using [Claude in Chrome](https://claude.ai/chrome). You don't need API keys or to copy and paste anything.

---

## 🚀 Install it the lazy way

Open Claude Code and paste this:

```
Install the Google Flow plugin from https://github.com/Jayith/claude-google-flow and set it up for me
```

Claude installs it and walks you through a two-minute setup. That's the whole install.

<details>
<summary>Prefer typing commands yourself?</summary>

In Claude Code:

```
/plugin marketplace add Jayith/claude-google-flow
/plugin install google-flow@claude-google-flow
/reload-plugins
/google-flow:setup
```

or in a terminal (then start Claude Code and run `/google-flow:setup`):

```bash
claude plugin marketplace add Jayith/claude-google-flow
claude plugin install google-flow@claude-google-flow
```
</details>

## 🧰 What you need

- **[Claude Code](https://claude.com/claude-code)**
- **A Chrome-based browser** (Chrome, Brave, Edge, Arc, Vivaldi) with the **[Claude in Chrome](https://claude.ai/chrome)** extension, signed in to the same Claude account
- **A Google account that can use [Flow](https://flow.google.com)**
- macOS, Windows or Linux *(tested on macOS. Windows and Linux should work, and if you try them, please tell us how it goes!)*

## 🪄 First-time setup

Run `/google-flow:setup`, or just ask for your first image and Claude starts setup automatically. It checks four things and only asks you to click where it can't:

| | Check | What you might need to do |
|---|---|---|
| 1 | 🔌 Claude in Chrome is connected | Install the extension and sign in |
| 2 | 🔑 You're signed in to Flow | Sign in to Google in the tab Claude opens |
| 3 | 📁 Your browser has a working download folder | Pick a folder in the browser's download settings |
| 4 | 🙅 Flow's "wants to save" pop-up is turned off | Add `https://flow.google.com` under **Not allowed to edit files** (Claude gives you the link) |

Then it does a **free test run**, a tiny robot waving hello 🤖👋, to prove everything works from start to finish.

<details>
<summary>Why step 4?</summary>

Flow saves files through a "flow.google.com wants to save" system window. Claude can only click inside web pages, not system windows, so without this step you'd have to click **Save** on every download yourself. Blocking "file editing" for Flow (and only Flow) makes it fall back to a normal download that lands straight in your Downloads folder.
</details>

## 🎨 Make stuff

```
/google-flow:generate <image|video> "<prompt>" [options]
```

| Option | Default | What it does |
|---|---|---|
| `image` / `video` | `image` | What to make |
| `--ref <file>` | — | Reference images (image) or ingredients (video). Repeatable |
| `--start <file>` / `--end <file>` | — | First and last frame of a video |
| `--model <name>` | Flow's default | `pro`, `lite`, `fast`, `quality`… whatever Flow offers |
| `--aspect` | `16:9` | Images: 16:9, 4:3, 1:1, 3:4, 9:16. Videos: 16:9, 9:16 |
| `--count` | `1` | 1–4 at once |
| `--out <folder>` | `./flow-output` | Where your files land |
| `--project <title>` | new project | Keep working in an existing Flow project |

Or just talk to it:

> *"Make a 9:16 Veo clip of a paper boat sailing down a rainy street"*
>
> *"Use cat.png as a reference and give me 3 versions of it as a Renaissance painting"*
>
> *"Animate the last image you made, slow zoom out"*

### 💳 Credits stay in your hands

- Before generating, Claude reads Flow's **"Generating will use N credits"** line. If it costs anything, **Claude asks you first.**
- At most 8 generations per request unless you say more.
- It never touches billing, upgrades, sharing or publishing, and it stops at sign-in pages and CAPTCHAs.

## 🔧 Troubleshooting

| Uh-oh | Fix |
|---|---|
| A "flow.google.com wants to save" window pops up | Click **Cancel** and run `/google-flow:setup` (step 4 fixes it) |
| "Browser extension is not connected" | Open your browser, check Claude in Chrome is on and signed in, restart the browser |
| `download folder does not exist` | Run `/google-flow:setup`, or set `FLOW_DOWNLOADS=/path/to/folder` |
| It picked the wrong browser profile | Set `FLOW_BROWSER_PROFILE` to the profile folder that contains `Preferences` |
| Claude can't find a button | Flow probably redesigned something. Claude will try to adapt; [open an issue](https://github.com/Jayith/claude-google-flow/issues) with what moved |

## 🤖 Notes for Claude

If a user gives you this repository and asks you to install it, do this:

1. Run in Bash:
   ```bash
   claude plugin marketplace add Jayith/claude-google-flow
   claude plugin install google-flow@claude-google-flow
   ```
2. Ask the user to run `/reload-plugins` (or restart Claude Code) so the new skills load.
3. Then run the `google-flow:setup` skill (the user can also type `/google-flow:setup`).

Don't change the user's browser settings yourself. Setup tells them what to click.

## 🧠 How it works

The plugin is two [skills](plugins/google-flow/skills) (`setup` and `generate`): instructions Claude follows using the Claude in Chrome tools. It also has a few helpers:

- [`ui-map.md`](plugins/google-flow/skills/generate/reference/ui-map.md): a field guide to every button in Flow, checked against the live site
- [`page-hooks.js`](plugins/google-flow/skills/generate/reference/page-hooks.js): lets Claude attach your local files without a system file picker
- [`collect.sh`](plugins/google-flow/skills/generate/scripts/collect.sh): finds your browser's download folder and moves new results into `--out` with names based on the prompt

## ⚠️ The fine print

This is an **unofficial** fan project, not affiliated with or endorsed by Google or Anthropic. It drives Flow's website the way you would, so a Flow redesign can break it until it's updated. Automated use may be limited by Google's terms, and you're responsible for how you use it on your account. Generations spend your Flow credits.

## License

[MIT](LICENSE). Have fun, make weird stuff. ✨
