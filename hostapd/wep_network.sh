#! /bin/bash

SSID=was-wep                         #
CHANNEL=1                            #
HW_MODE=g                            #

sudo ip netns exec $NETNS bash -c "/opt/hostap/hostapd/hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WEP network
auth_algs=2
wep_default_key=0
wep_key0=badbeefcaf
EOF
)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo ip netns exec $CLIENT_NETNS bash -c "/opt/hostap/wpa_supplicant/wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"

  key_mgmt=NONE
  wep_tx_keyidx=0
  wep_key0=badbeefcaf
}
EOF
)" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
