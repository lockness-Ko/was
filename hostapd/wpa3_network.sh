#! /bin/bash

SSID=was-wpa3                        #
CHANNEL=1                            #
HW_MODE=g                            #
WPA_PASSPHRASE=password              #

sudo ip netns exec $NETNS bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WPA3 PSK with CCMP
wpa=2
wpa_key_mgmt=SAE
rsn_pairwise=CCMP
wpa_passphrase=$WPA_PASSPHRASE
EOF
)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo ip netns exec $CLIENT_NETNS bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"

  key_mgmt=SAE
  sae_password=\"$WPA_PASSPHRASE\"
}
EOF
)" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
