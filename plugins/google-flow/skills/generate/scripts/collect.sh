#!/usr/bin/env bash
# Moves files the browser downloaded from Google Flow into an output folder.
#
#   collect.sh mark                        remember "now" so later downloads can be found
#   collect.sh dir                         print the browser's download folder
#   collect.sh browser                     print the detected browser and its settings URL scheme
#   collect.sh collect <out_dir> <prompt>  move downloads newer than the mark into out_dir
#   collect.sh setup-status <state_dir>    exit 0 if first-time setup was completed, 5 if not
#   collect.sh setup-done <state_dir>      record that first-time setup was completed
#
# Env overrides:
#   FLOW_DOWNLOADS        download folder (skips browser detection)
#   FLOW_BROWSER_PROFILE  Chromium profile dir containing Preferences / History
#
# Works on macOS, Linux and Windows (Git Bash). Exit codes: 0 ok, 1 usage/no mark,
# 3 download folder missing, 4 nothing downloaded, 5 setup needed.
set -euo pipefail

MARK="${TMPDIR:-/tmp}/google-flow.mark"

# Candidate Chromium profile dirs (Default profile) for each OS.
profile_candidates() {
  local h="$HOME"
  case "$(uname -s)" in
    Darwin)
      local b="$h/Library/Application Support"
      printf '%s\n' "$b/Google/Chrome/Default" "$b/BraveSoftware/Brave-Browser/Default" \
        "$b/Microsoft Edge/Default" "$b/Arc/User Data/Default" "$b/Vivaldi/Default" "$b/Chromium/Default"
      ;;
    MINGW* | MSYS* | CYGWIN*)
      local l="${LOCALAPPDATA:-$h/AppData/Local}"
      command -v cygpath >/dev/null && l="$(cygpath -u "$l")"
      printf '%s\n' "$l/Google/Chrome/User Data/Default" "$l/BraveSoftware/Brave-Browser/User Data/Default" \
        "$l/Microsoft/Edge/User Data/Default" "$l/Vivaldi/User Data/Default" "$l/Chromium/User Data/Default"
      ;;
    *)
      local c="${XDG_CONFIG_HOME:-$h/.config}"
      printf '%s\n' "$c/google-chrome/Default" "$c/BraveSoftware/Brave-Browser/Default" \
        "$c/microsoft-edge/Default" "$c/vivaldi/Default" "$c/chromium/Default"
      ;;
  esac
}

mtime() { date -r "$1" +%s 2>/dev/null || stat -c %Y "$1" 2>/dev/null || stat -f %m "$1"; }

# The most recently used browser profile is almost always the one Claude in Chrome drives.
browser_profile() {
  if [[ -n "${FLOW_BROWSER_PROFILE:-}" ]]; then printf '%s\n' "$FLOW_BROWSER_PROFILE"; return; fi
  local best="" best_t=0 p t
  while IFS= read -r p; do
    [[ -f "$p/Preferences" ]] || continue
    t=$(mtime "$p/Preferences")
    if (( t > best_t )); then best="$p"; best_t=$t; fi
  done < <(profile_candidates)
  printf '%s\n' "$best"
}

default_downloads() {
  case "$(uname -s)" in
    Darwin | MINGW* | MSYS* | CYGWIN*) printf '%s\n' "$HOME/Downloads" ;;
    *) command -v xdg-user-dir >/dev/null && xdg-user-dir DOWNLOAD || printf '%s\n' "$HOME/Downloads" ;;
  esac
}

download_dir() {
  if [[ -n "${FLOW_DOWNLOADS:-}" ]]; then printf '%s\n' "$FLOW_DOWNLOADS"; return; fi
  local prof d=""
  prof=$(browser_profile)
  if [[ -n "$prof" && -f "$prof/Preferences" ]]; then
    d=$(grep -o '"default_directory":"[^"]*"' "$prof/Preferences" | head -1 | sed 's/^"default_directory":"//; s/"$//; s/\\\\/\\/g' || true)
    if [[ -n "$d" ]] && command -v cygpath >/dev/null; then d=$(cygpath -u "$d"); fi
  fi
  if [[ -n "$d" ]]; then printf '%s\n' "$d"; else default_downloads; fi
}

