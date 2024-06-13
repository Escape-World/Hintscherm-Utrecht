# Raspberry Setup

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
./setup-hintscherm.sh
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


# Ubuntu Setup

### 1\. Install Ubuntu

Install Ubuntu LTS (tested on 24.04)

### 2\. Running the kiosk script

1.  **Clone the Repository**:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Escape-World/Hintscherm-Utrecht.git
```

2.  **Run the script**:

```bash
cd Hintscherm-Utrecht/Ubuntu
chmod +x setup-kiosk.sh
sudo ./setup-kiosk.sh
```

3.  **Follow On-Screen Instructions**: 
The script will prompt for the URL to display and then proceed with the setup. Ubuntu will reboot once the setup is complete.
Ubuntu will automatically be set to read only. After the script is done, you cannot change any settings and not revert setting it in read-only. 