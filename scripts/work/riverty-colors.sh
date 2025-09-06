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

# Documentation:
# @raycast.author "Egemen Poslu"
# @raycast.authorURL "https://github.com/egemenposlu"
# @raycast.description "Get the Riverty brand colors and copy them to the clipboard."

color_name="$1"
opacity="$2"
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
esac

echo -n "$hex_code" | pbcopy
echo "Copied $hex_code to clipboard"