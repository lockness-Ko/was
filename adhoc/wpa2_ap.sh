#! /bin/bash

# Usage:
# ./wpa2_ap.sh <interface> <ssid> <channel> <password>
#
# e.g.
# ./wpa2_ap.sh wlan1 was-enterprise 11 g Password123

SSID=$2                  #
CHANNEL=$3                           #
HW_MODE=$4                            #
IN_INTERFACE=$1
WPA_PASSPHRASE=$5

sudo bash -c "hostapd-mana <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WPA2 PSK with CCMP
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_passphrase=$WPA_PASSPHRASE

mana_wpaout=./mana.credout
EOF
)"
