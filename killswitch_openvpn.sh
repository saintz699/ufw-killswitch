#!/bin/bash


function set_default_rules() {
    # Disabling firewall and setting basic rules
    ufw disable

    # Reset any existing rule
    yes | ufw reset

    # Set basic rules
    ufw default deny outgoing
    ufw default deny incoming
    # ufw deny ssh
}
clear
printf "\n\n---------------------\n\n"

printf "Execute this script as sudo AND connect to the Open VPN before running it."
printf "Also, make sure you have the port number your Open VPN will use (it is on the vpn config file)."

printf "\n\n------------------------\n\n"

printf "Select \"Yes\" if you want to set up ufw from scratch (will reset existing rules) or \"No\" to simply allow a new connection\n"

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


printf "\n\n---------------------\n\n"

count_of_interfaces=$(ip link | grep "state UP" | grep -oP '(?<=: ).*(?=:)' | wc -l)
if [ $count_of_interfaces == 1 ]
then
    local_interface=$(ip link | grep "state UP" | grep -oP '(?<=: ).*(?=:)')
    printf "Automatically selected ** $local_interface ** interface as the local connection you are using"
else
    printf "Select the interface you're conneted to:\n\tEthernet interfaces start with eth or enp\n\tWifi interfaces start with wl.\n"
    select local_interface in $(ip link | grep "state UP" | grep -oP '(?<=: ).*(?=:)')
    do
        if [ $local_interface == "Exit" ]
        then
            printf "Leaving the script..."
            exit 0
        else
            printf "You selected ** $local_interface ** interface"
            break
        fi
    done
fi

printf "\n\n---------------------\n\n"
printf "Now enter the IP of the VPN:\n"
select vpn_ip in "I am already connected to the VPN (will automatically pick the IP)" "Enter VPN IP manually"
do
    if [ "$vpn_ip" == "Enter VPN IP manually" ]
    then
        echo -n "Enter VPN IP address: "
        read vpn_ip
        break
    fi
    if [ "$vpn_ip" == "Exit" ]
    then
        printf "Leaving the script..."
        exit 0
    else
        vpn_ip=$( ip r | grep -v default | grep via | cut -d " " -f 1 )
        break
    fi
done
printf "\nWe'll use the following address for the VPN: ** $vpn_ip **"

printf "\n\n---------------------\n\n"

echo -n "Enter the port of the VPN: "

read vpn_port

printf "\n\n---------------------\n\n"

autopick_interface=0
printf "Enter the interface of the vpn.\n\tUsually named * tun0 * or * tun1 * for OpenVPN.\n\tFor Wireguard, check the name of the .conf file under /etc/wireguard\n"
select ioption in "Enter vpn interface manually" "Select from the list (choose this only if you are connected to an OpenVPN)"
do
    if [ "$ioption" == "Exit" ]
    then
        printf "Leaving the script..."
        exit 0
    fi
    if [ "$ioption" == "Enter vpn interface manually" ]
    then
        echo -n "Enter the VPN interface: "
        read vpn_interface
        break
    else
        select vpn_interface in $( ip link show | grep -v "$local_interface" | grep -v "lo" | grep -oP '(?<=: ).*(?=:)' )
        do
            if [ $vpn_interface == "Exit" ]
            then
                printf "Leaving the script..."
                exit 0
            else
                autopick_interface=1
                break
            fi
        done
    fi
    if [ $autopick_interface == 1 ]
    then
        break
    fi
done

printf "The VPN interface is ** $vpn_interface **"

local_ip=$( ip r | grep -e "default.*$local_interface" | cut -d " " -f 3 )

printf "\n\n------------------------\n\n"

# Set custom rules based on information entered
if [ $first_run == "Yes" ]
then
    set_default_rules
fi

# Allow outgoing traffic to the VPN ip address
printf "Executing the following command: ufw allow out to $vpn_ip port $vpn_port proto udp\n"
ufw allow out to $vpn_ip port $vpn_port proto udp

# Allow outgoing traffic to the VPN interface
printf "Executing the following command: ufw allow out on $vpn_interface from any to any\n"
ufw allow out on $vpn_interface from any to any

# Allow incoming traffic from the VPN IP address to our local interface ip address. 
## This is used to allow OpenVPN to request authorization to connect/reconnect to the VPN
# printf "Executing the following command: ufw allow in on $local_interface from $vpn_ip to $local_ip"
# ufw allow in $local_interface from $vpn_ip to $local_ip


# Enable the firewall
ufw enable

# Show a status
ufw status numbered

printf "\n\nScript finished.\n\n"
printf "\nRun systemctl enable ufw.service for systemd distributions. .\n"
printf "\nOr add ufw enable to /etc/rc.local for SysV init distributions.\n"

printf "\n\n------------------------\n\n"
