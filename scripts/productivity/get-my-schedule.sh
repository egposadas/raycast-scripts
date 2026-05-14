#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get my schedule
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📅
# @raycast.needsConfirmation false
# @raycast.argument1 { "type": "text", "placeholder": "Date (e.g. today+3, 2026-05-14)", "optional": true }

# Documentation:
# @raycast.description icalBuddy schedule of the day with formatted output for Reflect timebox
# @raycast.author egposadas
# @raycast.authorURL https://raycast.com/batcave/scripts

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

    entry="- **${time_part}: ${local_title}**"

    timed_schedule+="${entry}"$'\n'
    ((event_count++))
  else
    # --- All-day event ---
    local_title=$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    is_excluded "$local_title" && continue

    entry="- ☀️ **All Day: ${local_title}**"

    allday_schedule+="${entry}"$'\n'
    ((event_count++))
  fi
done <<< "$raw_schedule"

# Combine: all-day first, then timed
formatted_schedule="${allday_schedule}${timed_schedule}"

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

