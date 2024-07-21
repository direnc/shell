#!/usr/bin/env bash

# start by adding the script name 
SCRIPT_NAME="geolocation"
PYTHON_IS_USED=true


# if .env is not found, exit
if [ ! -f .env ]; then
  echo "❌ Error: .env file not found."
  exit 1
fi

# import env variables from .env
set -a
source .env

# if logger is not found, exit
if [ ! -f utils/logger.sh ]; then
  echo "❌ Error: utils/logger.sh not found."
  exit 1
fi

# import logger
source utils/logger.sh 

# if python is used, check if it is installed
if [ "$PYTHON_IS_USED" = true ]; then
  if ! command -v python3 &> /dev/null
  then
      log_error "Python3 is not installed."
      echo "❌ Error: Python3 is not installed."
      exit 1
  fi
fi 

# if curl is not installed, exit
if ! command -v curl &> /dev/null
then
    log_error "Curl is not installed. Exiting"
    echo "❌ Error: This app can not be run in this environment. Curl is not installed."
    exit 1
fi

# start a virtual environment if it is not already started

# Activate virtual environment if it exists
if [ -d "venv" ]; then
  log_info "Activating virtual environment | $SCRIPT_NAME"
  source venv/bin/activate
fi


log_start "Starting the script for  $SCRIPT_NAME   "

# code starts here  
# 

print_geolocation_info() {
  local external_ip=$(curl -s ifconfig.me)
  local geolocation_info=$(python3 - << END
import requests
import json

ip = "$external_ip"
url = f"https://ipinfo.io/{ip}/json"
response = requests.get(url)
data = response.json()

print(json.dumps(data, indent=2))
END
)

  echo $geolocation_info

}

# deactivating the virtual environment
if [ -d "venv" ]; then
  log_info "Deactivating virtual environment | $SCRIPT_NAME"
  deactivate
fi

# 
# code ends here

log_end "Ending the script for $SCRIPT_NAME  "