#!/usr/bin/env bash

# Name of your VPN as shown by: scutil --nc list
export VPN_NAME="rty-dna"

if [ -z "$VPN_NAME" ]; then
  echo "\$VPN_NAME is empty"
  echo "Please, rename it in \"vpn-config.sh\"."
  exit 1
fi

vpn_status() {
  scutil --nc status "$VPN_NAME" 2>/dev/null | sed -n 1p
}

vpn_exists() {
  scutil --nc list 2>/dev/null | grep -Fq "\"$VPN_NAME\""
}

vpn_require() {
  if ! vpn_exists; then
    echo "VPN \"$VPN_NAME\" not found. Check Azure VPN Client / scutil --nc list"
    exit 1
  fi
}
