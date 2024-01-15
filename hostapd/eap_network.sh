#! /bin/bash

SSID=was-enterprise                  #
CHANNEL=11                           #
HW_MODE=g                            #

# Configure CA cert
CA_CERT_CN=AU
CA_CERT_STATE=NSW
CA_CERT_LOCALITY=Sydney
CA_CERT_ORG="Internet Widgets Pty."
CA_CERT_EMAIL=ca@internetwidgets.com.au
CA_CERT_COMMON_NAME="Certificate Authority"

CL_CERT_CN=AU
CL_CERT_STATE=NSW
CL_CERT_LOCALITY=Sydney
CL_CERT_ORG="Internet Widgets Pty."
CL_CERT_EMAIL=client@internetwidgets.com.au

SV_CERT_CN=AU
SV_CERT_STATE=NSW
SV_CERT_LOCALITY=Sydeny
SV_CERT_ORG="Internet Widgets Pty."
SV_CERT_EMAIL=admin@internetwidgets.com.au
SV_CERT_COMMON_NAME="Internet Widgets Pty."

# Create temp directory
TEMPDIR=$(mktemp -d)
cp hostapd/eap_network_certs/* $TEMPDIR

# Write to certs
sed -i "s/CA_CERT_CN/$CA_CERT_CN/;s/CA_CERT_STATE/$CA_CERT_STATE/;s/CA_CERT_LOCALITY/$CA_CERT_LOCALITY/;s/CA_CERT_ORG/$CA_CERT_ORG/;s/CA_CERT_EMAIL/$CA_CERT_EMAIL/;s/CA_CERT_COMMON_NAME/$CA_CERT_COMMON_NAME/" $TEMPDIR/ca.cnf
sed -i "s/CL_CERT_CN/$CL_CERT_CN/;s/CL_CERT_STATE/$CL_CERT_STATE/;s/CL_CERT_LOCALITY/$CL_CERT_LOCALITY/;s/CL_CERT_ORG/$CL_CERT_ORG/;s/CL_CERT_EMAIL/$CL_CERT_EMAIL/" $TEMPDIR/client.cnf
sed -i "s/SV_CERT_CN/$SV_CERT_CN/;s/SV_CERT_STATE/$SV_CERT_STATE/;s/SV_CERT_LOCALITY/$SV_CERT_LOCALITY/;s/SV_CERT_ORG/$SV_CERT_ORG/;s/SV_CERT_EMAIL/$SV_CERT_EMAIL/;s/SV_CERT_COMMON_NAME/$SV_CERT_COMMON_NAME/" $TEMPDIR/server.cnf

# Add users
cat << EOF > $TEMPDIR/hostapd.eap_user
"peter@internetwidgets.com.au" PEAP [ver=0]
"peter@internetwidgets.com.au" MSCHAPV2 "iloveyou" [2]
EOF

# Make certificates
pushd $TEMPDIR
make
popd

sudo ip netns exec $NETNS bash -c "hostapd <(cat << EOF
interface=$IN_INTERFACE
ssid=$SSID
channel=$CHANNEL

hw_mode=$HW_MODE

# WPA2 PSK with CCMP
wpa=2
wpa_key_mgmt=WPA-EAP
wpa_pairwise=CCMP TKIP

macaddr_acl=0 
auth_algs=1
own_ip_addr=127.0.0.1
ieee8021x=1
eap_server=1
eapol_version=1

eap_user_file=$TEMPDIR/hostapd.eap_user
ca_cert=$TEMPDIR/ca.pem
server_cert=$TEMPDIR/server.pem
private_key=$TEMPDIR/server.key
private_key_passwd=whatever
EOF
)" 2>&1 | while read line; do echo -e "$HOSTAPD $line"; done &

sudo ip netns exec $CLIENT_NETNS bash -c "wpa_supplicant -i $CLIENT_INTERFACE -c <(cat << EOF
network={
  ssid=\"$SSID\"

  scan_ssid=1
  key_mgmt=WPA-EAP
  identity=\"peter@internetwidgets.com.au\"
  password=\"iloveyou\"
  eap=PEAP
  phase1=\"peaplabel=0\"
  phase2=\"auth=MSCHAPV2\"
}
EOF
)" 2>&1 | while read line; do echo -e "$WPA_SUPPLICANT $line"; done | grep -v "kernel reports" &
