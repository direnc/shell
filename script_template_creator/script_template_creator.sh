#!/usr/bin/env bash

# ask user the name of the script 
echo "Enter the name of the script: "
read script_name

# create a new script file
touch $script_name.sh

# open the script file in the default text editor
open $script_name.sh

# give the script file execute permission
chmod +x $script_name.sh

# write the shebang line in the script file
echo "#!/usr/bin/env bash" > $script_name.sh

# ask the user if the script needs to use .env file
echo "Does the script need to use .env file? (y/n)"
read use_env

# if user wants to use .env file
if [ $use_env == "y" ]; then
  # create a new .env file
  touch .env

  # open the .env file in the default text editor
  open .env

  # write the .env file check in the script file
  echo "# if .env is not found, exit" >> $script_name.sh
  echo "if [ ! -f .env ]; then" >> $script_name.sh
  echo "  echo \"❌ Error: .env file not found.\"" >> $script_name.sh
  echo "  exit 1" >> $script_name.sh
  echo "fi" >> $script_name.sh

  # ask the user if user wants to add any env variables now
  echo "Do you want to add one env variable now? (y/n)"
  read add_env

  # if user wants to add env variables
  if [ $add_env == "y" ]; then
    # ask the user the name of the env variable
    echo "Enter the name of the env variable: "
    read env_name

    # ask the user the value of the env variable
    echo "Enter the value of the env variable: "
    read env_value 
    
    # write the env variable in the .env file
    echo "$env_name=$env_value" >> .env
  fi

  # write the .env file import in the script file
  echo "# import env variables from .env" >> $script_name.sh
  echo "set -a" >> $script_name.sh
  echo "source .env" >> $script_name.sh
fi

# open the script file in the default text editor
open $script_name.sh

# give the script file execute permission
chmod +x $script_name.sh

# notify the user that the script has been created
echo "Script $script_name.sh has been created."


