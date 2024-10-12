# WayBak - Waydroid Backup & Restore Utility

WayBak is a utility script designed for backing up and restoring Waydroid data. The script allows you to:
- Create compressed backups of Waydroid's important directories.
- Restore Waydroid from a selected backup.
- Manage backup settings (backup directory and Waydroid username).

## Features
- Back up Waydroid's local, var, and etc directories to a specified backup directory.
- Automatically generates unique backup filenames based on the date and time.
- Restores from a list of available backups.
- Allows you to set and update the backup directory and Waydroid username.
- Cleans up Waydroid directories (optional) before restoring.

## Requirements
- Waydroid must be installed and set up on your system.
- Root permissions are required to perform the backup and restore operations.

## Usage

### Main Menu Options
When you run the script without any arguments, you will be presented with a menu:

```
===== WayBak Menu =====
1) Backup
2) Restore
----
Optional Settings:
3) Set Backup Directory [current: /your/backup/directory]
4) Set Username [current: your_username]
5) Help
6) Exit
```

- **Backup**: Create a new backup of your Waydroid data. The script will generate a backup tarball in the specified backup directory.
- **Restore**: Restore Waydroid from a selected backup tarball.
- **Set Backup Directory**: Change the directory where backups will be saved. If no directory is set, the default is `./backups`.
- **Set Username**: Set the Waydroid username (used to determine the path to Waydroid's local data).
- **Help**: Display usage information.
- **Exit**: Exit the script.

### Prerequisites
Before using the **Backup** and **Restore** options, make sure that both the **Backup Directory** and **Username** are set. You can configure these settings via options 3 and 4 in the menu.

### Backup Process
1. Choose option `1) Backup` from the menu.
2. A unique backup filename will be generated (e.g., `waybak_2024-10-12_14-10-48.tar.gz`).
3. You will be prompted to either keep the generated filename or input a new one. You don't need to include the `.tar.gz` extension manually.
4. The script will create a backup tarball in the configured backup directory, compressing Waydroid's data directories.

### Restore Process
1. Choose option `2) Restore` from the menu.
2. A list of available backup files in the backup directory will be displayed.
3. Select the backup you want to restore.
4. You will be prompted if you want to clean up existing Waydroid files before restoring.
5. The selected backup will be restored, and Waydroid will be reconfigured with the restored data.

### Set Backup Directory
1. Choose option `3) Set Backup Directory`.
2. The current backup directory (if set) will be displayed. You can edit it or provide a new directory path.
3. If the directory does not exist, you will be asked if you want to create it.
4. The backup directory will be updated and saved in the configuration.

### Set Username
1. Choose option `4) Set Username`.
2. The current username (if set) will be displayed. You can edit it or provide a new username.
3. The script will check if the corresponding Waydroid directory exists (`/home/your_username/.local/share/waydroid`). If the directory does not exist, you will be warned and prompted to enter a valid username.

## Command-Line Usage

The script also supports command-line options:

```
./waybak.sh [OPTIONS]

Options:
  -b, --backup                Perform a backup
  -r, --restore               Perform a restore
      --set-dir <directory>   Set a new backup directory
      --set-username <name>   Set a new username for Waydroid
  -h, --help                  Display this help message
```

### Examples:

1. **Backup Waydroid**:
   ```
   sudo ./waybak.sh --backup
   ```

2. **Restore Waydroid**:
   ```
   sudo ./waybak.sh --restore
   ```

3. **Set a new backup directory**:
   ```
   ./waybak.sh --set-dir /path/to/new/backup_directory
   ```

4. **Set a new username**:
   ```
   ./waybak.sh --set-username new_username
   ```

### Notes
- Both the backup directory and username must be set before running backup or restore.
- The backup tarballs are automatically compressed as `.tar.gz` files.
- Make sure to run the script with `sudo` since root permissions are required for the backup and restore operations.

