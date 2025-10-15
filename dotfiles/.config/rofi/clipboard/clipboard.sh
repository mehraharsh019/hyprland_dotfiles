#!/usr/bin/env bash

## Rofi Clipboard Manager using cliphist
## Supports text and images from clipboard history

# Current Theme
dir="$HOME/.config/rofi/clipboard"
theme='style'

# Check if cliphist is installed
if ! command -v cliphist &> /dev/null; then
    rofi -e "cliphist is not installed!" -theme "${dir}/${theme}.rasi"
    exit 1
fi

# Get clipboard history
clip_list=$(cliphist list)
clip_count=$(echo "$clip_list" | wc -l)

# Check if history is empty
if [[ $clip_count -eq 0 ]]; then
    rofi -e "No entries in clipboard history" -theme "${dir}/${theme}.rasi"
    exit 0
fi

# Prepare menu with Clear History option
menu_items="🧹 Clear History\n$clip_list"

# Rofi CMD with mouse support
selected=$(echo -e "$menu_items" | rofi -dmenu \
    -i \
    -p "Clipboard Manager" \
    -mesg "$clip_count items in history | Left Click: Copy | Alt+d: Delete" \
    -theme "${dir}/${theme}.rasi" \
    -kb-custom-1 "Alt+d" \
    -me-select-entry "" \
    -me-accept-entry "MousePrimary" \
    -me-accept-custom "MouseSecondary")

exit_code=$?

# Handle Clear History selection
if [[ "$selected" == "🧹 Clear History" ]]; then
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu \
        -p "Clear all clipboard history?" \
        -theme "${dir}/${theme}.rasi" \
        -theme-str 'window {width: 300px;}')
    
    if [[ "$confirm" == "Yes" ]]; then
        cliphist wipe
        notify-send "Clipboard" "History cleared" -i edit-clear
    fi
    exit 0
fi

# Handle rofi exit codes
case $exit_code in
    0)  # Normal selection (Enter/Left Click)
        if [[ -n "$selected" ]]; then
            # Copy selected item to clipboard
            echo "$selected" | cliphist decode | wl-copy
            notify-send "Clipboard" "Copied to clipboard" -i edit-copy
        fi
        ;;
    10) # Alt+d (custom-