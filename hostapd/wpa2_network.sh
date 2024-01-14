#! /bin/bash

SSID=was-wpa2                        #
CHANNEL=1                            #
HW_MODE=g                            #
WPA_PASSPHRASE=password              #

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
EOF)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(wpa_passphrase $SSID $WPA_PASSPHRASE)" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
