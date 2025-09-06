# Calendar Scripts

Scripts for managing calendar events and meeting information.

## Scripts

### get-meeting-info.sh
Retrieves detailed information about calendar events by title.
- **Mode**: Silent
- **Dependencies**: None
- **Permissions**: Calendar access required
- **Arguments**: 
  - Meeting title (required)
  - Date in YYYY-MM-DD format (optional)

### get-meeting.sh
Retrieves meeting details from calendar.
- **Mode**: Variable
- **Dependencies**: None
- **Permissions**: Calendar access required

### get-my-schedule.sh
Displays your current schedule and upcoming meetings.
- **Mode**: Variable
- **Dependencies**: None
- **Permissions**: Calendar access required

## Setup Notes

These scripts require:
1. Calendar access permissions
2. Configured calendar accounts in macOS Calendar app
3. Active calendar events to query

Grant calendar permissions when prompted by macOS.