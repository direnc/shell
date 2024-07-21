#!/usr/bin/env bash

SCRIPT_NAME="system_info.command"
JSON_OUTPUT_FILE="system_info.json"

# Check if .env is found, exit if not
if [ ! -f .env ]; then
  echo "❌ Error: .env file not found."
  exit 1
fi

# Import env variables from .env
set -a
source .env

# Check if logger is found, exit if not
if [ ! -f utils/logger.sh ]; then
  echo "❌ Error: utils/logger.sh not found. | $SCRIPT_NAME"
  exit 1
fi

# Import logger
source utils/logger.sh

# Check if spinner is found, exit if not
if [ ! -f utils/spinner.sh ]; then
  log_error "utils/spinner.sh not found. Exiting."
  echo "❌ Error: utils/spinner.sh not found."
  exit 1
fi

# Import spinner
source utils/spinner.sh

# import geolocation

if [ ! -f utils/geolocation.command ]; then
  log_error "utils/geolocation.command not found. Exiting."
  echo "❌ Error: utils/geolocation.command not found."
  exit 1
fi

source utils/geolocation.command

log_start "Starting the script for $SCRIPT_NAME"

# Function to gather system information
gather_system_info() {
  log_debug "Gathering system information..."
  local user=$(whoami)

  # detailed user information (running on MacOs)
  if command -v id &> /dev/null; then
    # save the user information compatible with JSON format, provide at least 5 properties 
    local user_info=$(id -Gn $user | awk '{print "{ \"groups\": \"" $0 "\", \"uid\": \"" $1 "\", \"gid\": \"" $2 "\", \"home\": \"" $3 "\", \"shell\": \"" $4 "\" }"}')
  else
    local user_info="User information not available"
  fi

  local geolocation_info=$(print_geolocation_info)

  local hostname=$(hostname)
  
  # important paths in the system
  local paths=$(echo "{ \"home\": \"$HOME\", \"temp\": \"$TMPDIR\", \"log\": \"$LOG_DIR\" }")

  local timezone=$(date +'%Z %z')


  local os=$(uname -s)
  local kernel=$(uname -r)
  local architecture=$(uname -m)
  local uptime=$(uptime | awk -F, '{print $1}' | awk '{print $3,$4}')
  local shell=$(echo $SHELL)
  local cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "CPU information not available")
  local total_mem=$(sysctl -n hw.memsize 2>/dev/null | awk '{print $1/1024/1024 " MB"}' || echo "Memory information not available")
  local current_time=$(date)

  # Disk usage information
  local disk_usage=$(df -h | grep "^/" | awk '{print "{ \"mount\": \"" $6 "\", \"usage\": \"" $5 "\" }"}' | tr '\n' ',' | sed 's/,$//')

  # Installed packages
  if command -v dpkg &> /dev/null; then
    local installed_packages=$(dpkg -l | awk '{print "\"" $2 "\""}' | grep -v "^\"lib" | tr '\n' ',' | sed 's/,$//')
  elif command -v brew &> /dev/null; then
    local installed_packages=$(brew list | awk '{print "\"" $1 "\""}' | tr '\n' ',' | sed 's/,$//')
  else
    local installed_packages="\"Package information not available\""
  fi

  # Installed packages count
  local package_count=$(echo $installed_packages | tr -cd ',' | wc -c)
  package_count=$((package_count + 1))

  # Installed software versions
  local bash_version=$(bash --version | head -n 1 | awk '{print $4}')
  local git_version=$(git --version | awk '{print $3}')
  local docker_version=$(docker --version 2>/dev/null | awk '{print $3}')
  local python_version=$(python3 --version 2>/dev/null | awk '{print $2}')
  local node_version=$(node --version 2>/dev/null || echo "Node not installed")
  local npm_version=$(npm --version 2>/dev/null || echo "NPM not installed")

  # Network information
  local network_info=$(ifconfig | awk '/^[a-z]/ { iface=$1 } $1 == "inet" { print "{ \"interface\": \"" iface "\", \"ip\": \"" $2 "\" }" }' | tr '\n' ',' | sed 's/,$//')
  local external_ip=$(curl -s https://api.ipify.org)


  # Remaining disk space 
  local remaining_disk_space=$(df -h / | awk 'NR==2 {print $4}')

  # Potentially running processes in port 3000
  local processes_in_port_3000=$(lsof -i :3000 | awk 'NR>1 {print "{ \"user\": \"" $3 "\", \"pid\": \"" $2 "\", \"command\": \"" $1 "\" }"}' | tr '\n' ',' | sed 's/,$//')
  
  # check if internet is available and assign this to a variable
  local internet_status=$(curl -s -I www.google.com | head -n 1 | grep "HTTP/1.1" | awk '{print $2}')
 
  # check if postgres is running, assign status to a variable in quotes
  local postgres_status=$(pg_isready | awk '{print "{ \"status\": \"" $3 "\" }"}' | tr '\n' ',' | sed 's/,$//')

  # other potential information to gather

  # check if the system is running on a virtual machine
  local virtual_machine=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}' | grep -i "virtual" || echo "Not a virtual machine")

  

  # show a summary of the gathered information
  echo '{
    "user": "'$user'",
    "user_info": ['"$user_info"'],
    "geolocation_info": ['"$geolocation_info"'],
    "hostname": "'$hostname'",
    "paths": ['"$paths"'],
    "timezone": "'$timezone'",
    "os": "'$os'",
    "kernel": "'$kernel'",
    "architecture": "'$architecture'",
    "uptime": "'$uptime'",
    "shell": "'$shell'",
    "cpu": "'$cpu'",
    "total_mem": "'$total_mem'",
    "current_time": "'$current_time'",
    "disk_usage": ['"$disk_usage"'],
    "package_count": "'$package_count'",
    "bash_version": "'$bash_version'",
    "git_version": "'$git_version'",
    "docker_version": "'$docker_version'",
    "python_version": "'$python_version'",
    "node_version": "'$node_version'",
    "npm_version": "'$npm_version'",
    "network_info": ['"$network_info"'],
    "external_ip": "'$external_ip'",
    "remaining_disk_space": "'$remaining_disk_space'",
    "processes_in_port_3000": ['"$processes_in_port_3000"'],
    "internet_status": "'$internet_status'",
    "postgres_status": ['"$postgres_status"'],
    "virtual_machine": "'$virtual_machine'"
}
'
}

