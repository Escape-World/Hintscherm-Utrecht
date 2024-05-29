#!/bin/bash

# Ask the user for the URL to display
read -p "Enter the URL to display in kiosk mode: " kiosk_url

# Ask the user for the hostname
read -p "Enter the hostname for this Raspberry Pi: " pi_hostname

# Update and upgrade the system
sudo apt update && sudo apt full-upgrade -y

# Install Git if it's not already installed
if ! command -v git &> /dev/null; then
    sudo apt install -y git
fi

# Install X Window System, Chromium, and unclutter
sudo apt install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox
sudo apt install -y chromium-browser unclutter

# Set the hostname
echo $pi_hostname | sudo tee /etc/hostname
sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$pi_hostname/g" /etc/hosts
sudo hostname $pi_hostname

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
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOL | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
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

# Function to set the system to read-only mode
set_read_only_mode() {
    # Modify /etc/fstab to set root as read-only and necessary directories as read-write
    sudo cp /etc/fstab /etc/fstab.bak
    sudo bash -c 'cat <<EOL > /etc/fstab
proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    defaults,ro       0       2
/dev/mmcblk0p2  /               ext4    defaults,ro       0       1
tmpfs           /var/log        tmpfs   defaults,noatime,nosuid,mode=0755,size=20m   0  0
tmpfs           /var/tmp        tmpfs   defaults,noatime,nosuid,mode=1777,size=10m   0  0
tmpfs           /tmp            tmpfs   defaults,noatime,nosuid,mode=1777,size=10m   0  0
EOL'

    # Ensure directories exist and are mounted as tmpfs
    sudo mkdir -p /var/log /var/tmp /tmp
    sudo mount -a

    # Reload the systemd daemon
    sudo systemctl daemon-reload

    # Make rc.local script to remount necessary directories as read-write on boot
    sudo cp /etc/rc.local /etc/rc.local.bak
    sudo bash -c 'cat <<EOL > /etc/rc.local
#!/bin/bash
mount -o remount,rw /
mount -o remount,rw /boot
exit 0
EOL'
    sudo chmod +x /etc/rc.local
}

# Call the function to set the system to read-only mode
set_read_only_mode

# Reboot the system to apply all changes
echo "Rebooting to apply changes..."
sudo reboot
