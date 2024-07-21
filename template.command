#!/usr/bin/env bash

# start by adding the script name 
SCRIPT_NAME="enter_script_name_here"


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


log_start "Starting the script for  $SCRIPT_NAME   "

# code starts here  
# 












# 
# code ends here

log_end "Ending the script for $SCRIPT_NAME  "