# Function to save JSON output to file
save_json_to_file() {
  local json_content=$1
  echo "$json_content" > "$JSON_OUTPUT_FILE"
  log_info "System information saved to $JSON_OUTPUT_FILE"
}

# Show spinner while gathering system information
gather_system_info & pid=$!
spinner $pid

# Capture the JSON output
system_info_json=$(gather_system_info)

# Save the JSON output to a file
save_json_to_file "$system_info_json"

# Display a user-friendly message
echo "✅ System information has been gathered and saved to $JSON_OUTPUT_FILE"

log_end "Ending the script for $SCRIPT_NAME"


  # check for potential system updates on Mac Os
  #if command -v softwareupdate &> /dev/null; then
    # grep the last line of the output to get the system update information
    #local system_updates=$(softwareupdate -l | tail -n 1)
  #else
    #local system_updates="System update information not available"
  #fi


  # Running processes
  #local running_processes=$(ps aux --sort=-%mem | awk 'NR<=10 {print "{ \"user\": \"" $1 "\", \"pid\": \"" $2 "\", \"cpu\": \"" $3 "\", \"mem\": \"" $4 "\", \"command\": \"" $11 "\" }"}' | tr '\n' ',' | sed 's/,$//')

  # Open ports
  #local open_ports=$(ss -tuln | awk 'NR>1 {print "{ \"proto\": \"" $1 "\", \"local_address\": \"" $4 "\", \"foreign_address\": \"" $5 "\", \"state\": \"" $1 "\" }"}' | tr '\n' ',' | sed 's/,$//')

  # Environment variables
  #local env_vars=$(env | awk -F= '{print "{ \"" $1 "\": \"" $2 "\" }"}' | tr '\n' ',' | sed 's/,$//')



  # various API systems for geolocation
  #local location=$(curl -s https://ipapi.co/json/)
  #local location=$(curl -s https://ipinfo.io/)
  #local location=$(curl -s https://freegeoip.app/json/)


