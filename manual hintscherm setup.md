### 1\. Prepare Your Raspberry Pi

1.  **Install Raspberry Pi OS Lite**:
    *   Download the latest Raspberry Pi OS Lite image from the official Raspberry Pi website.
    *   Use the Raspberry Pi Imager to write the image to your MicroSD card.

### 2\. Initial Setup

1.  **Boot the Raspberry Pi**:
    
    *   Insert the MicroSD card into the Raspberry Pi, connect the monitor via HDMI, and connect the keyboard and mouse.
    *   Power on the Raspberry Pi and follow the initial setup instructions.
2.  **Update and Upgrade**:
    
    *   Open a terminal and run:

        sudo apt update 
        sudo apt full-upgrade -y 
        sudo reboot
        

### 3\. Install X11 and Chromium

1.  **Install X Window System and Chromium**:
    
    *   After the reboot, install the X Window System (a lightweight GUI) and Chromium browser:
        
        sudo apt install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox 
        sudo apt install -y chromium-browser
        sudo apt install -y unclutter
        
2.  **Configure Autostart for Kiosk Mode**:
    
    *   Create an autostart script for Openbox:

        mkdir -p ~/.config/openbox 
        nano ~/.config/openbox/autostart
        
    *   Add the following lines to the autostart file:
        
        # Disable screen blanking 
        xset s off xset s noblank xset -dpms 
        
        # Hide the mouse cursor after 0.1 seconds of inactivity 
        unclutter -idle 0.1 -root & 
        
        # Start Chromium in kiosk mode 
        chromium-browser --noerrdialogs --disable-infobars --kiosk http://your-webpage-url`
        
    *   Replace `http://your-webpage-url` with the URL of the webpage you want to display.
3.  **Configure Xinit**:
    
    *   Create a `.xinitrc` file in your home directory to start Openbox:
        
        nano ~/.xinitrc
        
    *   Add the following line to the `.xinitrc` file:

        exec openbox-session
        

### 4\. Set Up Automatic Login and Start X on Boot

1.  **Enable Automatic Login**:
    
    *   Edit the getty service to enable automatic login for the `pi` user:

        sudo systemctl edit getty@tty1
        
    *   Add the following lines:
        
        [Service] 
        ExecStart= 
        ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM`
        
2.  **Start X at Login**:
    
    *   Edit the `.bash_profile` to start X automatically when the `pi` user logs in:

        nano ~/.bash_profile
        
    *   Add the following lines:

        if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then     startx fi
        

### 5\. Final Steps

1.  **Reboot**:
    
    *   Reboot the Raspberry Pi to apply all changes:

        sudo reboot
        
2.  **Test**:
    
    *   After rebooting, the Raspberry Pi should automatically log in, start the X server, launch Openbox, and open Chromium in kiosk mode displaying the specified webpage.