# List downloads the browser started after the mark but didn't finish (needs sqlite3).
report_interrupted() {
  local prof db since
  prof=$(browser_profile)
  [[ -n "$prof" && -f "$prof/History" ]] && command -v sqlite3 >/dev/null || return 0
  db="${TMPDIR:-/tmp}/google-flow-history.db"
  cp "$prof/History" "$db" 2>/dev/null || return 0
  since=$(( ($(mtime "$MARK") + 11644473600) * 1000000 ))
  sqlite3 "$db" "select 'interrupted download (reason ' || interrupt_reason || ') ' || mime_type from downloads where start_time >= $since and state = 2;" >&2 || true
  rm -f "$db"
}

case "${1:-}" in
  mark)
    touch "$MARK"
    dl=$(download_dir)
    [[ -d "$dl" ]] || { echo "WARNING: browser download folder does not exist: $dl" >&2; exit 3; }
    prof=$(browser_profile)
    if [[ -n "$prof" ]] && grep -q '"prompt_for_download":true' "$prof/Preferences" 2>/dev/null; then
      echo "WARNING: the browser asks where to save each download; turn that off in its download settings" >&2
    fi
    echo "marked $(date '+%H:%M:%S'); downloads go to $dl"
    ;;
  dir)
    download_dir
    ;;
  browser)
    # name + settings URL scheme of the detected browser, e.g. "brave brave://"
    case "$(browser_profile)" in
      *BraveSoftware*) echo "brave brave://" ;;
      *Edge* | *edge*) echo "edge edge://" ;;
      *Vivaldi* | *vivaldi*) echo "vivaldi vivaldi://" ;;
      *Arc*) echo "arc chrome://" ;;
      *Chromium* | *chromium*) echo "chromium chrome://" ;;
      *Chrome* | *chrome*) echo "chrome chrome://" ;;
      *) echo "unknown chrome://" ;;
    esac
    ;;
  collect)
    out="${2:?out dir required}"
    prompt="${3:-flow}"
    [[ -f "$MARK" ]] || { echo "no mark; run '$0 mark' first" >&2; exit 1; }
    dl=$(download_dir)
    mkdir -p "$out"
    slug=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')
    # keep it short, cutting at a word boundary
    if (( ${#slug} > 40 )); then slug=${slug:0:41}; slug=${slug%-*}; fi
    stamp=$(date '+%Y%m%d-%H%M%S')
    # wait for in-progress downloads to finish (up to 2 min)
    for _ in $(seq 60); do
      [[ -z $(find "$dl" -maxdepth 1 -name '*.crdownload' -newer "$MARK" 2>/dev/null) ]] && break
      sleep 2
    done
    n=0
    while IFS= read -r -d '' f; do
      n=$((n + 1))
      dest="$out/${slug:-flow}-${stamp}-${n}.${f##*.}"
      mv "$f" "$dest"
      echo "$dest"
    done < <(find "$dl" -maxdepth 1 -type f -newer "$MARK" \
      \( -iname '*.mp4' -o -iname '*.mov' -o -iname '*.webm' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) -print0 2>/dev/null)
    if (( n == 0 )); then
      echo "no new files in $dl" >&2
      report_interrupted
      exit 4
    fi
    ;;
  setup-status)
    state="${2:?state dir required}"
    if [[ -f "$state/setup-done" ]]; then echo "setup done $(cat "$state/setup-done")"; else echo "setup needed"; exit 5; fi
    ;;
  setup-done)
    state="${2:?state dir required}"
    mkdir -p "$state"
    date '+%Y-%m-%d' > "$state/setup-done"
    echo "setup marked done"
    ;;
  *)
    echo "usage: $0 mark | dir | collect <out_dir> <prompt> | setup-status <state_dir> | setup-done <state_dir>" >&2
    exit 2
    ;;
esac
