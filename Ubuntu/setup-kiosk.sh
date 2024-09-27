#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

read -p "Enter the URL to display in kiosk mode: " URL

# # Step 1: Modify /etc/fstab to mount root filesystem as read-only
# echo "Modifying /etc/fstab..."
# echo "UUID=$(blkid -s UUID -o value /) / ext4 ro 0 1" | tee -a /etc/fstab > /dev/null

# # Step 2: Install overlayroot
# echo "Installing overlayroot..."
# apt update
# apt install -y overlayroot

# # Step 3: Configure overlayroot
# echo "Configuring overlayroot..."

# cat <<EOF >> /etc/overlayroot.conf
# overlayroot="tmpfs"
# overlayroot_cfgdisk="tmpfs"
# overlayroot_mode="ro"
# overlayroot_options="sync=always"
# overlayroot_tmpfs_size="50%"
# overlayroot_quiet="yes"
# EOF

# # Step 4: Update bootloader configuration
# echo "Updating bootloader configuration..."
# sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 overlayroot=tmpfs"/' /etc/default/grub

# # Change GRUB_TIMEOUT to 0
# echo "Setting GRUB_TIMEOUT to 0..."
# sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub

# update-grub

# Step 5: Install Chromium and configure kiosk mode
echo "Installing Chromium..."
apt install -y chromium-browser

echo "Configuring Chromium kiosk mode..."
mkdir -p /etc/xdg/autostart
cat <<EOF > /etc/xdg/autostart/chromium.desktop
[Desktop Entry]
Type=Application
Exec=chromium-browser --noerrdialogs --autoplay-policy=no-user-gesture-required --enable-features=OverlayScrollbar --disable-restore-session-state --kiosk "$URL"
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Chromium
Name=Chromium
Comment=Start Chromium in kiosk mode
EOF

# Step 6: Install unclutter-xfixes to hide the cursor immediately
echo "Installing unclutter-xfixes..."
apt install -y unclutter-xfixes

echo "Configuring unclutter-xfixes to hide the cursor immediately..."
cat <<EOF > /etc/xdg/autostart/unclutter-xfixes.desktop
[Desktop Entry]
Type=Application
Exec=unclutter --timeout 1 --start-hidden
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Unclutter-xfixes
Name=Unclutter-xfixes
Comment=Hide the cursor immediately
EOF

# Step 7: Disable screen timeout and screensaver
echo "Disabling screen timeout and screensaver..."
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
systemctl mask suspend.target

# Step 8: Add xset commands to disable DPMS and screen blanking
echo "Disabling DPMS and screen blanking..."
cat <<EOF > /etc/xdg/autostart/disable-dpms.desktop
[Desktop Entry]
Type=Application
Exec=sh -c 'xset -display :0.0 -dpms; xset -display :0.0 s off; xset -display :0.0 s noblank'
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Disable DPMS
Name=Disable DPMS
Comment=Disable DPMS and screen blanking
EOF

# Step 9: Reboot
echo "Rebooting..."
reboot
