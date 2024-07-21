#!/usr/bin/env bash

# Array of spinner characters
SPINNER=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )

# Array of colors
COLORS=( "\033[31m" "\033[32m" "\033[33m" "\033[34m" "\033[35m" "\033[36m" )

# Function to display a spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinpos=0
    local colorpos=0
    while [ -d /proc/$pid ]; do
        echo -ne "${COLORS[$colorpos]}${SPINNER[$spinpos]}\033[0m"  # Print spinner with color
        spinpos=$(( (spinpos + 1) % ${#SPINNER[@]} ))
        colorpos=$(( (colorpos + 1) % ${#COLORS[@]} ))
        sleep $delay
        echo -ne "\r"  # Return to the beginning of the line
    done
    echo -ne "\r\033[K"  # Clear the line
}
