#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get Meeting Info
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ℹ️
# @raycast.argument1 { "type": "text", "placeholder": "Meeting Title (fuzzy)" }
# @raycast.argument2 { "type": "text", "placeholder": "Date (e.g. today+3, 2026-05-14)", "optional": true }

# Documentation:
# @raycast.description Show meeting info (attendees, notes, location) and copy to clipboard for Reflect
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

# Load shared helpers
source "$(dirname "$0")/_calendar_helpers.sh"
check_icalbuddy

search_term="$1"
date_arg="$2"

# Query events with all useful properties
# Use a unique separator (§) between properties to avoid conflicts with ": " in content
SEP="§"
events=$(query_events "$date_arg" \
  -nc -na 20 -npn \
  -ps "|${SEP}|" \
  -iep "datetime,title,attendees,notes" \
  -po "datetime,title,attendees,notes" \
  -b "" -tf "%H:%M" -ea \
  -nnr "$NL_MARKER" --maxNumNoteChars 500)

# Parse events into structured data — collect ALL matches, not just the first
# Parse events — collapse multi-line output into single lines per event.
# icalBuddy may output attendees/notes across multiple lines; -nnr only handles notes.
# We detect event boundaries by the time pattern and join continuation lines.
declare -a event_lines=()
current_line=""
while IFS= read -r line; do
  if [[ "$line" =~ ^[0-9]{2}:[0-9]{2}\ -\ [0-9]{2}:[0-9]{2} ]]; then
    # New event starts — save previous if any
    [[ -n "$current_line" ]] && event_lines+=("$current_line")
    current_line="$line"
  elif [[ -n "$current_line" ]]; then
    # Continuation of previous event — append with space
    current_line+=" $line"
  fi
done <<< "$events"
[[ -n "$current_line" ]] && event_lines+=("$current_line")

# Now parse each collapsed event line
declare -a match_times=()
declare -a match_titles=()
declare -a match_attendees=()
declare -a match_notes=()
declare -a all_entries=()

for line in "${event_lines[@]}"; do
  [[ -z "$line" ]] && continue

  # Split by our separator §
  IFS="$SEP" read -ra parts <<< "$line"

  event_time=$(printf '%s' "${parts[0]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  event_title=$(printf '%s' "${parts[1]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  event_attendees=$(printf '%s' "${parts[2]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  event_notes=$(printf '%s' "${parts[3]:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  [[ -z "$event_title" ]] && continue
  all_entries+=("${event_time}  ${event_title}")

  if fuzzy_match "$search_term" "$event_title"; then
    match_times+=("$event_time")
    match_titles+=("$event_title")
    match_attendees+=("$event_attendees")
    match_notes+=("$event_notes")
  fi
done

num_matches=${#match_titles[@]}

if [[ $num_matches -eq 1 ]]; then
  # Exactly one match — show it
  matched_time="${match_times[0]}"
  matched_title="${match_titles[0]}"
  matched_attendees="${match_attendees[0]}"
  matched_notes=$(restore_newlines "${match_notes[0]}")

  # Build display output (shown in Raycast fullOutput panel)
  display="## ${matched_title}"
  display+=$'\n'
  [[ -n "$matched_time" ]] && display+=$'\n'"**Time:** ${matched_time}"
  [[ -n "$matched_attendees" ]] && display+=$'\n\n'"**Attendees:** ${matched_attendees}"
  [[ -n "$matched_notes" ]] && display+=$'\n\n'"**Notes from invite:**"$'\n'"${matched_notes}"

  # Build clipboard output (optimized for Reflect notes pasting)
  clipboard=""
  [[ -n "$matched_time" ]] && clipboard+="- _Time:_ ${matched_time}"$'\n'
  [[ -n "$matched_attendees" ]] && clipboard+="- _Attendees:_ ${matched_attendees}"$'\n'
  if [[ -n "$matched_notes" ]]; then
    clipboard+="- _Notes:_"$'\n'"${matched_notes}"$'\n'
  else
    clipboard+="- _Notes:_"$'\n'
  fi
  clipboard+="- _Action Items:_"$'\n'
  clipboard+="- _References:_"

  # Copy to clipboard and display
  safe_copy "$clipboard"

  printf '%s\n' "$display"
  echo ""
  echo "---"
  echo "Copied to clipboard for ${date_arg:-today}"
elif [[ $num_matches -gt 1 ]]; then
  # Multiple matches — list them so the user can refine
  echo "Multiple matches found for \"$1\" — please refine your search:"
  echo ""
  for ((i=0; i<num_matches; i++)); do
    echo "  ${match_times[$i]}: ${match_titles[$i]}"
  done
  exit 1
else
  echo "No matching event found for \"$1\" on ${date_arg:-today}"
  if [[ ${#all_entries[@]} -gt 0 ]]; then
    echo ""
    echo "Available meetings:"
    for entry in "${all_entries[@]}"; do
      echo "  $entry"
    done
  fi
  exit 1
fi

