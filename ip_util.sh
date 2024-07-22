#!/usr/bin/env bash

function encrypt_ip {
    local IP=$1
    local NEW_IP=""

    for (( i=0; i<${#1}; i++ ))
    do
        local NEW_CHAR="${IP:$i:1}"
        
        if [ "$NEW_CHAR" == "9" ]
        then
            NEW_CHAR="#"
        elif [ "$NEW_CHAR" != "." ]
        then
            NEW_CHAR=$(expr $NEW_CHAR + 1)
        fi

        NEW_IP=$(echo "$NEW_IP$NEW_CHAR")
    done

    echo "$NEW_IP"
}

function decrypt_ip {
  local NEW_IP=""

  IP=$1

  for (( i = 0; i<${#IP}; i++ )); do
    CURRENT_CHAR=${IP:$i:1}
    NEW_CHAR=""
  
    if [ "$CURRENT_CHAR" = "." ]
    then
      NEW_CHAR=$CURRENT_CHAR
    elif [ "$CURRENT_CHAR" = "#" ]
    then
      NEW_CHAR=9
    else
      NEW_CHAR=$(expr $CURRENT_CHAR - 1)
    fi

    NEW_IP="${NEW_IP}${NEW_CHAR}"
  done

  echo "$NEW_IP"
}

function save_ip {
  echo $1 > ip.txt
  echo "[+] Saved to ip.txt"
}

MODE=$1
IP=$2

if [ "$MODE" = "-d" ]
then

  if [ "$IP" = "" ]
  then
    read -p "[?] Encoded IP: " IP
  fi

  DECRYPTED=$(decrypt_ip $IP)
  echo "[+] Result: $DECRYPTED"
elif [ "$MODE" = "-e" ]
then
  if [ "$IP" = "" ]
  then
    read -p "[?] Original IP: " IP
  fi
  
  ENCRYPTED=$(encrypt_ip $IP)
  echo "[+] Result: $ENCRYPTED"
  save_ip $ENCRYPTED
else
  echo "[!] Invalid mode provided"
  echo -e "USAGE: ./ip_util.sh <mode> <IP>\n"
  echo "Modes: "
  echo "-d     Decode the encoded IP"
  echo -e "-e     Encode the IP\n"
  echo "Example: ./ip_util.sh -e 192.168.100.24"
fi
  