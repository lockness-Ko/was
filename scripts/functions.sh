#! /bin/bash

DNSMASQ="\x1b[1;44m[DNSMASQ]\x1b[0m"
WPA_SUPPLICANT="\x1b[1;41m[CLIENT]\x1b[0m"
HOSTAPD="\x1b[1;42m[HOSTAPD]\x1b[0m"
INFO="\x1b[1;36m[WAS - Info]\x1b[0m"
WARN="\x1b[1;33m[WAS - Warn]\x1b[0m"
ERR="\x1b[1;31m[WAS - Err]\x1b[0m"

echo -e $INFO ./scripts/functions.sh

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

ctrlc() {
  echo -e "$INFO Cleaning up..."
  sudo rmmod mac80211_hwsim
  sudo ip netns del $NETNS
  sudo ip netns del $CLIENT_NETNS
  exit $1
}

INTERFACES=$(sudo airmon-ng | grep mac80211_hwsim| awk -F ' ' '{print $2}')
PHYS=$(sudo airmon-ng | grep mac80211_hwsim| awk -F ' ' '{print $1}')

# Randomize mac addresses
echo $INTERFACES | tr ' ' '\n' | while read line; do
	echo -e $INFO Randomizing $line mac address
	sudo ip link set $line down
	sudo macchanger -r $line
	sudo ip link set $line up
done

get_interface() {
	echo $INTERFACES | tr ' ' '\n' | head -n $1 | tail -n 1
}

get_phy() {
	echo $PHYS | tr ' ' '\n' | head -n $1 | tail -n 1
}
