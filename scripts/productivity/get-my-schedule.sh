#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get My Schedule
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ../images/calendar.png
# @raycast.packageName Calendar
# @raycast.needsConfirmation false
# @raycast.argument1 { "type": "text", "placeholder": "Date (e.g. today+3, 2026-05-14)", "optional": true }

# Documentation:
# @raycast.description Copy today's schedule (or a given date) formatted for Reflect timebox
# @raycast.author egposadas
# @raycast.authorURL https://github.com/egposadas

# Load shared helpers
source "$(dirname "$0")/_calendar_helpers.sh"
check_icalbuddy

# --- Query ALL events (timed + all-day) in one call ---
date_arg="$1"
raw_schedule=$(query_events "$date_arg" \
  -nc -ps "|: |" \
  -iep "datetime,title" -po "datetime,title" \
  -tf "%H:%M" -b "")

# For testing purposes, uncomment the next line
# raw_schedule=$(cat test_data.md)

# Check if the schedule is empty
if [[ -z "$raw_schedule" ]]; then
  if [[ -n "$date_arg" ]]; then
    echo "No events scheduled for $date_arg!"
  else
    echo "No events scheduled for today!"
  fi
  exit 0
fi

allday_schedule=""
timed_schedule=""
event_count=0

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  # Detect timed vs all-day: timed events start with "HH:MM - HH:MM: ..."
  if [[ "$line" =~ ^[0-9]{2}:[0-9]{2}\ -\ [0-9]{2}:[0-9]{2}: ]]; then
    # --- Timed event ---
    time_part=$(printf '%s' "$line" | sed -E 's/^([0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}).*/\1/')
    after_time=$(printf '%s' "$line" | sed -E 's/^[0-9]{2}:[0-9]{2} - [0-9]{2}:[0-9]{2}: //')

    local_title=$(printf '%s' "$after_time" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    is_excluded "$local_title" && continue

    if [[ -z "$date_arg" || "$date_arg" == "today" ]] && is_happening_now "$time_part"; then
      entry="- ▶️ **${time_part}: ${local_title}**"
    else
      entry="- **${time_part}: ${local_title}**"
    fi

    timed_schedule+="${entry}"$'\n'
    ((event_count++))
  else
    # --- All-day event ---
    local_title=$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Strip leading date labels that can remain on all-day lines
    local_title=$(printf '%s' "$local_title" | sed -E 's/^[^:]+: //')
    is_excluded "$local_title" && continue

    entry="- ☀️ **All Day: ${local_title}**"

    allday_schedule+="${entry}"$'\n'
    ((event_count++))
  fi
done <<< "$raw_schedule"

day_label=$(schedule_day_label "$date_arg")
header="# Schedule — ${day_label}"$'\n'

# Combine: header, all-day first, then timed
formatted_schedule="${header}${allday_schedule}${timed_schedule}"

# Check if the schedule is empty after filtering
if [[ -z "$formatted_schedule" ]]; then
  if [[ -n "$date_arg" ]]; then
    echo "No events scheduled for $date_arg!"
  else
    echo "No events scheduled for today!"
  fi
  exit 0
fi

# Copy the formatted schedule to clipboard (printf avoids echo -e emoji corruption)
safe_copy "$formatted_schedule"

# Display success message
if [[ -n "$date_arg" ]]; then
  echo "✅ ${event_count} event(s) for $date_arg copied to clipboard"
else
  echo "✅ ${event_count} event(s) for today copied to clipboard"
fi

