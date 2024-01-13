# Open network

## Tools

- [airmon-ng](https://linux.die.net/man/1/airmon-ng)
- [airodump-ng](https://linux.die.net/man/1/airodump-ng)
- [wpa_supplicant](https://linux.die.net/man/8/wpa_supplicant)

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

3. Create a `wpa_supplicant` configuration file based off of the information gathered in step 2

- Edit the configuration file

```bash
nano open_network.conf
```

> This doesn't have to be called open_network.conf, it can be called anything you want!

- Add the following contents in the configuration file

```
network={
  ssid="<network name>"
  key_mgmt=NONE
}
```

> Replace `<network name>` with the name of the network you found in step 2.
> e.g. If the network name was called `MyOpenNetwork` the configuration file would look like:
> ```
> network={
>   ssid="MyOpenNetwork"
>   key_mgmt=NONE
> }
> ```

- Exit nano by pressing Ctrl+X, Y, and then Enter

4. Take the `wlan2mon` interface out of monitor mode

```bash
sudo airmon-ng stop wlan2mon
```

5. Connect to the open network

```bash
sudo wpa_supplicant -i wlan2 -c open_network.conf
```
