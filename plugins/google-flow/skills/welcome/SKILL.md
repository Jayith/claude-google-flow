---
name: welcome
description: Show the Google Flow plugin's welcome card — every command, example prompts and options in one friendly screen. Use when the user runs /google-flow:welcome, has just installed the plugin, or asks what the Google Flow plugin can do, which commands it has, or how to use it.
allowed-tools: Read(${CLAUDE_PLUGIN_ROOT}/welcome.txt) Bash(${CLAUDE_PLUGIN_ROOT}/skills/generate/scripts/collect.sh setup-status *)
---

# Welcome 🎬

1. Read `${CLAUDE_PLUGIN_ROOT}/welcome.txt` and show it to the user **exactly as written**, inside a plain fenced code block (no language tag) so the alignment holds. Don't summarize, reword or add to it.
2. Run `${CLAUDE_PLUGIN_ROOT}/skills/generate/scripts/collect.sh setup-status "${CLAUDE_PLUGIN_DATA}"` and add ONE short, upbeat line under the card:
   - exit 5 (setup not done) → invite them to start with `/google-flow:setup` and say it only takes a couple of minutes.
   - exit 0 → invite them to make something, or to check `/google-flow:credits` first.
That's it — keep the rest of the reply empty.
