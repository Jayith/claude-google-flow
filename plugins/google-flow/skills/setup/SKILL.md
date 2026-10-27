---
name: setup
description: Friendly first-time setup for the Google Flow plugin — checks the Claude in Chrome connection, Flow sign-in, the browser's download folder and save-dialog setting, then does a free test generation to prove everything works. Use when the user runs /google-flow:setup, just installed the plugin, asks how to set up / fix the Flow plugin, or when /google-flow:generate reports that setup is needed.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/skills/generate/scripts/collect.sh *)
---

# Google Flow — first-time setup 🎬

Walk the user through getting the plugin ready, one check at a time. This is their first impression of the plugin, so make it feel easy and a little fun.

`collect.sh` below means `${CLAUDE_PLUGIN_ROOT}/skills/generate/scripts/collect.sh`. Setup state lives in `${CLAUDE_PLUGIN_DATA}`. The Flow UI map is `${CLAUDE_PLUGIN_ROOT}/skills/generate/reference/ui-map.md` and the page script is `${CLAUDE_PLUGIN_ROOT}/skills/generate/reference/page-hooks.js`.

## Voice

- Warm, upbeat, brief. Talk like a friendly studio assistant getting the set ready ("lights… camera… let's check your browser").
- One check per message. Mark progress like `✅ 1/4 Browser connected`. A few emoji at milestones are welcome; don't decorate every line.
- When something needs the user, give them **exactly** what to click or type, then wait for them to say they're done. Never make them feel they did something wrong.
- Stay plain and precise about anything involving their account, settings, or credits.
- You do the checking; the user only does the steps you can't (installing an extension, signing in, changing a browser setting). Never change browser settings yourself.

## Steps

**0. Hello.** One short message: what's about to happen (4 quick checks + a free test image, ~2 minutes) and that they'll only need to click a couple of things.

**1. Browser connection.** Load the Claude in Chrome tools in ONE ToolSearch call:
`select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__find,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__browser_batch,mcp__claude-in-chrome__tabs_close_mcp`
Call `tabs_context_mcp` with `createIfEmpty: true`.
- Not connected (or the tools don't exist) → explain: install **Claude in Chrome** from https://claude.ai/chrome in a Chrome-based browser (Chrome, Brave, Edge, Arc…), sign in to the **same Claude account** as Claude Code, then fully restart the browser. Wait, then retry.

**2. Flow sign-in.** `tabs_create_mcp`, navigate to `https://flow.google.com/`, wait 3 s, screenshot.
- Project grid / **New project** button → signed in ✅.
- Google sign-in page or a welcome/terms screen → ask them to finish it in that tab (you don't type credentials or accept terms for them), then re-check.
- "Not available in your country" or similar → explain Flow isn't available for that account/region and stop kindly.

**3. Download folder.** Run `collect.sh mark`.
- Exit 3 → their browser saves to a folder that no longer exists. Get the scheme from `collect.sh browser` and send them to `<scheme>settings/downloads` to pick a real folder (e.g. Downloads). Re-run.
- Output warns the browser "asks where to save" → same page: turn off **Ask where to save each file**. Re-run.
- Otherwise ✅, and mention the folder.

**4. The save-dialog trick.** Flow normally pops a "flow.google.com wants to save" system window that you can't click, so you'd be stuck waiting on them every download. Get the scheme from `collect.sh browser` and ask them to:
1. open `<scheme>settings/content/fileSystemWrite` (Edge: search settings for **File editing** if the link doesn't open)
2. next to **Not allowed to edit files**, click **Add**, enter `https://flow.google.com`, click **Add**
3. tell you when done.
Then reload the Flow tab (navigate to `https://flow.google.com/` again) — the setting only applies after a reload.

**5. Test drive ✨** Follow the generate skill's workflow (`${CLAUDE_PLUGIN_ROOT}/skills/generate/SKILL.md`, steps 3–9) with:
- New project, Image, the default model, 1:1, x1, prompt: `a tiny cheerful robot waving hello, soft pastel studio backdrop, product photo`, out dir `./flow-output`.
- Read the credits line. If it isn't 0, tell them the cost and ask before generating (they can also skip the test).
- After clicking **Original size**, run `collect.sh collect ./flow-output "hello robot"`.
  - File arrives → 🎉 show the path.
  - Exit 4 → ask whether a save window popped up. If yes: have them click **Cancel**, double-check step 4 (exact address `https://flow.google.com`, then reload), and try the download once more. If no window and still nothing: report the script output and stop.

**6. Done.** Run `collect.sh setup-done "${CLAUDE_PLUGIN_DATA}"`. Celebrate briefly and show 2–3 starter commands:
```
/google-flow:generate image "a cozy reading nook, rainy window, warm lamp light" --count 2
/google-flow:generate video "slow push-in on a steaming cup of coffee" --aspect 9:16
/google-flow:generate video "the robot starts dancing" --start ./flow-output/<their test image>
```
Then show their credit menu: follow the `google-flow:credits` skill's steps 2–4 (reusing the open tab — do this before closing it) so they know exactly how many images and videos they can make. Remind them: Claude always asks before spending credits, and `/google-flow:credits` shows the menu again anytime.

Close the tab when you're finished.

If they want to stop partway, that's fine — don't mark setup done; tell them `/google-flow:setup` picks up from the top anytime.
