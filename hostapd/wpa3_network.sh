#! /bin/bash

sudo bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WPA3 PSK with CCMP
wpa=2
wpa_key_mgmt=SAE
rsn_pairwise=CCMP
wpa_passphrase=$WPA_PASSPHRASE
EOF)" &

sudo bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"

  key_mgmt=SAE
  sae_password=\"$WPA_PASSPHRASE\"
}
EOF)" | grep -v "kernel reports" &
