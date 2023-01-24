# ufw-killswitch

These are just two scripts that will guide/help you to set up a "killswitch" on your computer, using the UFW firewall.  
A killswitch is a term used to explain that whenever your VPN connection fails, then no packages will be leaked while you are disconnected from the VPN.

# Steps
1. Clone/download the repository
1. Switch to your superuser (`su -`) or execute the following steps and the scripts using `sudo`, since only the root user can make changes to the UFW firewall
1. Make sure you have `ufw`installed, or else install it from using your package manager  
`pacman -S ufw` for arch based distros, `apt install ufw` for debian based, `apt-get install ufw` for PCLinuxOS
1. Make the scripts executable by running `chmod +x [scriptname].sh` (replace the scriptname for the actual script name)
1. Run the script you want by doing `./scriptname.sh` and follow the steps
1. If you have any questions, suggestions or concerns, open an issue here in github. Your feedback is appreciated.
