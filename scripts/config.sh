#! /bin/bash

echo -e $INFO ./scripts/config.sh

#################
# CONFIGURATION #
######################################
                                     #
IN_INTERFACE=$(get_interface 3)      # Don't touch the interface settings :)
CLIENT_INTERFACE=$(get_interface 4)  #
ATTACK_INTERFACE1=$(get_interface 1) #
ATTACK_INTERFACE2=$(get_interface 2) #
                                     #
NETNS=was-ns			     #
CLIENT_NETNS=was-client              #
				     #
LISTEN_ADDRESS=10.0.0.1              #
CIDR=24                              #
DHCP_RANGE=10.0.0.100,10.0.0.199,12h #
DHCP_LEASE_TIME=100                  #
DNS_SERVER=10.0.0.1                  #
                                     #
######################################

# Create the namespace
sudo ip netns del $NETNS &>/dev/null && echo -e $INFO Deleted $NETNS || echo -e $WARN Unable to delete $NETNS;
sudo ip netns add $NETNS
sudo ip netns del $CLIENT_NETNS &>/dev/null && echo -e $INFO Deleted $CLIENT_NETNS || echo -e $WARN Unable to delete $CLIENT_NETNS;
sudo ip netns add $CLIENT_NETNS

# Add client and ap interfaces to the namespace
sudo iw phy $(get_phy 3) set netns name /run/netns/$NETNS
sudo iw phy $(get_phy 4) set netns name /run/netns/$CLIENT_NETNS
