#!/usr/bin/env bash

# if .env is not found, exit
if [ ! -f .env ]; then
  echo "❌ Error: .env file not found."
  exit 1
fi

# Import env variables from .env
set -a
source .env

# Ensure the logs directory exists
LOG_DIR="logs"
mkdir -p $LOG_DIR

# Log file
LOG_FILE="$LOG_DIR/application.log"

# Use a conditional operator to set USE_LOGGER
[[ "$LOGGING_ENABLED" == "true" ]] && USE_LOGGER=true || USE_LOGGER=false

# Function to log messages
log_message() {
    local log_level=$1
    local log_emoji=$2
    local log_message=$3
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    if [ "$USE_LOGGER" == "true" ]; then
        echo "$timestamp [$log_level] $log_emoji $log_message" >> $LOG_FILE
    else
        echo "Logging is disabled. Enable it in .env to create logs."
    fi
}

# Functions for different log levels
log_info() {
    log_message "INFO." "📌" "$1"
}

log_warning() {
    log_message "WARN." "🟠" "$1"
}

log_error() {
    log_message "ERROR" "❌" "$1"
}

log_debug() {
    log_message "DEBUG" "⏺️" "$1"
}

log_start () {
    log_message "  🟢  " " " "$1"
} 

log_end () {
    log_message "  🔴  " " " "$1"
}

# Function to rotate log files
rotate_logs() {
    local max_size=1048576  # 1MB in bytes
    if [ -f $LOG_FILE ] && [ $(stat -c%s "$LOG_FILE") -ge $max_size ]; then
        mv $LOG_FILE "$LOG_FILE.$(date +"%Y%m%d%H%M%S")"
        touch $LOG_FILE
        find $LOG_DIR -type f -name "*.log.*" -mtime +7 -exec rm {} \;  # Remove logs older than 7 days
    fi
}

