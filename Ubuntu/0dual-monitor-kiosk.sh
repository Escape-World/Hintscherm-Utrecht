#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Step 1: Configure Xorg for separate screens
echo "Configuring Xorg for separate screens..."

cat <<EOF > /etc/X11/xorg.conf
Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    Screen      1  "Screen1" RightOf "Screen0"
EndSection

Section "Device"
    Identifier  "IntelGPU"
    Driver      "intel"
    BusID       "PCI:0:2:0"
    Screen      0
EndSection

Section "Device"
    Identifier  "IntelGPU1"
    Driver      "intel"
    BusID       "PCI:0:2:0"
    Screen      1
EndSection

Section "Monitor"
    Identifier   "Monitor0"
EndSection

Section "Monitor"
    Identifier   "Monitor1"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "IntelGPU"
    Monitor    "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth     24
        Modes     "1920x1080"  # Adjust according to monitor resolution
    EndSubSection
EndSection

Section "Screen"
    Identifier "Screen1"
    Device     "IntelGPU1"
    Monitor    "Monitor1"
    DefaultDepth 24
    SubSection "Display"
        Depth     24
        Modes     "1920x1080"  # Adjust according to monitor resolution
    EndSubSection
EndSection
EOF

# Restart GDM to apply the new configuration
echo "Restarting GDM..."
systemctl restart gdm3

# Step 2: Ask for URLs
read -p "Enter the URL to display on the first monitor in kiosk mode: " URL1
read -p "Enter the URL to display on the second monitor in kiosk mode: " URL2

# Step 3: Install Chromium and configure kiosk mode
echo "Installing Chromium..."
apt install -y chromium-browser

echo "Configuring Chromium kiosk mode..."
mkdir -p /etc/xdg/autostart
cat <<EOF > /etc/xdg/autostart/chromium1.desktop
[Desktop Entry]
Type=Application
Exec=chromium-browser --noerrdialogs --kiosk --display=:0.0 "$URL1"
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Chromium1
Name=Chromium1
Comment=Start Chromium in kiosk mode on the first monitor
EOF

cat <<EOF > /etc/xdg/autostart/chromium2.desktop
[Desktop Entry]
Type=Application
Exec=chromium-browser --noerrdialogs --kiosk --display=:0.1 "$URL2"
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Chromium2
Name=Chromium2
Comment=Start Chromium in kiosk mode on the second monitor
EOF

# Step 4: Install unclutter-xfixes to hide the cursor immediately
echo "Installing unclutter-xfixes..."
apt install -y unclutter-xfixes

echo "Configuring unclutter-xfixes to hide the cursor immediately..."
cat <<EOF > /etc/xdg/autostart/unclutter-xfixes.desktop
[Desktop Entry]
Type=Application
Exec=unclutter-xfixes -init
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Unclutter-xfixes
Name=Unclutter-xfixes
Comment=Hide the cursor immediately
EOF

# Step 5: Disable screen timeout and screensaver
echo "Disabling screen timeout and screensaver..."
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false

# Step 6: Add xset commands to disable DPMS and screen blanking
echo "Disabling DPMS and screen blanking..."
cat <<EOF > /etc/xdg/autostart/disable-dpms.desktop
[Desktop Entry]
Type=Application
Exec=sh -c 'xset -display :0.0 -dpms; xset -display :0.0 s off; xset -display :0.0 s noblank; xset -display :0.1 -dpms; xset -display :0.1 s off; xset -display :0.1 s noblank'
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Disable DPMS
Name=Disable DPMS
Comment=Disable DPMS and screen blanking on both screens
EOF

# Step 7: Reboot to apply changes
echo "Rebooting..."
reboot
