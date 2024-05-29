#!/bin/bash

# Ask the user for the URL to display
read -p "Enter the URL to display in kiosk mode: " kiosk_url

# Update and upgrade the system
sudo apt update && sudo apt full-upgrade -y

# Install X Window System, Chromium, and unclutter
sudo apt install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox
sudo apt install -y chromium-browser unclutter

# Create Openbox autostart directory
mkdir -p ~/.config/openbox

# Create and configure autostart script
cat <<EOL > ~/.config/openbox/autostart
# Disable screen blanking
xset s off
xset s noblank
xset -dpms

# Hide the mouse cursor after 0.1 seconds of inactivity
unclutter -idle 0.1 -root &

# Start Chromium in kiosk mode
chromium-browser --noerrdialogs --disable-infobars --kiosk $kiosk_url
EOL

# Create and configure .xinitrc file
cat <<EOL > ~/.xinitrc
exec openbox-session
EOL

# Enable automatic login
sudo systemctl edit getty@tty1 <<EOL
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
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
