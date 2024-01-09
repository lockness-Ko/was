#! /bin/bash

sudo bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WEP network
auth_algs=1
wep_default_key=0
wep_key0=badbeefcaf
EOF)" &

sudo bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"

  key_mgmt=NONE
  wep_tx_keyidx=0
  wep_key0=badbeefcaf
}
EOF)" | grep -v "kernel reports" &
