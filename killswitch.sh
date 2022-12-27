#!/bin/bash

# TODO: hacer un IF para configurar todo de cero o simplemente agregar/habilitar un nuevo ip
# TODO: probar con lo de wireguard

function set_default_rules() {
    # Disabling firewall and setting basic rules
    ufw disable

    # Reset any existing rule
    yes | ufw reset

    # Set basic rules
    ufw default deny outgoing
    ufw default deny incoming
    ufw deny ssh
}

printf "Execute this script as sudo AND connect to the VPN before running it."
printf "Also, make sure you have the port number your VPN will use (it is on the vpn config file)."

printf "\n\n------------------------\n\n"

printf "Select \"Yes\" if you want to set up ufw from scratch (will reset existing rules) or \"No\" to simply allow a new connection"

select first_run in "Yes" "No"
do
    if [ $first_run == "Exit" ]
    then
        printf "Leaving the script..."
        exit 0
    else
        break
    fi
done

printf "Select the interface you're conneted to. \nEthernet interfaces start with eth or enp\nWifi interfaces start with wlan.\n"

select local_interface in $(ip link show | grep -v "lo" | grep -oP '(?<=: ).*(?=:)')
do
    if [ $local_interface == "Exit" ]
    then
        printf "Leaving the script..."
        exit 0
    else
        break
    fi
done
vpn_ip=$( ip r | grep -v default | grep via | cut -d " " -f 1 )

echo -n "Enter the port of the VPN: "

read vpn_port


printf "Enter the interface of the vpn. Usually named tun0 or tun1 for OpenVPN or wg-xxx for Wireguard"

select vpn_interface in $( ip link show | grep -v "$local_interface" | grep -v "lo" | grep -oP '(?<=: ).*(?=:)' )
do
    if [ $vpn_interface == "Exit" ]
    then
        printf "Leaving the script..."
        exit 0
    else
        break
    fi
done

local_ip=$( ip r | grep -e "default.*$local_interface" | cut -d " " -f 3 )

printf "\n\n------------------------\n\n"

# Set custom rules based on information entered
if [ $first_run == "Yes" ]
then
    set_default_rules
fi

# Allow outgoing traffic to the VPN ip address
printf "Executing the following command: ufw allow out to $vpn_ip port $vpn_port proto udp"
ufw allow out to $vpn_ip port $vpn_port proto udp

# Allow outgoing traffic to the VPN interface
printf "Executing the following command: ufw allow out on $vpn_interface from any to any"
ufw allow out on $vpn_interface from any to any

# Allow incoming traffic from the VPN IP address to our local interface ip address. 
## This is used to allow OpenVPN to request authorization to connect/reconnect to the VPN
printf "Executing the following command: ufw allow in on $local_interface from $vpn_ip to $local_ip"
ufw allow in $local_interface from $vpn_ip to $local_ip


# Enable the firewall
ufw enable

# Show a status
ufw status numbered

printf "\n\nScript finished.\n\n"
