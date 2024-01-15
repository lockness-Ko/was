#! /bin/bash

SSID=was-wps                         #
CHANNEL=1                            #
HW_MODE=g                            #
WPA_PASSPHRASE=password              #

sudo ip netns exec $NETNS bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WPA2 PSK with CCMP
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_passphrase=$WPA_PASSPHRASE


wps_state=2
ap_setup_locked=0
wps_pin_requests=/var/run/hostapd_wps_pin_requests
device_name=QCA Access Point
manufacturer=Qualcomm Atheros
device_type=6-0050F204-1
config_methods=virtual_push_button physical_push_button label keypad virtual_display
pbc_in_m1=1
ap_pin=12345670
#upnp_iface=br-lan
eap_server=1
EOF
)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo ip netns exec $CLIENT_NETNS bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(wpa_passphrase $SSID $WPA_PASSPHRASE)" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
