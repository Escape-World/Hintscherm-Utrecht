#!/bin/bash

set -e

# Prompt for the kiosk URL
read -p "Enter the URL for the kiosk mode: " KIOSK_URL

# Variables
BASE_DIR="/base"
UPPER_DIR="/upper"
WORK_DIR="/work"
OVERLAY_DIR="/overlay"
ROOTFS_DIR="/rootfs"

# Install overlayroot if not already installed
if ! dpkg -l | grep -q overlayroot; then
  echo "Installing overlayroot..."
  apt-get update
  apt-get install -y overlayroot
fi

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p $BASE_DIR $UPPER_DIR $WORK_DIR $OVERLAY_DIR

# Ensure the base directory is not already mounted
if mountpoint -q $BASE_DIR; then
  echo "Unmounting the base directory..."
  umount $BASE_DIR
fi

# Mount the root filesystem as read-only to the base directory
echo "Mounting the root filesystem as read-only to the base directory..."
mount --bind / $BASE_DIR
mount -o remount,ro $BASE_DIR

# Create a script to setup the overlay filesystem
cat << 'EOF' > /usr/local/bin/setup-overlayfs.sh
#!/bin/bash
set -e

BASE_DIR="/base"
UPPER_DIR="/upper"
WORK_DIR="/work"
OVERLAY_DIR="/overlay"
ROOTFS_DIR="/rootfs"

# Create the overlay filesystem
mkdir -p $ROOTFS_DIR
mount -t overlay overlay -o lowerdir=$BASE_DIR,upperdir=$UPPER_DIR,workdir=$WORK_DIR $ROOTFS_DIR

# Switch to the new root filesystem
echo "Switching to the new root filesystem..."
exec switch_root $ROOTFS_DIR /sbin/init
EOF

# Make the script executable
chmod +x /usr/local/bin/setup-overlayfs.sh

# Modify the GRUB configuration to use the overlay setup script on boot
echo "Configuring GRUB to use the overlay setup script..."
GRUB_CMDLINE_LINUX="init=/usr/local/bin/setup-overlayfs.sh"
sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE_LINUX\"|" /etc/default/grub

# Update GRUB
update-grub

# Set up autologin for 'escapeworld' user
echo "Setting up autologin for 'escapeworld' user..."
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat << 'EOF' > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin escapeworld --noclear %I $TERM
EOF

# Set up kiosk mode for 'escapeworld' user
echo "Setting up kiosk mode..."
cat << EOF > /home/escapeworld/.xsession
#!/bin/bash
xset -dpms
xset s off
xset s noblank
exec /usr/bin/chromium-browser --kiosk "$KIOSK_URL"
EOF
chmod +x /home/escapeworld/.xsession
chown escapeworld:escapeworld /home/escapeworld/.xsession

echo "Kiosk setup complete. Reboot to apply changes."
