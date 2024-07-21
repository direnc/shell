#!/usr/bin/env bash

# import env variables from .env
set -a
source .env
  
  # Generate a random URL-safe password
RANDOM_PW=$(openssl rand -base64 12 | tr '+/' '-_')

# save the current date and time to a variable
#CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

CURRENT_DATE=$(date +%s)

# list the current directory and pipe the output to a file
ls -l > "$CURRENT_DATE".txt


# time zone
readlink /etc/localtime > timezone.txt

# local time
# zdump /etc/localtime


