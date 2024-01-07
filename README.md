# NAS-Storage-Automation

The Bash scripts are designed to automate the setup of Network Attached Storage (NAS) between Linux systems. It facilitates the automatic backup of directories between client and server systems with a user-friendly menu-based interface. The script is compatible with all Ubuntu and RedHat-based Linux distributions, supporting both local area network (LAN) and internet (cloud) connections. It also enables many-to-many mesh connections between the server and client.

## Features
- **Menu-based Interface:** A user-friendly menu system simplifies the setup and uninstallation process.
- **Automatic Setup:** Automates the setup of storage servers between Linux systems.
- **Cloud Support:** Allows for NAS configuration on cloud virtual machines.
- **Periodic Backups:** Facilitates automatic periodic backups with customizable scheduling options.
- **Compatibility:** Works seamlessly with Ubuntu and RedHat-based Linux distributions.

## Prerequisites
**figlet:** ASCII font manipulation tool used for a stylish display.

## Usage
Download the script:
```bash
git clone https://github.com/Shrit-Shah/NAS-Automation_Bash.git
```
Make the script executable:
```bash
chmod +x NAS.sh
```
Run the script:
```bash
./NAS.sh
```
![image](https://github.com/Shrit-Shah/NAS-Automation_Bash/assets/45697885/5262630a-2d7f-4189-a6a4-c038b5c9d4f5)

Setup Instructions
Follow the on-screen menu options to set up your storage server. Choose the appropriate options for LAN or cloud setup and provide necessary details when prompted.

Uninstallation
If you need to uninstall the NAS configuration, select the corresponding option from the main menu. The script will guide you through the uninstallation process.

## Note
Uninstallation: Uninstalling the NAS configuration on the client side does not delete the backup data on the server drive.


Feel free to contribute or report issues!
