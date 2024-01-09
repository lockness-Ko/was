# WAS

Practice wireless attacks on your own machine, without the need for an external adapter!

> Implemented

- [x] Client simulation
- [x] Open network
- [x] WPA2-PSK network
- [x] WPA3-PSK network
- [ ] WEP network / weird errors here, someone help pls
- [ ] WPS network
- [ ] WPA2-MGT network

## Why

Wi-Fi attack sim is me being annoyed at no PEN-210 labs so I made my own with bash scripts.

## Installation

> **NOTE**
> **THIS COUNTS ON GUESSING AND HOPING THAT YOU DO NOT HAVE ANY OTHER INTERFACES THAT CALL THEMSELVES wlanN**
> run this in a VM

You'll need:
- hostapd
- dnsmasq
- iproute2
- mac80211_hwsim kernel module

## Usage

Run WAS with the script
