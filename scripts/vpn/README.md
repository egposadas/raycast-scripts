# VPN Scripts

Azure VPN Client scripts for the `rty-dna` connection, controlled via `scutil --nc`.

## Scripts

| File | Raycast title | Mode |
|------|---------------|------|
| `vpn-config.sh` | (shared helpers) | — |
| `vpn-status.sh` | Azure VPN - status | Inline (1m refresh) |
| `vpn-toggle.sh` | Azure VPN - toggle | Silent |

## Setup

1. Install **Azure VPN Client** and import the `rty-dna` profile
2. Confirm the name: `scutil --nc list`
3. If the name differs, edit `VPN_NAME` in `vpn-config.sh`
