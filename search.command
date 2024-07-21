#!/usr/bin/env bash

# import env variables from .env
set -a
source .env
source utils/spinner.sh

# ask the user for a search term
read -p "Enter a search term: " SEARCH_TERM

# search for the term in "~" and its subdirectories, and save the output to a file
#grep -r "$SEARCH_TERM" ~ > search_results.txt


# Ensure sudo password is asked
sudo -v

# search for the term  in "~" and its subdirectories FILE NAMES, and save the output to a file

# Start the search in the background
(sudo find ~ -type f -name "*$SEARCH_TERM*" -exec echo "[PID $$] {}" \; > search_results.txt) &

# Get the PID of the search process
search_pid=$!

# Echo the PID to the user
echo "Search process in the background has started with PID: $search_pid"

# Guide the user to stop the search process if needed, that will be achieved by killing the process
echo "To stop the search process, run: kill $search_pid"

# Show the spinner while the search is running
spinner $search_pid

# when the background search process is done, notify the user
echo "✅ Search for $SEARCH_TERM is running in the background and the results are saving in search_results.txt"