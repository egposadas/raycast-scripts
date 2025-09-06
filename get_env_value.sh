#!/bin/bash

# Description:
# A Raycast script for quickly finding environment variables in .env files.
# Matches keys in three ways:
# 1. Abbreviations: "aak" → "AWS_ACCESS_KEY", "gpt" → "GITHUB_PAT_TOKEN"
# 2. Partial matches: "shap" → "SHAPE", "aws" → "AWS_KEY"
# 3. Fuzzy finding: "ath" → "AUTH_TOKEN"

# Matched values are copied to clipboard and printed to terminal using pbcopy (brew install pbcopy or similar)

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get Env Value
# @raycast.mode compact
# @raycast.argument1 { "type": "text", "placeholder": "Key", "required": true }

# Optional parameters:
# @raycast.icon 🤖
# @raycast.copyToClipboard true

# Documentation:
# @raycast.description Search and copy environment variables from your .env file
# @raycast.author graham_anderson
# @raycast.authorURL https://raycast.com/graham_anderson

# Dependencies:
# - fzf (Fuzzy Finder: https://github.com/junegunn/fzf)
# - pbcopy (macOS built-in utility for copying to clipboard)

# Global Debug Flag
DEBUG_MODE=false  # Set to "true" to enable debug output, "false" to disable

# Check if pbcopy is installed
if ! command -v pbcopy &> /dev/null; then
    echo "Error: 'pbcopy' is not installed. Please install it to use this script."
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "Error: 'fzf' is not installed. Please install it to use this script."
    exit 1
fi

# Path to the file containing the key-value pairs
FILE="$HOME/scripts/.env"

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Please provide a key to search for"
    exit 1
fi

# Function to get value for abbreviated key
get_abbreviated_value() {
    local search="$1"
    local debug="${2:-false}"  # Second argument is the debug flag (defaults to false)

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" ]] || [[ $line == \#* ]] && continue
        
        # Extract key (everything before the first = sign, even if quotes are present)
        key=$(echo "$line" | awk -F= '{print $1}' | tr -d ' ' | tr -d "'" | tr -d '"')
        
        # Clean the key and create abbreviation
        clean_key=$(echo "$key" | tr -d ' ')
        abbrev=$(echo "$clean_key" | awk -F'_' '{for(i=1;i<=NF;i++) printf "%s", substr($i,1,1)}' | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
        
        # Debug: Print the key and its abbreviation if debug is true
        if [[ "$debug" == "true" ]]; then
            echo "Key: $clean_key, Abbrev: $abbrev" >&2
        fi
        
        # Clean the search term (remove all non-alphanumeric characters)
        search_lower=$(echo "$search" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
        
        # Debug: Print the exact search term and abbreviation being compared
        if [[ "$debug" == "true" ]]; then
            echo "Comparing: Search Term: '$search_lower' (length: ${#search_lower}) vs Abbrev: '$abbrev' (length: ${#abbrev})" >&2
        fi
        
        if [ "$abbrev" = "$search_lower" ]; then
            # Extract value for the FULL KEY (not the abbreviation)
            value=$(echo "$line" | awk -F= '{print $2}' | tr -d "'" | tr -d '"' | tr -d ' ')
            echo "$value"
            return 0
        fi
    done < "$FILE"
    return 1
}

# Key to search for
KEY="$1"

# Step 1: Check if input is an abbreviation (all lowercase letters)
if [[ "$KEY" =~ ^[a-z]+$ ]]; then
    # Try to match the abbreviation
    ABBREV_VALUE=$(get_abbreviated_value "$KEY" $DEBUG_MODE)
    if [ -n "$ABBREV_VALUE" ]; then
        echo "$ABBREV_VALUE" | pbcopy  # Copy the value to the clipboard
        echo "$ABBREV_VALUE"           # Print the value to the terminal
        exit 0
    fi
fi

# Step 2: Check for an exact match of the full key
if grep -q -E "^[[:space:]]*${KEY}[[:space:]]*=" "$FILE"; then
    VALUE=$(grep -E "^[[:space:]]*${KEY}[[:space:]]*=" "$FILE" | awk -F= '{print $2}' | tr -d "'" | tr -d '"' | tr -d ' ')
    echo "$VALUE" | pbcopy  # Copy the value to the clipboard
    echo "$VALUE"           # Print the value to the terminal
    exit 0
fi

# Step 3: Fall back to fuzzy matching with fzf
MATCH=$(awk -F= '{print $1}' "$FILE" | fzf -q "$KEY" -1 -0)

if [ -n "$MATCH" ]; then
    VALUE=$(grep "^$MATCH=" "$FILE" | awk -F= '{print $2}')
    echo "$VALUE" | pbcopy  # Copy the value to the clipboard
    echo "$VALUE"           # Print the value to the terminal
else
    echo "No keys matching '$KEY' found."
fi