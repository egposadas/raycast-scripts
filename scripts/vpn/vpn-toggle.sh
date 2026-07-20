#!/bin/bash

# Required parameters:
# DEACTIVATED — moved to a Raycast extension; uncomment to re-enable as a Script Command
# # @raycast.schemaVersion 1
# # @raycast.title Azure VPN - toggle
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ../images/azure-vpn.png
# @raycast.packageName VPN

# Documentation:
# @raycast.description Toggle Azure VPN (rty-dna) connection on/off
# @raycast.author egposadas
# @raycast.authorURL https://github.com/egposadas


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/vpn-config.sh"
VPN=$VPN_NAME

vpn_require

status=$(vpn_status)

if [ "$status" == "Connected" ]; then
    scutil --nc stop "$VPN"
    # Brief wait so status reflects disconnect
    sleep 0.5
    if [ "$(vpn_status)" == "Connected" ]; then
        echo "⚠️ Couldn't disconnect from $VPN"
        exit 1
    fi
    echo "❌ Disconnected from $VPN!"
    exit 0
fi

function isnt_connected () {
    vpn_status | grep -qv Connected
}

function poll_until_connected () {
    local loops=0
    local max_loops=200 # 200 * 0.1 is 20 seconds

    while isnt_connected; do
        sleep 0.1
        loops=$((loops + 1))
        [ $loops -gt $max_loops ] && break
    done

    [ $loops -le $max_loops ]
}

scutil --nc start "$VPN"

if poll_until_connected; then
    echo "✅ Connected to $VPN!"
else
    echo "⚠️ Couldn't connect to $VPN"
    scutil --nc stop "$VPN"
    exit 1
fi
