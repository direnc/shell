#!/usr/bin/env bash

# if .env is not found, exit
if [ ! -f .env ]; then
  log_error ".env file not found. Exiting."
  echo "❌ Error: .env file not found."
  exit 1
fi

# Import env variables from .env
set -a
source .env

# if spinner is not found, exit
if [ ! -f utils/spinner.sh ]; then
  log_error "utils/spinner.sh not found. Exiting."
  echo "❌ Error: spinner.sh not found."
  exit 1
fi

# Import the spinner function
source utils/spinner.sh

# if logger is not found, exit
if [ ! -f utils/logger.sh ]; then
  echo "❌ Error: utils/logger.sh not found."
  exit 1
fi

# import logger
source utils/logger.sh



# Echo a welcome message
echo "📚 Welcome to the Manual Creator! 📚"

# start the logfile 
log_info "= = = = = = = = => A new process for Manual Creator has started."

# debug 
log_debug "Now running manual_creator.command" || echo "Logging is disabled. Enable it in .env to create logs."

# Ask the user for the command that the manual is going to be generated for
log_debug "Asking user for the command"
read -p "For which command do you need a manual? " COMMAND

# Check if the command exists
if ! command -v $COMMAND &> /dev/null; then
  log_error "$COMMAND does not exist. Exiting."
  echo "❌ Error: $COMMAND does not exist."
  exit 1
fi

# Check if the manuals folder exists, if not create it
if [ ! -d "manuals" ]; then
  log_debug "Creating manuals folder"
  mkdir manuals
fi

# Capture the output of the man command, including any error messages
log_debug "Capturing the output of the man command"
MAN_OUTPUT=$(man $COMMAND 2>&1 | col -b)

# Check if the output contains "No manual entry"
if [[ "$MAN_OUTPUT" == *"No manual entry"* ]]; then
  log_error "No manual exists for $COMMAND. Exiting."
  echo "❌ Error: No manual exists for $COMMAND."
  exit 1
fi

# Save the output to a file
log_debug "Saving the output to manuals/${COMMAND}.txt"
(echo "$MAN_OUTPUT" > "manuals/${COMMAND}.txt") &

# Get the PID of the manual creation process
manual_create_pid=$!
log_debug "PID of the manual creation process: $manual_create_pid"

# Show the spinner while the manual is being created
log_debug "Showing the spinner while the manual is being created"
spinner $manual_create_pid

# Check if the manual creation process has finished
echo "✅ Manual for $COMMAND has been generated and saved in manuals/${COMMAND}.txt"
log_info "Manual for $COMMAND has been generated and saved in manuals/${COMMAND}.txt"

# Get the size of the generated manual file
manual_size=$(stat -f%z "manuals/${COMMAND}.txt")
# Convert size to kB if larger than 1024 bytes
if [ "$manual_size" -ge 1024 ]; then
  manual_size_kb=$(echo "scale=2; $manual_size / 1024" | bc)
  log_info "The size of the manual for $COMMAND is ${manual_size_kb} kB."
else
  log_info "The size of the manual for $COMMAND is ${manual_size} bytes."
fi


# end the logfile
log_info "= = = = = = = = => Manual Creator process has ended."