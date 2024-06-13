#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Step 1: Remove overlayroot configuration
echo "Removing overlayroot configuration..."
sed -i '/overlayroot=/d' /etc/default/grub
sed -i '/overlayroot_cfgdisk=/d' /etc/overlayroot.conf
sed -i '/overlayroot_mode=/d' /etc/overlayroot.conf
sed -i '/overlayroot_options=/d' /etc/overlayroot.conf
sed -i '/overlayroot_tmpfs_size=/d' /etc/overlayroot.conf
sed -i '/overlayroot_quiet=/d' /etc/overlayroot.conf

# Step 2: Update bootloader configuration
echo "Updating bootloader configuration..."
update-grub

# Step 3: Modify /etc/fstab to mount root filesystem as read-write
echo "Modifying /etc/fstab..."
sed -i 's/\(.*\) \/ ext4 ro \(.*\)/\1 \/ ext4 rw \2/' /etc/fstab

# Step 4: Remove Chromium autostart configuration
echo "Removing Chromium autostart configuration..."
rm /etc/xdg/autostart/chromium.desktop

# Step 5: Remove unclutter autostart configuration
echo "Removing unclutter autostart configuration..."
rm /etc/xdg/autostart/unclutter.desktop

# Step 6: Reboot
echo "Rebooting..."
reboot
