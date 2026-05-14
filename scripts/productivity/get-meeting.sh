#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get Meeting
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 👥
# @raycast.argument1 { "type": "text", "placeholder": "Meeting title (fuzzy)" }
# @raycast.argument2 { "type": "text", "placeholder": "Date (e.g. today+3, 2026-05-14)", "optional": true }

# Documentation:
# @raycast.description Find meeting details by fuzzy title match, copy to clipboard for Reflect
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

# Load shared helpers
source "$(dirname "$0")/_calendar_helpers.sh"
check_icalbuddy

search_term="$1"
date_arg="$2"

# Query events with title, datetime, and notes
# Use § separator to avoid conflicts with ": " in titles/notes
# Use -npn to strip property name prefixes (e.g. "notes:")
# Use NL_MARKER to replace newlines in notes for single-line parsing
SEP="§"
events=$(query_events "$date_arg" \
  -nc -npn -ps "|${SEP}|" \
  -iep "datetime,title,notes" -po "datetime,title,notes" \
  -tf "%H:%M" -ea -b "" \
  -nnr "$NL_MARKER" --maxNumNoteChars 200)

result=""
matched_title=""
matched_notes=""
declare -a match_times_arr=()
declare -a match_titles_arr=()
declare -a match_notes_arr=()
declare -a all_entries=()

# Collapse multi-line output into single lines per event.
# icalBuddy may output notes across multiple lines; detect event boundaries by time pattern.
declare -a event_lines=()
current_line=""
while IFS= read -r line; do
  if [[ "$line" =~ ^[0-9]{2}:[0-9]{2}\ -\ [0-9]{2}:[0-9]{2} ]]; then
    [[ -n "$current_line" ]] && event_lines+=("$current_line")
    current_line="$line"
  elif [[ -n "$current_line" ]]; then
    current_line+=" $line"
  fi
done <<< "$events"
[[ -n "$current_line" ]] && event_lines+=("$current_line")

# Process each collapsed event line
for line in "${event_lines[@]}"; do
  [[ -z "$line" ]] && continue

  IFS="$SEP" read -ra parts <<< "$line"

  time_part=$(printf '%s' "${parts[0]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  title_part=$(printf '%s' "${parts[1]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  notes_part=$(printf '%s' "${parts[2]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  [[ -z "$title_part" ]] && continue
  all_entries+=("${time_part}  ${title_part}")

  if fuzzy_match "$search_term" "$title_part"; then
    match_times_arr+=("$time_part")
    match_titles_arr+=("$title_part")
    match_notes_arr+=("$notes_part")
  fi
done

num_matches=${#match_titles_arr[@]}

# Output the result
if [[ $num_matches -eq 1 ]]; then
  matched_title="${match_titles_arr[0]}"
  matched_notes=$(restore_newlines "${match_notes_arr[0]}")
  result="- **${match_times_arr[0]}: ${matched_title}**"
  [[ -n "$matched_notes" ]] && result+=$'\n'"  _Notes:_ ${matched_notes}"

  safe_copy "$result"
  echo "\"$matched_title\" copied to clipboard"
elif [[ $num_matches -gt 1 ]]; then
  echo "Multiple matches for \"$1\" — refine your search:"
  for ((i=0; i<num_matches; i++)); do
    echo "  ${match_times_arr[$i]}: ${match_titles_arr[$i]}"
  done
else
  echo "No meeting found matching \"$1\""
  if [[ ${#all_entries[@]} -gt 0 ]]; then
    echo "Available meetings:"
    for entry in "${all_entries[@]}"; do
      echo "  $entry"
    done
  fi
fi

