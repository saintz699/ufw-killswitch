#!/bin/bash

echo "Execute this script as sudo. Press enter to continue."

# Disabling firewall and setting basic rules
ufw disable

yes | ufw reset

ufw default deny outgoing
ufw default deny incoming
ufw deny ssh

echo $( ip addr )

echo -n "Enter the interface you're connected to. eth0 or wlanX"

read interface

echo -n "Enter the IP of the VPN"

read vpn_ip

echo -n "Enter the port of the VPN"

read vpn_port

echo "Executing the following command: ufw allow out to $vpn_ip port $vpn_port proto udp"

echo -n "Enter the interface of the vpn. tun0 or tun1 or wg-xxx"

read vpn_iface

echo "Executing the following command: ufw allow out on $vpn_iface from any to any"

ufw allow out on $vpn_iface from any to any

echo -n "Enter the ip of your local interface connection "

read local_ip

echo "Executing the following command: ufw allow in on $interface from $vpn_ip to $local_ip"

ufw allow in $interface from $vpn_ip on $local_ip

echo "Script finished."

ufw status numbered
