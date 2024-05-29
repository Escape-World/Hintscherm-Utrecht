### 1\. Prepare Your Raspberry Pi

1.  **Install Raspberry Pi OS Lite x64**
2.  **Boot Raspberry and open a terminal or connect via SSH**

### 2\. Running the kiosk script

1. **Setup the Raspberry**

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

2.  **Clone the Repository**:
    
```bash
sudo apt install -y git
git clone https://github.com/Escape-World/Hintscherm-Utrecht.git
```

3.  **Run the Script**:

```bash
cd Hintscherm-Utrecht
chmod +x setup-hintscherm.sh
sudo ./setup-hintscherm.sh
```
    
4.  **Follow On-Screen Instructions**: 
The script will prompt for the URL to display and then proceed with the setup. The Raspberry Pi will reboot once the setup is complete.

### 3\. Setting the Pi in read-only mode

1. **Open config**

```bash
sudo raspi-config
```

2. **Set to read-only**

Navigate down to “Performance Options” and then “Overlay File System.” 
Select “Yes” to both the enable and write-protect questions.

It may take a minute or more while the system works, this is normal. 
Tab to the “Finish” button and reboot when prompted.