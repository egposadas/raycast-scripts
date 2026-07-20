#!/bin/bash
# Shared helpers for Raycast calendar scripts
# This file is sourced by the productivity scripts — NOT a standalone Raycast command.

# --- Locale ---
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# --- Configuration ---
# Pipe-separated list of event titles to exclude (case-insensitive)
EXCLUDE_EVENTS="Lunch"

# Marker used by -nnr to replace newlines in notes during parsing.
# After extraction, restore_newlines converts it back to real line breaks.
NL_MARKER="{{NL}}"

# --- Dependency check ---
check_icalbuddy() {
  if ! command -v icalBuddy &>/dev/null; then
    echo "❌ icalBuddy is not installed. Install with: brew install ical-buddy"
    exit 1
  fi
}

# --- Event query wrapper ---
# Usage: query_events "$date" [extra_icalbuddy_args...]
# If $date is empty, queries today's events.
# Passes any extra arguments directly to icalBuddy.
# When a date argument is provided, icalBuddy prefixes output with the date label:
#   Timed:   "tomorrow at 07:30 - 08:15: Title"  (instead of "07:30 - 08:15: Title")
#   All-day: "tomorrow: Title"                    (instead of just "Title")
# We strip these prefixes so downstream parsing always sees a consistent format.
query_events() {
  local date="$1"
  shift
  if [[ -n "$date" ]]; then
    icalBuddy "$@" eventsFrom:"$date" to:"$date" | sed -E \
      -e 's/^.+ at ([0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2})/\1/' \
      -e '/^[0-9]{2}:[0-9]{2}/!s/^[^:]+: //'
  else
    icalBuddy "$@" eventsToday
  fi
}

# --- Safe clipboard copy ---
# Usage: safe_copy "text"
# Uses printf to avoid echo -e interpreting escape sequences in event titles/emojis.
safe_copy() {
  printf '%s' "$1" | pbcopy
}

# --- Fuzzy match ---
# Usage: fuzzy_match "search words" "text to match against"
# Returns 0 (true) if ALL words in the search term appear in the text (any order, case-insensitive).
# Tolerates single-character typos (e.g. "debex" matches "devex").
# Example: fuzzy_match "dna sync" "DnA ArGo Sync" → true
fuzzy_match() {
  local search="$1"
  local text="$2"
  local text_lower
  text_lower=$(printf '%s' "$text" | tr '[:upper:]' '[:lower:]')

  # Split search into words and check each
  local word
  while IFS= read -r word; do
    [[ -z "$word" ]] && continue
    word=$(printf '%s' "$word" | tr '[:upper:]' '[:lower:]')

    # 1) Exact substring match
    if [[ "$text_lower" == *"$word"* ]]; then
      continue
    fi

    # 2) Typo-tolerant: try replacing each character with a wildcard (?)
    #    Handles single-character substitutions like "debex" → "de?ex" matches "devex"
    local typo_matched=false
    local len=${#word}
    local i
    for ((i=0; i<len; i++)); do
      local pattern="${word:0:i}?${word:i+1}"
      if [[ "$text_lower" == *${pattern}* ]]; then
        typo_matched=true
        break
      fi
    done

    if [[ "$typo_matched" == false ]]; then
      return 1
    fi
  done <<< "$(printf '%s' "$search" | tr ' ' '\n')"
  return 0
}

# --- Event exclusion check ---
# Usage: is_excluded "Event Title"
# Returns 0 (true) if the title matches any entry in EXCLUDE_EVENTS.
is_excluded() {
  local title="$1"
  local title_lower
  title_lower=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]')

  local IFS='|'
  local pattern
  for pattern in $EXCLUDE_EVENTS; do
    pattern=$(printf '%s' "$pattern" | tr '[:upper:]' '[:lower:]')
    if [[ "$title_lower" == "$pattern" ]]; then
      return 0
    fi
  done
  return 1
}

# --- Restore newlines ---
# Usage: restore_newlines "text with {{NL}} markers"
# Replaces NL_MARKER back to real newlines after extraction from icalBuddy output.
restore_newlines() {
  local text="$1"
  local newline=$'\n'
  printf '%s' "${text//${NL_MARKER}/${newline}}"
}

# --- Extract first meeting join URL from notes ---
# Prefers Teams, then Zoom, then Google Meet, then any https URL.
extract_join_url() {
  local notes="$1"
  [[ -z "$notes" ]] && return 1

  local url
  url=$(printf '%s' "$notes" | grep -Eo 'https://teams\.microsoft\.com/l/meetup-join/[^[:space:]>"]+' | head -1)
  [[ -n "$url" ]] && { printf '%s' "$url"; return 0; }

  url=$(printf '%s' "$notes" | grep -Eo 'https://[^[:space:]"]*zoom\.us/j/[^[:space:]>"]+' | head -1)
  [[ -n "$url" ]] && { printf '%s' "$url"; return 0; }

  url=$(printf '%s' "$notes" | grep -Eo 'https://meet\.google\.com/[a-zA-Z0-9-]+' | head -1)
  [[ -n "$url" ]] && { printf '%s' "$url"; return 0; }

  url=$(printf '%s' "$notes" | grep -Eo 'https://[^[:space:]>"]+' | head -1)
  [[ -n "$url" ]] && { printf '%s' "$url"; return 0; }

  return 1
}

# --- Schedule day label ---
# Usage: schedule_day_label "$date_arg"
# Returns a human label like "Monday, 20 Jul 2026".
schedule_day_label() {
  local date_arg="$1"
  if [[ -z "$date_arg" || "$date_arg" == "today" ]]; then
    date "+%A, %d %b %Y"
  else
    # Best-effort parse; fall back to the raw argument on failure.
    date -j -f "%Y-%m-%d" "$date_arg" "+%A, %d %b %Y" 2>/dev/null \
      || date -j -v"$date_arg" "+%A, %d %b %Y" 2>/dev/null \
      || printf '%s' "$date_arg"
  fi
}

# --- Is current time inside HH:MM - HH:MM? ---
# Usage: is_happening_now "09:00 - 09:30"
is_happening_now() {
  local range="$1"
  local start_h start_m end_h end_m now_mins start_mins end_mins
  if [[ ! "$range" =~ ^([0-9]{2}):([0-9]{2})\ -\ ([0-9]{2}):([0-9]{2}) ]]; then
    return 1
  fi
  start_h="${BASH_REMATCH[1]}"
  start_m="${BASH_REMATCH[2]}"
  end_h="${BASH_REMATCH[3]}"
  end_m="${BASH_REMATCH[4]}"
  now_mins=$((10#$(date +%H) * 60 + 10#$(date +%M)))
  start_mins=$((10#$start_h * 60 + 10#$start_m))
  end_mins=$((10#$end_h * 60 + 10#$end_m))
  [[ $now_mins -ge $start_mins && $now_mins -lt $end_mins ]]
}
