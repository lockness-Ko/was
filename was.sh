#! /bin/bash

DNSMASQ="\x1b[1;44m[DNSMASQ]\x1b[0m"
WPA_SUPPLICANT="\x1b[1;41m[CLIENT]\x1b[0m"
HOSTAPD="\x1b[1;42m[HOSTAPD]\x1b[0m"
INFO="\x1b[1;36m[WAS - Info]\x1b[0m"
WARN="\x1b[1;33m[WAS - Warn]\x1b[0m"
ERR="\x1b[1;31m[WAS - Err]\x1b[0m"

echo -e "$INFO Welcome to Wi-Fi Attack Sim v0.0.1!"

# Set Ctrl+C and error handler
error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo -e "$ERR Error line ${parent_lineno}: ${message}; with status ${code}"
  else
    echo -e "$ERR Error line ${parent_lineno}; with status ${code}"
  fi
  ctrlc $code
  exit "${code}"
}
trap 'error ${LINENO}' ERR

ctrlc() {
  echo -e "$INFO Cleaning up..."
  sudo rmmod mac80211_hwsim
  exit $1
}
trap 'ctrlc 0' INT

# Load mac80211_hwsim
echo -e "$INFO Checking for mac80211_hwsim presence"
sudo lsmod | grep "mac80211_hwsim" && echo -n || bash -c "echo -e \"$WARN mac80211_hwsim not loaded. Loading...\"; sudo modprobe mac80211_hwsim radios=4"
echo -e "$INFO Loaded mac80211_hwsim"

#################
# CONFIGURATION #
######################################
                                     #
IN_INTERFACE=wlan0                   #
CLIENT_INTERFACE=wlan1               #
ATTACK_INTERFACE=wlan2               #
SSID=SusCorp                         #
CHANNEL=1                            #
HW_MODE=g                            #
WPA_PASSPHRASE=password              #
                                     #
LISTEN_ADDRESS=10.0.0.1              #
CIDR=24                              #
DHCP_RANGE=10.0.0.100,10.0.0.199,12h #
DHCP_LEASE_TIME=100                  #
DNS_SERVER=10.0.0.1                  #
                                     #
######################################

# Randomize mac addresses
sudo ip link set $IN_INTERFACE down
sudo macchanger -r $IN_INTERFACE
sudo ip link set $IN_INTERFACE up

sudo ip link set $CLIENT_INTERFACE down
sudo macchanger -r $CLIENT_INTERFACE
sudo ip link set $CLIENT_INTERFACE up

sudo ip link set $ATTACK_INTERFACE down
sudo macchanger -r $ATTACK_INTERFACE
sudo ip link set $ATTACK_INTERFACE up

# Set AP ip address
sudo ip link set $IN_INTERFACE up
sudo ip addr add $LISTEN_ADDRESS/$CIDR dev $IN_INTERFACE
echo -e "$INFO Set interface $IN_INTERFACE up:"
ip --color=always a s $IN_INTERFACE

# Run hostapd with parameters
. ./hostapd/$1.sh 2>/dev/null
echo -e "$INFO Started hostapd with config: $1"

# Run dnsmasq with parameters
sudo bash -c "dnsmasq --conf-file=<(cat << EOF
domain-needed
bogus-priv
no-resolv
filterwin2k
expand-hosts
domain=localdomain
local=/localdomain/
listen-address=$LISTEN_ADDRESS
dhcp-range=$DHCP_RANGE
dhcp-lease-max=$DHCP_LEASE_TIME
dhcp-option=option:router,$LISTEN_ADDRESS
dhcp-authoritative
server=$DNS_SERVER
EOF) -d" 2>&1 | while read line; do echo -e "$DNSMASQ $line"; done &
echo -e "$INFO Started dnsmasq"

# Hang forever
sleep 0.5
echo -e "$INFO Use wlan2 as your attacker mode interface"
echo -e "$INFO First, wait til $CLIENT_INTERFACE is up with the 'ip a s $CLIENT_INTERFACE'"
echo -e "$INFO Press Ctrl+C to quit"
tail -f /dev/null
