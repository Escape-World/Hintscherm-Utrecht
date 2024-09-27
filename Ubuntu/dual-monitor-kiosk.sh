#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

read -p "Enter the URL to display on the first monitor in kiosk mode: " URL1
read -p "Enter the URL to display on the second monitor in kiosk mode: " URL2

# Step 1: Ensure second monitor is detected and configured
echo "Configuring monitors..."
xrandr --output HDMI-1 --auto --right-of HDMI-2

# Step 2: Create Firefox profiles and startup script
echo "Creating Firefox profiles and startup script..."
mkdir -p /home/kiosk/.mozilla/firefox/kiosk1
mkdir -p /home/kiosk/.mozilla/firefox/kiosk2

cat <<EOF > /home/kiosk/.mozilla/firefox/kiosk1/user.js
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.warnOnClose", false);
EOF

cat <<EOF > /home/kiosk/.mozilla/firefox/kiosk2/user.js
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.warnOnClose", false);
EOF

cat <<EOF > /usr/local/bin/start_firefox_kiosk.sh
#!/bin/bash
sleep 10  # Wait for the desktop environment to fully load
firefox --kiosk --new-instance -P kiosk1 --window-size=1920,1080 "$URL1" &
sleep 5
firefox --kiosk --new-instance -P kiosk2 --window-size=1920,1080 "$URL2" &

# Wait for Firefox windows to open
sleep 5

# Move windows to correct positions
wmctrl -r "Mozilla Firefox" -e 0,0,0,1920,1080
wmctrl -r "Mozilla Firefox" -e 0,1920,0,1920,1080
EOF

chmod +x /usr/local/bin/start_firefox_kiosk.sh
chown -R kiosk:kiosk /home/kiosk/.mozilla

# Step 3: Configure autostart for the Firefox startup script
echo "Configuring autostart for Firefox kiosk mode..."
mkdir -p /etc/xdg/autostart

cat <<EOF > /etc/xdg/autostart/firefox-kiosk.desktop
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/start_firefox_kiosk.sh
Hidden=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Firefox Kiosk
Name=Firefox Kiosk
Comment=Start Firefox in kiosk mode on both monitors
EOF

# Step 4: Install unclutter-xfixes and wmctrl
echo "Installing unclutter-xfixes and wmctrl..."
apt install -y unclutter-xfixes wmctrl

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