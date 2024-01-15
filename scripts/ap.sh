#! /bin/bash

echo -e $INFO ./scripts/ap.sh

# Set AP ip address
sudo ip -n $NETNS link set $IN_INTERFACE up
sudo ip -n $NETNS addr add $LISTEN_ADDRESS/$CIDR dev $IN_INTERFACE
echo -e "$INFO Set interface $IN_INTERFACE up:"
sudo ip -n $NETNS --color=always a s $IN_INTERFACE

# Run dnsmasq with parameters
sudo ip netns exec $NETNS bash -c "dnsmasq --conf-file=<(cat << EOF
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
EOF
) -d" 2>&1 | while read line; do echo -e "$DNSMASQ $line"; done &
echo -e "$INFO Started dnsmasq"
