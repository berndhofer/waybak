# Waybak - Simple Waydroid Backup and Restore Tool

**Waybak** is a simple and minimalistic Bash script designed to help you easily back up and restore your Waydroid data. It provides a straightforward menu interface with essential prompts to guide you through the backup and restore processes.

## Features

- **Backup Waydroid Data**: Creates a compressed backup of your Waydroid data directories.
- **Restore Waydroid Data**: Restores your Waydroid data from a selected backup.
- **User-Friendly Menu**: Provides a simple menu for easy navigation.
- **Safe Operations**: Includes confirmations to prevent accidental data loss.
- **Minimal Dependencies**: Relies on standard Linux commands and utilities.

## Requirements

- **Operating System**: Linux (with Bash shell)
- **Waydroid**: Installed and configured
- **Bash**: Version supporting `select` and `read` commands
- **Permissions**: Ability to run `sudo` commands

## Installation

1. **Download the Script**

   Clone the repository from GitHub:

   ```bash
   git clone https://github.com/berndhofer/waybak.git
   ```

   Alternatively, you can download the `waybak.sh` script directly:

   ```bash
   wget -O waybak.sh https://github.com/berndhofer/waybak/raw/main/waybak.sh
   ```

2. **Make the Script Executable**

   ```bash
   chmod +x waybak.sh
   ```

3. **(Optional) Move the Script to a Directory in Your PATH**

   To run the script from any location, you can move it to `/usr/local/bin`:

   ```bash
   sudo mv waybak.sh /usr/local/bin/waybak
   ```

   > **Note**: Moving the script requires `sudo` privileges.

## Usage

Run the script from the terminal:

```bash
./waybak.sh
```

If you moved the script to a directory in your `PATH`, you can run it directly:

```bash
waybak
```

### Main Menu

Upon running the script, you'll see the following menu:

```
Waybak - Simple Waydroid Backup and Restore Tool
-----------------------------------------------
1) Backup
2) Restore
3) Exit
Enter your choice [1-3]:
```

Enter the number corresponding to the action you wish to perform.

### Backup Waydroid Data

1. **Select Option 1**: Enter `1` and press `Enter`.
2. **Backup Process**:
   - The script will stop any running Waydroid session.
   - It will create a backup of the Waydroid data directories.
   - The backup is saved as a compressed `.tar.gz` file in the `backups` directory located in the same directory as the script.
3. **Completion**: You'll receive a confirmation message once the backup is completed.

### Restore Waydroid Data

1. **Select Option 2**: Enter `2` and press `Enter`.
2. **Select a Backup**:
   - The script will display a numbered list of available backups.
   - Example:
     ```
     Available backups:
     1) /path/to/waybak/backups/waydroid_backup_20231014_123456.tar.gz
     2) /path/to/waybak/backups/waydroid_backup_20231013_101112.tar.gz
     ```
   - Enter the number corresponding to the backup you wish to restore.
3. **Confirm Restore**:
   - You'll be prompted to confirm the restore operation:
     ```
     This will overwrite your current Waydroid data. Are you sure? (y/n):
     ```
   - Enter `y` to proceed or `n` to cancel.
   - If you enter an invalid input, the script will prompt you again.
4. **Restore Process**:
   - The script will clean the existing Waydroid data directories (files within directories are deleted, directories remain).
   - It will extract the selected backup to restore your data.
5. **Completion**: You'll receive a confirmation message once the restore is completed.

### Exit

- **Select Option 3**: Enter `3` and press `Enter` to exit the script.

## Configuration

### Backup Directory

- **Default Location**: Backups are stored in the `backups` directory located in the same directory as the script.
- **Changing the Backup Directory**:
  - You can modify the `BACKUP_DIR` variable at the top of the script to change the backup directory.
  - Example:
    ```bash
    BACKUP_DIR="/path/to/your/desired/backup/location"
    ```

### Waydroid Data Directories

- The script backs up and restores the following Waydroid data directories by default:
  - User data: `$HOME/.local/share/waydroid`
  - System data: `/var/lib/waydroid`
  - Images: `/etc/waydroid-extra/images`
- **Custom Directories**:
  - If your Waydroid installation uses different directories, modify the corresponding variables in the script:
    ```bash
    WAYDROID_USER_HOME="/your/custom/path"
    WAYDROID_VAR="/your/custom/path"
    WAYDROID_ETC="/your/custom/path"
    ```

## Important Notes

- **Data Overwrite Warning**: Restoring a backup will overwrite your current Waydroid data. Ensure that you have backed up any important data before proceeding.
- **Permissions**: The script uses `sudo` for operations that require elevated privileges. Make sure you have `sudo` access.
- **Waydroid Session**: The script stops the Waydroid session before performing backup or restore operations to prevent data corruption.

## Troubleshooting

- **Waydroid Not Installed**: If you receive an error stating that Waydroid is not installed, install Waydroid first before using this script.
- **No Backups Found**: If no backups are found during restore, ensure that you have previously created backups and that they are located in the correct backup directory.
- **Script Errors**: Ensure that you have the necessary permissions and that all paths specified in the script are correct.

## License

This script is provided as-is without any warranty. Use it at your own risk.

## Contributing

Feel free to modify the script to suit your needs or contribute improvements.

## Acknowledgements

- **Waydroid**: Thanks to the Waydroid project for enabling Android environments on Linux systems.

---

**Disclaimer**: This script is a simple helper tool intended for personal use. Always exercise caution when performing backup and restore operations, especially when dealing with system-level data.

