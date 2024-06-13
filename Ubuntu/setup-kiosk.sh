#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Check if URL argument is provided
if [ -z "$1" ]
  then
    echo "Usage: sudo ./setup_read_only.sh <URL>"
    exit
fi

# URL for Chromium kiosk mode
URL="$1"

# Step 1: Modify /etc/fstab to mount root filesystem as read-only
echo "Modifying /etc/fstab..."
echo "UUID=$(blkid -s UUID -o value /) / ext4 ro 0 1" | tee -a /etc/fstab > /dev/null

# Step 2: Install overlayroot
echo "Installing overlayroot..."
apt update
apt install -y overlayroot

# Step 3: Configure overlayroot
echo "Configuring overlayroot..."

cat <<EOF >> /etc/overlayroot.conf
overlayroot="tmpfs"
overlayroot_cfgdisk="tmpfs"
overlayroot_mode="ro"
overlayroot_options="sync=always"
overlayroot_tmpfs_size="50%"
overlayroot_quiet="yes"
EOF

# Step 4: Update bootloader configuration
echo "Updating bootloader configuration..."
sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 overlayroot=tmpfs"/' /etc/default/grub
update-grub

# Step 5: Install Chromium and configure kiosk mode
echo "Installing Chromium..."
apt install -y chromium-browser

echo "Configuring Chromium kiosk mode..."
mkdir -p /etc/xdg/autostart
cat <<EOF > /etc/xdg/autostart/chromium.desktop
[Desktop Entry]
Type=Application
Exec=chromium-browser --noerrdialogs --kiosk "$URL"
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Chromium
Name=Chromium
Comment=Start Chromium in kiosk mode
EOF

# Step 6: Reboot
echo "Rebooting..."
reboot
