#! /bin/bash

sudo bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WPA2 PSK with CCMP
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=$WPA_PASSPHRASE
EOF)" &

sudo bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(wpa_passphrase $SSID $WPA_PASSPHRASE)" | grep -v "kernel reports" &
