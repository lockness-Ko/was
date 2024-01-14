#! /bin/bash

SSID=was-open                        #
CHANNEL=1                            #
HW_MODE=g                            #

sudo bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# Open WiFi network
wpa=0
EOF)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"
  key_mgmt=NONE
}
EOF)" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
