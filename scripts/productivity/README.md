# Productivity Scripts

Scripts to enhance productivity and automate common tasks. Calendar scripts are optimized for a **Reflect timebox workflow**: capture your daily schedule → paste as a list → enrich with notes and action items during the day.

## Dependencies

- **icalBuddy** — required by all calendar scripts. Install with `brew install ical-buddy`
- **macOS Calendar** — configured with your calendar accounts
- **Calendar permissions** — grant access when prompted by macOS

## Scripts

### 📅 get-my-schedule.sh

Copies the full day's schedule to clipboard as a Markdown list, ready to paste into Reflect.

- **Mode**: Silent
- **Arguments**:
  - Date (optional) — e.g. `today+3`, `2026-05-14`. Defaults to today.
- **Features**:
  - All-day events shown at the top with 🌐 prefix
  - Timed events with location shown inline _(Room 3.01)_
  - Configurable event exclusion (default: "Lunch") via `EXCLUDE_EVENTS` in `_calendar_helpers.sh`
  - Event count in success message
  - Emoji-safe output (no garbling in Raycast v2)

**Example clipboard output:**
```
- **🌐 All Day: Company Holiday**
- **09:00 - 09:25: 🛡️ DnA ArGo Sync**
- **09:45 - 10:00: 🗓️ DnA PE - Daily** _(Room 3.01)_
- **10:00 - 10:25: Weekly BU 1:1**
```

### 👥 get-meeting.sh

Find a specific meeting by fuzzy title search, copies time + title + details to clipboard.

- **Mode**: Silent
- **Arguments**:
  - Meeting title (required) — supports fuzzy matching (e.g. "dna sync" matches "DnA ArGo Sync")
  - Date (optional) — e.g. `today+3`, `2026-05-14`. Defaults to today.
- **Features**:
  - Word-based fuzzy matching (all words must appear, any order)
  - Shows location and notes (from calendar invite) if available
  - On no match, shows up to 5 available meeting titles as suggestions

### ℹ️ get-meeting-info.sh

Show detailed meeting info (attendees, notes, location) in Raycast and copy a Reflect-ready template to clipboard.

- **Mode**: Full Output (visible in Raycast panel)
- **Arguments**:
  - Meeting title (required) — supports fuzzy matching
  - Date (optional) — e.g. `today+3`, `2026-05-14`. Defaults to today.
- **Features**:
  - Displays meeting info in Raycast's output panel for review
  - Auto-copies structured template to clipboard:
    ```
    - _Time:_ 09:00 - 09:25
    - _Location:_ Room 3.01
    - _Attendees:_ Person A, Person B
    - _Notes:_ Agenda from calendar invite
    - _Action Items:_
    - _References:_
    ```
  - Up to 20 attendees shown, notes truncated to 500 chars
  - On no match, shows suggestions

### ✉️ mail-deeplink.applescript

Creates deep links for mail items in macOS Mail app.

- **Mode**: Compact
- **Dependencies**: Mail app access

## Shared Helpers

### _calendar_helpers.sh

Shared functions sourced by all calendar scripts. **Not a Raycast command** (underscore prefix).

Contains:
- **Locale setup** — `LC_ALL=en_US.UTF-8` for emoji/UTF-8 safety
- **`check_icalbuddy()`** — exits with clear error if icalBuddy is missing
- **`query_events(date, ...args)`** — wraps `eventsToday` vs `eventsFrom:date to:date`
- **`safe_copy(text)`** — printf-based clipboard copy (avoids echo -e corruption)
- **`fuzzy_match(search, text)`** — word-based fuzzy matching
- **`is_excluded(title)`** — checks against `EXCLUDE_EVENTS` config
- **`EXCLUDE_EVENTS`** — pipe-separated list of event titles to exclude (default: `"Lunch"`)

### Customizing Excluded Events

Edit `_calendar_helpers.sh` and modify the `EXCLUDE_EVENTS` variable:

```bash
# Exclude multiple events (pipe-separated, case-insensitive)
EXCLUDE_EVENTS="Lunch|Focus Time|Block"
```