---
name: credits
description: Show how many Google Flow credits the user has, when they refill, and what that buys right now — how many images and videos per model — by reading the live balance and live prices in Flow without generating anything. Use when the user runs /google-flow:credits or asks how many credits they have, how many images/videos they can make, what a model costs, or when credits refresh.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/skills/generate/scripts/collect.sh *)
---

# What can I make? 🎟️

Read the user's Flow credit balance and the live price of each model, then show a friendly "menu" of what they can make right now. **Nothing is generated and no credits are spent.**

The Flow UI map is `${CLAUDE_PLUGIN_ROOT}/skills/generate/reference/ui-map.md` — read its *Settings popover* and *Credit balance* sections first.

## Voice

Same cheerful film-crew voice as `generate`: short, upbeat, a couple of emoji. The numbers themselves are always exact.

## Steps

1. **Tools.** Load in ONE ToolSearch call:
   `select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__find,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__browser_batch,mcp__claude-in-chrome__tabs_close_mcp`
   `tabs_context_mcp` → `tabs_create_mcp`. Not connected → point them to `/google-flow:setup` and stop.

2. **Balance.** Navigate to `https://flow.google.com/`. Click **Account details** (avatar, top right), read **"N Google Flow credits"** and **"Credits refresh daily at HH:MM"**, close the panel. Don't click anything else in it.

3. **Prices.** Open any project (most recent, or **New project** if they have none) so the composer shows. Agent chip off. Open **Settings trigger** and note the current settings so you can restore them. Then, without generating, read the "Generating will use N credits" line at **x1** for:
   - Image: each model in the dropdown
   - Video: each model in the dropdown at its default options; for models with resolution/duration rows (e.g. Omni Flash), read the cheapest and the default combination
   Prices scale linearly with x2–x4, so x1 is enough. Use `browser_batch` (select → zoom on the footer) to keep this quick.
   Restore the settings you noted, press Escape, close the tab.

4. **Show the menu.** Example shape:

   ```
   🎟️ You have 40 Flow credits · refills daily at 21:01

   🍌 Images: free on your plan
      Nano Banana 2.1 · Nano Banana 2 Lite · Nano Banana Pro: 0 credits, up to 4 per prompt

   🎬 Videos (one 8 s clip each)
      Omni 1.1 Flash 360p   6 cr   → 6 clips
      Veo 3.1 Lite         10 cr   → 4 clips
      Omni 1.1 Flash 720p  12 cr   → 3 clips
      Veo 3.1 Fast         20 cr   → 2 clips
      Veo 3.1 Quality     100 cr   → not yet (60 short)
   ```
   - "→ N clips" = floor(balance ÷ price). Sort videos cheapest first.
   - Mention that each prompt can make x1–x4 at once (x2 costs double), and that the plugin asks before spending and does at most 8 generations per request unless they say more.
   - If images show 0 credits, say they're free *as far as Flow shows* — Google may still apply limits it doesn't display.
   - End with one fun suggestion that fits their balance (e.g. "Enough for 4 Veo Lite clips — want to animate the robot from setup?").
