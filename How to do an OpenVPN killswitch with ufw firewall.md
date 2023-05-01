## First log as root (or use sudo)
`su -`

## Restart the firewall (unless you already have set up rules)
`ufw reset`

## Set default rules
`ufw default deny incoming`

`ufw default deny outgoing`

## Enable outgoing traffic through the VPN tunnel
- First connect to the VPN and then run: `ip link show`
- Then, look for the interface being used. For OpenVPN it is usually tun0 or tun1.
- Ignore those interfaces named as *eth*, *wlan* or *enp0s* because those are your wifi/ethernet connections that you want to keep blocked. Then run the following command:


`ufw allow out on tun0`

## Enable outgoing traffic through the VPN port
- Check for the port number on the VPN configuration file, it's the one after the colon. Example: 111.111.22.22:***8080***

`ufw allow out to any port vpn_port_here`

## Enable ufw
ufw enable