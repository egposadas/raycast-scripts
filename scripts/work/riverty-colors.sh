#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Riverty Colors
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎨
# @raycast.packageName Design
# @raycast.argument1 { "type": "dropdown", "placeholder": "Color", "data": [{"title": "Vanguard", "value": "Vanguard"}, {"title": "Charcoal", "value": "Charcoal"}, {"title": "Haze", "value": "Haze"}, {"title": "Ember", "value": "Ember"}]}
# @raycast.argument2 { "type": "dropdown", "placeholder": "Opacity", "data": [{"title": "100%", "value": "100%"}, {"title": "70%", "value": "70%"}, {"title": "30%", "value": "30%"}], "optional": true}
# @raycast.argument3 { "type": "dropdown", "placeholder": "Format", "data": [{"title": "Hex", "value": "hex"}, {"title": "RGB", "value": "rgb"}, {"title": "RGBA", "value": "rgba"}], "optional": true}

# Documentation:
# @raycast.description Copy a Riverty brand color (hex / RGB / RGBA) to the clipboard
# @raycast.author egposadas
# @raycast.authorURL https://github.com/egposadas

color_name="$1"
opacity="${2:-100%}"
format="${3:-hex}"
hex_code=""

case "$color_name" in
    "Vanguard")
        case "$opacity" in
            "70%") hex_code="#86A27B" ;;
            "30%") hex_code="#CBD7C6" ;;
            *) hex_code="#527A42" ;;
        esac
        ;;
    "Charcoal")
        case "$opacity" in
            "70%") hex_code="#686868" ;;
            "30%") hex_code="#C9C9C9" ;;
            *) hex_code="#282828" ;;
        esac
        ;;
    "Haze")
        case "$opacity" in
            "70%") hex_code="#ECE9E7" ;;
            "30%") hex_code="#F3F1F0" ;;
            *) hex_code="#E7E4E2" ;;
        esac
        ;;
    "Ember")
        case "$opacity" in
            "70%") hex_code="#F49B97" ;;
            "30%") hex_code="#F9C6C4" ;;
            *) hex_code="#EF706B" ;;
        esac
        ;;
    *)
        echo "Unknown color: ${color_name:-<empty>}"
        exit 1
        ;;
esac

hex_to_rgb() {
  local hex="${1#\#}"
  printf '%d %d %d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

opacity_alpha() {
  case "$1" in
    "70%") printf '0.7' ;;
    "30%") printf '0.3' ;;
    *) printf '1' ;;
  esac
}

output=""
case "$format" in
  rgb)
    read -r r g b <<< "$(hex_to_rgb "$hex_code")"
    output="rgb(${r}, ${g}, ${b})"
    ;;
  rgba)
    read -r r g b <<< "$(hex_to_rgb "$hex_code")"
    # Use the selected swatch hex (already baked for 70%/30%), alpha from opacity label.
    a=$(opacity_alpha "$opacity")
    output="rgba(${r}, ${g}, ${b}, ${a})"
    ;;
  *)
    output="$hex_code"
    ;;
esac

printf '%s' "$output" | pbcopy
echo "Copied $output to clipboard"
