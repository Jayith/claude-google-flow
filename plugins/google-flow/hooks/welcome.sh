#!/usr/bin/env bash
# SessionStart hook: show the welcome card once, the first time Claude Code starts
# after the plugin is installed. Prints nothing on later sessions.
set -euo pipefail

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
data="${CLAUDE_PLUGIN_DATA:-}"
[[ -n "$data" ]] || exit 0
[[ -f "$data/welcomed" ]] && exit 0

# JSON-escape the card without needing jq or python.
json_escape() {
  local s
  s=$(cat "$1")
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\t'/\\t}
  s=${s//$'\r'/}
  s=${s//$'\n'/\\n}
  printf '%s' "$s"
}

card=$(json_escape "$root/welcome.txt")
context="The google-flow plugin was just installed and the user was shown its welcome card in the terminal. Its commands are /google-flow:setup, /google-flow:generate, /google-flow:credits and /google-flow:welcome. If the user hasn't run setup yet and asks to make something in Flow, start with setup."

printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$card" "$context"

mkdir -p "$data"
date '+%Y-%m-%d' > "$data/welcomed"
