# WAS

Wi-Fi Attack Simulator.

Practice wireless attacks on your own machine, without the need for an external adapter!

> Implemented

- [x] Client simulation
- [x] Open network
- [x] WPA2-PSK network
- [x] WPA3-PSK network
- [x] WEP network / NOTE: YOU NEED TO COMPILE A CUSTOM HOSTAPD AND WPA_SUPPLICANT. SEE BELOW.
- [ ] WPS network
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
- git

For the WEP network, you'll need to get your hands dirty with some compilation!

I can't be bothered to write up docs for this, so here is just a bunch of commands. If you don't follow them exactly it wont work!

```bash
cd /opt
git clone --depth=1 https://w1.fi/hostap.git
cd hostap/hostapd
cp defconfig .config
sed -i 's/#CONFIG_WEP=y/CONFIG_WEP=y/' .config
make -j $(nproc)

cd ../wpa_supplicant
cp defconfig .config
sed -i 's/#CONFIG_WEP=y/CONFIG_WEP=y/' .config
make -j $(nproc)
```

Once you've run the above commands everything should be good to go :)

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
