#! /bin/bash

# Usage:
# ./eap_client.sh wlan1 was-enterprise "test@icicles.com" "Password123!"

INTERFACE=$1
SSID=$2
IDENTITY=$3
PASSWORD=$4

sudo bash -c "wpa_supplicant -i $INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"

  scan_ssid=1
  key_mgmt=WPA-EAP
  identity=\"$IDENTITY\"
  password=\"$PASSWORD\"
  eap=PEAP
  phase1=\"peaplabel=0\"
  phase2=\"auth=MSCHAPV2\"
}
EOF)"
