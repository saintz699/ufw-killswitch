#!/bin/bash

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

echo -n "Enter the port of the VPN: "

read vpn_port

printf "Select the VPN interface. Usually named tun0 or tun1 for OpenVPN or check the name of the .conf file under /etc/wireguard for Wireguard\n"
echo -n "Enter the VPN interface: "
read vpn_interface

printf "\n\n------------------------\n\n"

if [ $first_run == "Yes" ]
then
    set_default_rules
fi

# Set custom rules based on information entered
ufw deny in on $vpn_interface
ufw deny out on $vpn_interface

ufw allow out on $vpn_interface # TODO: la interfaz sacarla del nombre del archivo .conf en /etc/wireguard
ufw allow out to any port $vpn_port # TODO: el puerto sacarlo del archivo de configuracion

# Enable the firewall
ufw enable

# Show a status
ufw status numbered

printf "\n\nScript finished.\n\n"
