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

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p $BASE_DIR $UPPER_DIR $WORK_DIR $OVERLAY_DIR

# Create an init script to setup the overlay filesystem
cat << 'EOF' > /usr/local/bin/setup-overlayfs.sh
#!/bin/sh

PREREQ=''

prereqs() {
  echo "$PREREQ"
}

case $1 in
prereqs)
  prereqs
  exit 0
  ;;
esac

# Boot normally when the user selects single user mode.
if grep single /proc/cmdline >/dev/null; then
  exit 0
fi

ro_mount_point="${rootmnt%/}.ro"
rw_mount_point="${rootmnt%/}.rw"

# Create mount points for the read-only and read/write layers:
mkdir "${ro_mount_point}" "${rw_mount_point}"

# Move the already-mounted root filesystem to the ro mount point:
mount --move "${rootmnt}" "${ro_mount_point}"

# Mount the read/write filesystem:
mount -t tmpfs root.rw "${rw_mount_point}"

# Mount the union:
mount -t aufs -o "dirs=${rw_mount_point}=rw:${ro_mount_point}=ro" root.union "${rootmnt}"

# Correct the permissions of /:
chmod 755 "${rootmnt}"

# Make sure the individual ro and rw mounts are accessible from within the root
# once the union is assumed as /. This makes it possible to access the
# component filesystems individually.
mkdir "${rootmnt}/ro" "${rootmnt}/rw"
mount --move "${ro_mount_point}" "${rootmnt}/ro"
mount --move "${rw_mount_point}" "${rootmnt}/rw"

# Make sure checkroot.sh doesn't run. It might fail or erroneously remount /.
rm -f "${rootmnt}/etc/rcS.d"/S[0-9][0-9]checkroot.sh
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
