#!/bin/bash

# Ask the user for the URLs to display
read -p "Enter the URL for display 1: " kiosk_url_1
read -p "Enter the URL for display 2: " kiosk_url_2

# Ask the user for the hostname
read -p "Enter the hostname for this Raspberry Pi: " pi_hostname

# Ask the user for the Pi's username
read -p "Enter the username of the Raspberry Pi: " pi_username

# Install X Window System, Chromium, and unclutter
sudo apt install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox
sudo apt install -y chromium-browser unclutter

# Set the hostname
echo $pi_hostname | sudo tee /etc/hostname
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$pi_hostname/g" /etc/hosts
echo "127.0.0.1   localhost.localdomain localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1   $pi_hostname" | sudo tee -a /etc/hosts
sudo hostnamectl set-hostname $pi_hostname

# Create Openbox autostart directory if it doesn't exist
mkdir -p ~/.config/openbox

# Create and configure autostart script for multiple displays
cat <<EOL > ~/.config/openbox/autostart
# Disable screen blanking
xset s off
xset s noblank
xset -dpms

# Hide the mouse cursor after 0.1 seconds of inactivity
unclutter -idle 0.1 -root &

# Start Chromium in kiosk mode on display 1 (HDMI-1)
export DISPLAY=:0.0
chromium-browser --noerrdialogs --disable-infobars --kiosk $kiosk_url_1 --window-position=0,0 --start-fullscreen --disable-gpu &

# Start Chromium in kiosk mode on display 2 (HDMI-2)
export DISPLAY=:0.1
chromium-browser --noerrdialogs --disable-infobars --kiosk $kiosk_url_2 --window-position=1920,0 --start-fullscreen --disable-gpu &
EOL

# Create and configure .xinitrc file
cat <<EOL > ~/.xinitrc
exec openbox-session
EOL

# Enable automatic login
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOL | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $pi_username --noclear %I \$TERM
EOL

# Configure .bash_profile to start X automatically
cat <<EOL >> ~/.bash_profile

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    startx
fi
EOL

# Reboot the system to apply all changes
echo "Rebooting to apply changes..."
sudo reboot
