#! /bin/bash

# Usage:
# ./eap_ap.sh <interface> <ssid> <channel> <hwmode> <cn> <state> <locality> <org> <ca_email> <ca_common_name> <server_email> <server_common_name>
#
# e.g.
# ./eap_ap.sh wlan1 was-enterprise 11 g AU NSW Sydney "Internet Widgets Pty." ca@internetwidgets.com.au "Certificate Authority" server@internetwidgets.com.au "Internet Widgets Pty."

SSID=$2                  #
CHANNEL=$3                           #
HW_MODE=$4                            #
IN_INTERFACE=$1

# Configure CA cert
CA_CERT_CN=$5
CA_CERT_STATE=$6
CA_CERT_LOCALITY=$7
CA_CERT_ORG=$8
CA_CERT_EMAIL=$9
CA_CERT_COMMON_NAME=$10

CL_CERT_CN=$5
CL_CERT_STATE=$6
CL_CERT_LOCALITY=$7
CL_CERT_ORG=$8
CL_CERT_EMAIL=$11

SV_CERT_CN=$5
SV_CERT_STATE=$6
SV_CERT_LOCALITY=$67
SV_CERT_ORG=$8
SV_CERT_EMAIL=$11
SV_CERT_COMMON_NAME=$12

# Create temp directory
TEMPDIR=$(mktemp -d)
cp ../hostapd/eap_network_certs/* $TEMPDIR

# Write to certs
sed -i "s/CA_CERT_CN/$CA_CERT_CN/;s/CA_CERT_STATE/$CA_CERT_STATE/;s/CA_CERT_LOCALITY/$CA_CERT_LOCALITY/;s/CA_CERT_ORG/$CA_CERT_ORG/;s/CA_CERT_EMAIL/$CA_CERT_EMAIL/;s/CA_CERT_COMMON_NAME/$CA_CERT_COMMON_NAME/" $TEMPDIR/ca.cnf
sed -i "s/CL_CERT_CN/$CL_CERT_CN/;s/CL_CERT_STATE/$CL_CERT_STATE/;s/CL_CERT_LOCALITY/$CL_CERT_LOCALITY/;s/CL_CERT_ORG/$CL_CERT_ORG/;s/CL_CERT_EMAIL/$CL_CERT_EMAIL/" $TEMPDIR/client.cnf
sed -i "s/SV_CERT_CN/$SV_CERT_CN/;s/SV_CERT_STATE/$SV_CERT_STATE/;s/SV_CERT_LOCALITY/$SV_CERT_LOCALITY/;s/SV_CERT_ORG/$SV_CERT_ORG/;s/SV_CERT_EMAIL/$SV_CERT_EMAIL/;s/SV_CERT_COMMON_NAME/$SV_CERT_COMMON_NAME/" $TEMPDIR/server.cnf

# Add users
cat << EOF > $TEMPDIR/hostapd.eap_user
*     PEAP,TTLS,TLS,FAST
"t"   TTLS-PAP,TTLS-CHAP,TTLS-MSCHAP,MSCHAPV2,MD5,GTC,TTLS,TTLS-MSCHAPV2    "pass"   [2]
EOF

# Make certificates
pushd $TEMPDIR
make
popd

sudo bash -c "hostapd-mana <(cat << EOF
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

mana_wpe=1
mana_credout=/tmp/hostapd.credout
mana_eapsuccess=1
mana_eaptls=1
ieee80211n=1

EOF
)"
