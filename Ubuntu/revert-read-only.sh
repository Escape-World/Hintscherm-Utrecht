#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]
then
  echo "Please run as root"
  exit
fi

# Step 1: Remove overlayroot
echo "Removing overlayroot..."
apt purge -y overlayroot

# Step 2: Remove Chromium and autostart configuration
echo "Removing Chromium and autostart configuration..."
apt purge -y chromium-browser
rm -f /etc/xdg/autostart/chromium.desktop

# Step 3: Modify /etc/fstab to mount root filesystem as read-write
echo "Modifying /etc/fstab..."
sed -i '/overlayroot/d' /etc/fstab

# Step 4: Update bootloader configuration
echo "Updating bootloader configuration..."
sed -i '/overlayroot/d' /etc/default/grub
update-grub

# Step 5: Reboot
echo "Rebooting..."
reboot
