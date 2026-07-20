# Raycast Scripts Collection

Personal Raycast Script Commands, organized by category.

## Quick Start

1. Clone this repository
2. Open Raycast → **Extensions** → **Script Commands** → add a script directory
3. Point it at this repo's `scripts/` folder (or a subcategory)
4. Search Raycast for the command titles below

## Repository Structure

```
scripts/
├── images/           # PNG icons for Script Commands (64px)
├── productivity/     # Calendar, Mail, daily workflow
├── system/           # macOS system utilities
├── vpn/              # Azure VPN (rty-dna) connect/status
├── work/             # Riverty-specific utilities
└── templates/        # Starters for new scripts
```

## Available Scripts

### Calendar (`scripts/productivity/`)

| Command | File | Mode |
|---------|------|------|
| **Get Meeting** | `get-meeting.sh` | silent |
| **Get Meeting Info** | `get-meeting-info.sh` | fullOutput |
| **Get My Schedule** | `get-my-schedule.sh` | silent |

Requires [icalBuddy](https://github.com/Ali-Sadel/icalBuddy).

Extras:
- Extracts Teams / Zoom / Meet join links from invite notes when present
- Schedule output includes a day header and marks the current meeting with ▶️

### Productivity

| Command | File | Mode |
|---------|------|------|
| **Copy Mail Deeplink** | `mail-deeplink.applescript` | silent |

Select message(s) in Apple Mail, then run the command to copy Markdown `message://` deeplinks.

### System

| Command | File | Mode |
|---------|------|------|
| **Toggle Sidecar** | `toggle-sidecar.js` | inline |

Optional device-name argument (defaults to `C3P0`).

### VPN (`scripts/vpn/`) — disabled as Script Commands

Kept in the repo for backup/CLI use; Raycast metadata is commented out because VPN is handled by an extension. Connection name: `VPN_NAME=rty-dna` in `vpn-config.sh`.

### Work

| Command | File | Mode |
|---------|------|------|
| **Riverty Colors** | `riverty-colors.sh` | silent |

Copies Hex, RGB, or RGBA for brand colors at 100% / 70% / 30% opacity.

## Icons

Raycast Script Commands only support **emoji**, **PNG**, or **JPEG** icons (not `.icns`). App icons live in `scripts/images/` and are referenced with relative paths like `../images/calendar.png`.

## Creating New Scripts

1. Copy a template from `scripts/templates/`
2. Fill in `@raycast.title`, `@raycast.mode`, `@raycast.icon`, and `@raycast.description`
3. Prefer a PNG under `scripts/images/` for app-tied commands; use emoji for abstract utilities
4. Set `@raycast.packageName` so related commands group in Raycast
5. Make the script executable: `chmod +x your-script.sh`

## Troubleshooting

- **Permission denied** — `chmod +x` the script
- **Script missing in Raycast** — ensure `@raycast.schemaVersion` and `@raycast.title` are present (not commented out)
- **No icon** — use emoji or a PNG/JPEG path (`.icns` will not render)
- **Calendar scripts fail** — install `icalBuddy` and grant Calendar access
- **VPN scripts fail** — confirm Azure VPN Client is installed and `VPN_NAME` matches `scutil --nc list`