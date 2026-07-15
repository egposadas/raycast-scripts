#!/usr/bin/env bash

# Name of your VPN as shown in System Settings → VPN
export VPN_NAME="ProtonVPN"

# ProtonVPN uses a Network Extension (not a traditional VPN type),
# so scutil --nc cannot see or control it. These scripts use
# AppleScript to toggle the VPN through System Settings instead.

if [ -z "$VPN_NAME" ]; then
  echo "\$VPN_NAME is empty";
  echo "Please, rename it in \"vpn-config.sh\".";
  exit 1;
fi

# --- Helper functions for Network Extension VPNs ---

# Detect VPN status by checking if any utun interface has a
# non-link-local, non-loopback IPv4 address assigned by the VPN.
vpn_is_connected() {
  ifconfig 2>/dev/null \
    | awk '/^utun/{iface=1} iface && /inet [0-9]/{print $2; iface=0}' \
    | grep -qvE '^(127\.|169\.254\.)'
}

# Toggle the VPN on/off via System Settings using AppleScript.
# Requires Raycast (or the calling app) to have Accessibility access.
vpn_toggle_via_settings() {
  local vpn_name="$1"
  local action="$2"  # "connect" or "disconnect"

  osascript <<EOF
tell application "System Settings"
    activate
    delay 0.5
    reveal anchor "VPN" in pane id "com.apple.systempreferences.vpn"
    delay 1
end tell

tell application "System Events"
    tell process "System Settings"
        set vpnRow to first row of table 1 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window 1 whose value of static text 1 contains "${vpn_name}"
        set vpnToggle to checkbox 1 of vpnRow
        set currentValue to value of vpnToggle
        if "${action}" is "connect" and currentValue is 0 then
            click vpnToggle
        else if "${action}" is "disconnect" and currentValue is 1 then
            click vpnToggle
        end if
    end tell
end tell

delay 0.5
tell application "System Settings" to quit
EOF
}
