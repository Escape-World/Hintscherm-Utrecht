#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

read -p "Enter the URL to display on the first monitor in kiosk mode (Firefox): " URL1
read -p "Enter the URL to display on the second monitor in kiosk mode (Chromium): " URL2

# Step 1: Ensure second monitor is detected and configured
echo "Configuring monitors..."
xrandr --output HDMI-1 --auto --right-of HDMI-2

# Step 2: Install Chromium browser
echo "Installing Chromium browser..."
apt install -y chromium-browser

# Step 3: Configure Firefox and Chromium kiosk mode
echo "Configuring Firefox and Chromium kiosk mode..."
mkdir -p /etc/xdg/autostart

cat <<EOF > /etc/xdg/autostart/firefox1.desktop
[Desktop Entry]
Type=Application
Exec=firefox --kiosk --window-position=0,0 --window-size=1920,1080 "$URL1"
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Firefox1
Name=Firefox1
Comment=Start Firefox in kiosk mode on the first monitor
EOF

cat <<EOF > /etc/xdg/autostart/chromium2.desktop
[Desktop Entry]
Type=Application
Exec=bash -c "sleep 5 && chromium-browser --noerrdialogs --disable-session-crashed-bubble --disable-infobars --kiosk --window-position=1920,0 --window-size=1920,1080 \"$URL2\""
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
Exec=unclutter-xfixes -noevents -timeout 0
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
systemctl mask suspend.target

# Step 6: Add xset commands to disable DPMS and screen blanking
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

# Step 7: Reboot
echo "Rebooting..."
reboot