#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DnA VPN - toggle
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📡

# @Documentation:
# @raycast.packageName VPN
# @raycast.description Toggle VPN connection on/off.
# @raycast.author Eduardo Posadas
# @raycast.authorURL https://github.com/egposadas


source vpn-config.sh
VPN=$VPN_NAME

status=$(scutil --nc status "$VPN" | sed -n 1p)

if [ "$status" == "Connected" ]; then
    networksetup -disconnectpppoeservice "$VPN"
    echo "Disconnected from $VPN!"
    exit 0
fi

# Connect
function isnt_connected () {
    scutil --nc status "$VPN" | sed -n 1p | grep -qv Connected
}

function poll_until_connected () {
    let loops=0 || true
    let max_loops=200 # 200 * 0.1 is 20 seconds

    while isnt_connected "$VPN"; do
        sleep 0.1
        let loops=$loops+1
        [ $loops -gt $max_loops ] && break
    done

    [ $loops -le $max_loops ]
}

networksetup -connectpppoeservice "$VPN"

if poll_until_connected "$VPN"; then
    echo "Connected to $VPN!"
else
    echo "Couldn't connect to $VPN"
    scutil --nc stop "$VPN"
    exit 1
fi
