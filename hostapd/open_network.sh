#! /bin/bash

sudo bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# Open WiFi network
wpa=0
EOF)" &

sudo bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"
  key_mgmt=NONE
}
EOF)" | grep -v "kernel reports" &
