# Flow UI map

Last verified: **2026-10-27** (Chromium browser + Claude in Chrome, viewport ~1053–1471 px wide). Coordinates are only hints — prefer `find` by label.

URL: `https://labs.google/fx/tools/flow` → redirects to `https://flow.google.com/`. Project URLs: `https://flow.google.com/project/<uuid>`.

## Home
- Promo carousel at top, project grid below (cards show date titles like "Oct 27 - 18:31").
- **"New project"** floating button over the grid → creates a project and opens it.

## Project view
- Left nav: All media, Images, Characters, Scenes, Uploads, Library, Tools, Bin.
- New projects open with an **Agent chat panel** on the right ("Untitled session"). Ignore it — use direct mode (below). Close it with its ✕ if it's open.
- Composer docked at the bottom: textbox **"What do you want to create?"**, then:
  - `+` **"Add ingredients to the prompt box"** (image refs / ingredients)
  - **"Agent"** toggle chip — click to turn agent mode **off**. Off = direct generation and the settings chip appears. (When Agent is on, the chip is replaced by "Agent instructions" + "Settings" icons that open *Agent settings* — not what we want.)
  - **"Settings trigger"** chip — shows current config, e.g. `🍌 Nano Banana 2.1 ▭ x1` or `Video · 720p · 8s ▭ x1`
  - **"Start generation"** (→ arrow, type=submit)

## Settings popover (click "Settings trigger")
- Tabs: **Image** | **Video**
- Image: aspect `16:9 4:3 1:1 3:4 9:16`; model dropdown (**Nano Banana 2.1**, Nano Banana 2 Lite, Nano Banana Pro); count `x1–x4`.
- Video: sub-mode **Frames** | **Ingredients**; aspect `16:9 9:16`; model dropdown (**Veo 3.1 - Lite**, Veo 3.1 - Fast, Veo 3.1 - Quality, Omni 1.1 Flash); count `x1–x4`. Chip shows `Video · 720p · 8s`.
- Video › **Omni 1.1 Flash** adds two extra rows: resolution **360p | 720p** and duration **4s | 6s | 8s | 10s**. Selecting it the first time shows a purple "You're generating with Gemini Omni Flash…" promo card with a **Got it** button behind the popover — harmless.
- Footer line: **"Generating will use N credits"** — the live price for the current settings; always read it, never assume. It scales linearly with the x1–x4 count.
- Close with Escape. Selections persist in the composer.
- Text-to-video = Video + Ingredients with no ingredients attached (or Frames with no frames).

## Credit balance
- Click the avatar (**"Account details"**, top right) → a Google account panel shows a link **"N Google Flow credits"** and the line **"Credits refresh daily at HH:MM"** (local time). Read both, then close the panel with its ✕ (**"Close"**). Don't follow the credits link — it goes to the Google One account page.
- Never click Upgrade / Manage subscription / Sign out in that panel.

## Prices seen (2026-10-27, one account on a Google AI plan — yours may differ; read live)
| Setting (x1) | Credits |
|---|---|
| Nano Banana 2.1 / 2 Lite / Pro, any aspect, x1–x4 | 0 |
| Veo 3.1 - Lite, 8s 720p | 10 |
| Veo 3.1 - Fast | 20 |
| Veo 3.1 - Quality | 100 |
| Omni 1.1 Flash 360p 8s | 6 |
| Omni 1.1 Flash 720p 8s / 10s | 12 / 15 |

## Attaching images
- Video › Frames: composer shows **Start** ⇄ **End** slots. Video › Ingredients / Image: use `+`.
- Clicking a slot or `+` opens an in-app picker ("Select a frame image"): left tabs Images / Uploads, search, **"Upload media"** button bottom-left, **"Add to prompt"** button bottom-right of the preview.
- "Upload media" creates an `<input type=file>` on demand (accept `.png,.jpg,.jpeg,.webp,.gif,.heif,.heic`, multiple) and calls `.click()` → native picker. **Run `reference/page-hooks.js` first** (via `javascript_tool`), then click "Upload media"; the input is labelled **"claude upload target"** → `find` it → `file_upload`.
- Uploaded file appears at the top of the picker list (also lands in the project's Uploads), but the highlight may stay on a previously selected asset — wait ~3 s, **click the uploaded filename** in the list, then **"Add to prompt"**. Thumbnail replaces the slot. Composer ✕ (top-right) clears attachments.
- The hooks do not survive a full page reload — rerun after navigation.

## Generation & results
- Tiles appear top-left of All media with a percentage while rendering. Image (Nano Banana 2.1, 1:1) took ~20 s.
- Finished tile gets an auto title (e.g. "Ceramic teapot on wooden table"). Hover → ♡, reuse-prompt, **⋮ "More options"**.
- ⋮ menu: Favourite, Reuse prompt, Animate, Add to prompt, **Download ▸**, Copy, Rename, Share, Set project cover, Flag output, Move to bin.
- Download ▸ (image): **1K Original size**, 2K Upscaled, 4K Upscaled (needs Upgrade). Hover the "Download" menuitem, then `find` "Original size" (the "1K" text isn't in its accessible name) and click it. Verified 2026-10-27: saves a 1024×1024 JPEG. Toast: "Your image has been downloaded!" — the toast appears even if the browser then interrupts the download, so verify with `collect.sh`.
- Video tiles span two grid columns, show a ▶ badge; a "Videos" nav item appears once a project has one. Veo 3.1 Lite, Frames, 16:9, x1: ~1.5 min, 10 credits.
- Video ⋮ menu adds: Add to scene ▸, Publish to YouTube (never click). Download ▸: 270p Animated GIF, **720p Original size**, 1080p / 4K Upscaled (need Upgrade). Toast: "Your video has been downloaded!". Verified 2026-10-27: 1280×720 H.264 + AAC, 8 s MP4.

## Gotchas
- The extension redacts URLs with query strings from `javascript_tool` output, so media can't be fetched by URL — use the Download menu.
- Downloads go through Flow's File System Access save picker ("flow.google.com wants to save" — a native dialog Claude can't click). Flow grabs the picker at page load, so `page-hooks.js` can't disable it. Fix on the browser side: block **File editing** for `https://flow.google.com` (README › Setup).
- Script-dispatched (synthetic) clicks open Flow's menus but don't trigger the final download — use real `computer` hover/click for Download → Original size.
- Screenshot coordinates can differ from CSS pixels (window scaling); click by `find` ref rather than coordinates computed in page JS.
