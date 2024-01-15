#! /bin/bash


echo -e "$INFO Welcome to Wi-Fi Attack Sim v0.1.0!"

# Load mac80211_hwsim
echo -e "$INFO Checking for mac80211_hwsim presence"
sudo lsmod | grep "mac80211_hwsim" && echo -n || bash -c "echo -e \"$WARN mac80211_hwsim not loaded. Loading...\"; sudo modprobe mac80211_hwsim radios=5"
echo -e "$INFO Loaded mac80211_hwsim"

. ./scripts/functions.sh
trap 'error ${LINENO}' ERR
trap 'ctrlc 0' INT
. ./scripts/config.sh
. ./scripts/ap.sh
. ./scripts/simulation.sh

# Hang forever
sleep 0.5
echo -e "$INFO Use $ATTACK_INTERFACE1 and $ATTACK_INTERFACE2 as your attacker mode interface"
echo -e "$INFO Press Ctrl+C to quit"
tail -f /dev/null
