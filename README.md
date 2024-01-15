# WAS

Wi-Fi Attack Simulator.

Practice wireless attacks on your own machine, without the need for an external adapter!

> Implemented

- [x] Client simulation
- [x] Open network
- [x] WPA2-PSK network
- [x] WPA3-PSK network
- [ ] WEP network / weird errors here, someone help pls
- [x] WPS network
- [x] WPA2-MGT network

## Why

Wi-Fi attack sim is me being annoyed at no PEN-210 labs so I made my own with bash scripts.

## Installation

> **NOTE**:
> **THIS COUNTS ON GUESSING AND HOPING THAT YOU DO NOT HAVE ANY OTHER INTERFACES THAT CALL THEMSELVES wlanN.**
> run this in a VM

You'll need:
- hostapd
- dnsmasq
- iproute2
- iw
- macchanger
- mac80211_hwsim kernel module

## Walkthroughs

[Walkthroughs are here](./walkthroughs)

## Usage

Run `was.sh` with the script with the name of a script in `hostapd/`.

Open network
```bash
./was.sh open_network
```

WPA2 network
```bash
./was wpa2_network
```

you get the idea...

## Other stuff

In the `adhoc/` folder there are scripts to generate any type of AP you want, as well as any type of client you want (without a config file).

This is nowhere near usable

Here's an example mgt network
```bash
./eap_ap.sh --wpa2 --eap --channel 11 --ssid was-enterprise --hwmode g --ca '/C=AU/ST=NSW/L=Sydney/O=Internet Widgets Pty./CN=ca@internetwidgets.com.au' --server '/C=AU/ST=NSW/L=Sydney/O=Internet Widgets Pty./CN=server@internetwidgets.com.au'
```

And here's an example of an open network
```bash
./open_ap.sh --channel 1 --hwmode g --ssid was-open
```
