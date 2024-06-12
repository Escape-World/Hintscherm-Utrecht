#!/bin/bash

# Check if URL is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <kiosk-url>"
  exit 1
fi

KIOSK_URL=$1


# Update and install necessary packages
apt update
apt install -y xorg openbox chromium-browser

# Create Openbox autostart file
mkdir -p /etc/xdg/openbox
cat <<EOF > /etc/xdg/openbox/autostart
chromium-browser --kiosk --no-first-run --disable-infobars $KIOSK_URL
EOF

# Create .xinitrc file to start Openbox
cat <<EOF > ~/escapeworld/.xinitrc
exec openbox-session
EOF
chown escapeworld:escapeworld ~/escapeworld/.xinitrc

# Create systemd service to start X at boot
cat <<EOF > /etc/systemd/system/kiosk.service
[Unit]
Description=Kiosk Mode
After=systemd-user-sessions.service

[Service]
User=escapeworld
Environment=DISPLAY=:0
ExecStart=/usr/bin/startx
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable the kiosk service
systemctl enable kiosk.service

# Create and configure a read-only file system
# /etc/fstab modifications for read-only root and other writable directories
cat <<EOF >> /etc/fstab
# Read-only root filesystem
/dev/sda1 / ext4 ro,noatime,errors=remount-ro 0 1

# Writable filesystems
/dev/sda2 /var ext4 defaults 0 2
tmpfs /tmp tmpfs defaults 0 0
/var/local/home /home none bind 0 0
/var/local/srv /srv none bind 0 0
EOF

# Create writable directories
mkdir -p /var/local/home /var/local/srv

# Configure necessary /etc symlinks for read-only root
ln -sf /var/local/adjtime /etc/adjtime
ln -sf /run/network /etc/network/run

# Environment variable for blkid
echo "BLKID_FILE=/var/local/blkid.tab" >> /etc/environment

# Ensure /etc/lvm/lvm.conf exists before modifying it
if [ -f /etc/lvm/lvm.conf ]; then
  sed -i 's|backup_dir = "/etc/lvm/backup"|backup_dir = "/var/backups/lvm/backup"|' /etc/lvm/lvm.conf
  sed -i 's|archive_dir = "/etc/lvm/archive"|archive_dir = "/var/backups/lvm/archive"|' /etc/lvm/lvm.conf

  # Move LVM backup and archive directories
  mkdir -p /var/backups/lvm
  mv /etc/lvm/backup /var/backups/lvm/
  mv /etc/lvm/archive /var/backups/lvm/
fi

# Add apt-get remount configuration
cat <<EOF >> /etc/apt/apt.conf
DPkg {
    // Auto re-mounting of a readonly /
    Pre-Invoke { "mount -o remount,rw /"; };
    Post-Invoke { "test \${NO_APT_REMOUNT:-no} = yes || mount -o remount,ro / || true"; };
};
EOF

echo "Kiosk setup complete. Please reboot the system."
