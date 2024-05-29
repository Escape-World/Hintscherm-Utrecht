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
    
3.  **Navigate to the Repository Directory**:

```bash
cd Hintscherm-Utrecht
```
    
4.  **Make the Script Executable**:

```bash
chmod +x setup-hintscherm.sh
```
    
5.  **Run the Script**:

```bash
./setup-hintscherm.sh
```
    
5.  **Follow On-Screen Instructions**: 
The script will prompt for the URL to display and then proceed with the setup. The Raspberry Pi will reboot once the setup is complete.