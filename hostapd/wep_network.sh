#! /bin/bash

sudo bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WEP network
auth_algs=2
wep_default_key=0
wep_key0=badbeefcaf
EOF)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo bash -c "iw dev $CLIENT_INTERFACE connect $SSID key 0:badbeefcaf" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
