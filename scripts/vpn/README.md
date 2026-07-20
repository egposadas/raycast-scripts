# VPN Scripts

Azure VPN Client scripts for the `rty-dna` connection, controlled via `scutil --nc`.

> **Disabled in Raycast** — these Script Commands are deactivated because VPN is now handled by a Raycast extension. The scripts remain for CLI use / backup. To re-enable, uncomment `@raycast.schemaVersion` and `@raycast.title` in `vpn-status.sh` and `vpn-toggle.sh`.

## Scripts

| File | Raycast title | Mode |
|------|---------------|------|
| `vpn-config.sh` | (shared helpers) | — |
| `vpn-status.sh` | Azure VPN - status (disabled) | Inline (1m refresh) |
| `vpn-toggle.sh` | Azure VPN - toggle (disabled) | Silent |

## Setup

1. Install **Azure VPN Client** and import the `rty-dna` profile
2. Confirm the name: `scutil --nc list`
3. If the name differs, edit `VPN_NAME` in `vpn-config.sh`
