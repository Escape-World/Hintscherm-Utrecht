#!/bin/bash

# Create directories if they don't exist
sudo mkdir -p /etc/X11/xorg.conf.d/

# Create Xorg configuration for Display :0
echo "Creating Xorg configuration for Display :0..."
sudo bash -c 'cat << EOF > /etc/X11/xorg.conf.d/10-screen-0.conf
Section "ServerLayout"
    Identifier "Layout0"
    Screen 0 "Screen0"
EndSection

Section "Monitor"
    Identifier "Monitor0"
    Option "PreferredMode" "auto"
EndSection

Section "Device"
    Identifier "Device0"
    Driver "intel"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "Device0"
    Monitor "Monitor0"
    SubSection "Display"
        Depth 24
    EndSubSection
EndSection
EOF'

# Create Xorg configuration for Display :1
echo "Creating Xorg configuration for Display :1..."
sudo bash -c 'cat << EOF > /etc/X11/xorg.conf.d/20-screen-1.conf
Section "ServerLayout"
    Identifier "Layout1"
    Screen 0 "Screen1"
EndSection

Section "Monitor"
    Identifier "Monitor1"
    Option "PreferredMode" "auto"
EndSection

Section "Device"
    Identifier "Device1"
    Driver "intel"
EndSection

Section "Screen"
    Identifier "Screen1"
    Device "Device1"
    Monitor "Monitor1"
    SubSection "Display"
        Depth 24
    EndSubSection
EndSection
EOF'

# Create systemd service for Display :0
echo "Creating systemd service for Display :0..."
sudo bash -c 'cat << EOF > /etc/systemd/system/xserver-display0.service
[Unit]
Description=X Server for Display 0
After=display-manager.service

[Service]
ExecStart=/usr/bin/X :0 -layout Layout0
Restart=always

[Install]
WantedBy=graphical.target
EOF'

# Create systemd service for Display :1
echo "Creating systemd service for Display :1..."
sudo bash -c 'cat << EOF > /etc/systemd/system/xserver-display1.service
[Unit]
Description=X Server for Display 1
After=display-manager.service

[Service]
ExecStart=/usr/bin/X :1 -layout Layout1
Restart=always

[Install]
WantedBy=graphical.target
EOF'

# Reload systemd to recognize new services
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable the systemd services for both displays
echo "Enabling X server services for Display :0 and Display :1..."
sudo systemctl enable xserver-display0.service
sudo systemctl enable xserver-display1.service

# Inform the user
echo "Setup complete! Please reboot your system to apply the changes."
