#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

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

# Change GRUB_TIMEOUT to 0
echo "Setting GRUB_TIMEOUT to 0..."
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub

update-grub