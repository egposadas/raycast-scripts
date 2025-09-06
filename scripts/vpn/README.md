# VPN Scripts

Scripts for managing VPN connections on macOS.

## Scripts

### vpn-config.sh
Manages VPN configuration settings.
- **Mode**: Variable
- **Dependencies**: None
- **Permissions**: Network settings access may be required

### vpn-start.sh
Starts a VPN connection.
- **Mode**: Silent
- **Dependencies**: None  
- **Permissions**: Network settings access required

### vpn-status.sh
Checks the current status of VPN connection.
- **Mode**: Inline
- **Dependencies**: None
- **Permissions**: Network settings access may be required

### vpn-stop.sh
Stops the active VPN connection.
- **Mode**: Silent
- **Dependencies**: None
- **Permissions**: Network settings access required

## Setup Notes

These scripts may require:
1. VPN client software to be installed
2. Network settings permissions
3. Specific VPN configuration profiles

Make sure your VPN is properly configured before using these scripts.