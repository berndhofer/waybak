#!/usr/bin/env bash

set -euo pipefail  # Exit on errors, unset variables, and failed pipes

# Get the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Config file to save user preferences for backup directory and username
CONFIG_FILE="${SCRIPT_DIR}/config.conf"

# Default settings
DEFAULT_BACKUP_ROOT="${SCRIPT_DIR}/backups"
DEFAULT_USERNAME="${USER}"  # Default username from system environment

# Function to read the backup directory and username from the config file
read_config() {
  if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
  else
    BACKUP_ROOT=""
    USERNAME=""
  fi
}

# Function to save the backup directory and username to the config file
save_config() {
  cat <<EOF > "${CONFIG_FILE}"
BACKUP_ROOT="${BACKUP_ROOT}"
USERNAME="${USERNAME}"
EOF
  echo "Configuration saved to: ${CONFIG_FILE}"
}

# Function to initialize Waydroid paths based on the username
initialize_waydroid_paths() {
  if [[ -n "${USERNAME:-}" ]]; then
    WAYDROID_LOCAL="/home/${USERNAME}/.local/share/waydroid"
    WAYDROID_VAR="/var/lib/waydroid"
    WAYDROID_ETC="/etc/waydroid-extra/images"
  else
    echo "Error: Username is not set."
    exit 1
  fi
}

# Call read_config at the start to load the config
read_config

# Ensure backup directory and username are set before running functions
check_config() {
  if [[ -z "${BACKUP_ROOT:-}" || -z "${USERNAME:-}" ]]; then
    return 1  # Not set
  else
    return 0  # Config is set
  fi
}

# Ensure the backup directory exists
ensure_backup_dir() {
  if [[ ! -d "${BACKUP_ROOT}" ]]; then
    mkdir -p "${BACKUP_ROOT}" || {
      echo "Failed to create backup directory: ${BACKUP_ROOT}"
      exit 1
    }
  fi
}

# Function to stop the Waydroid session
stop_waydroid_session() {
  echo "Stopping Waydroid session..."
  waydroid session stop || {
    echo "Failed to stop Waydroid session."
    exit 1
  }
}

# Function to create a unique backup tar file name and allow the user to edit
generate_backup_filename() {
  local datetime
  datetime=$(date +'%Y-%m-%d_%H-%M-%S')
  local filename="waybak_${datetime}"  # Filename without ".tar.gz"

  # Show the generated filename without .tar.gz and allow the user to edit it
  read -p "Generated backup filename is: ${filename}. Press Enter to keep it or input a new filename: " custom_filename
  custom_filename="${custom_filename:-${filename}}"  # Use the default if the user presses Enter

  # Append ".tar.gz" if the user didn't add it
  if [[ "${custom_filename}" != *.tar.gz ]]; then
    custom_filename="${custom_filename}.tar.gz"
  fi

  # Return the full path by appending the BACKUP_ROOT directory to the filename
  echo "${BACKUP_ROOT}/${custom_filename}"
}

# Backup function
backup() {
  stop_waydroid_session

  echo "Starting backup process..."

  # Initialize Waydroid paths based on the current username
  initialize_waydroid_paths

  ensure_backup_dir  # Make sure backup directory exists

  # Generate and edit backup tarball name
  backup_file=$(generate_backup_filename)

  # Perform the backup into a tar.gz file
  echo "Creating backup tarball..."
  sudo tar -czvf "${backup_file}" -C / "${WAYDROID_LOCAL}" "${WAYDROID_VAR}" "${WAYDROID_ETC}" || {
    echo "Failed to create the backup."
    return 1
  }

  echo "Backup completed successfully and saved to ${backup_file}."
}

# Function to optionally clean up existing files in Waydroid directories
optional_cleanup() {
  echo -n "Do you want to clean up existing Waydroid files before restoring? (y/n): "
  read -r cleanup_choice
  if [[ "${cleanup_choice}" == "y" || "${cleanup_choice}" == "Y" ]]; then
    echo "Cleaning up existing Waydroid files..."
    cleanup_directory "${WAYDROID_LOCAL}"
    cleanup_directory "${WAYDROID_VAR}"
    cleanup_directory "${WAYDROID_ETC}"
  else
    echo "Skipping cleanup."
  fi
}

# Cleanup function to remove existing files in directories and ensure the directories are empty
cleanup_directory() {
  local dir="$1"
  
  # Remove files and subdirectories
  echo "Removing all files in ${dir}..."
  sudo rm -rf "${dir}/"*
  
  # Check if the directory is now empty
  if [ -z "$(ls -A "${dir}")" ]; then
    echo "Cleanup successful: ${dir} is now empty."
  else
    echo "Error: ${dir} is not empty after cleanup."
    return 1
  fi
}

# Function to list backup files and allow the user to choose one
choose_backup_file() {
  echo "Searching for backup files in ${BACKUP_ROOT}..."

  # List .tar.gz files sorted by modified date, latest on top
  backup_files=($(ls -t "${BACKUP_ROOT}"/*.tar.gz 2>/dev/null))

  if [ ${#backup_files[@]} -eq 0 ]; then
    echo "No backup files found in ${BACKUP_ROOT}."
    return 1
  fi

  echo "Available backup files (latest first):"

  PS3="Choose a file number to restore: "
  select selected_file in "${backup_files[@]}"; do
    if [[ -n "${selected_file}" ]]; then
      backup_file="${selected_file}"  # Correctly assign the selected file to the variable
      break
    else
      echo "Invalid selection, please try again."
    fi
  done
}

# Restore function
restore() {
  stop_waydroid_session

  echo "Starting restore process..."

  # Initialize Waydroid paths based on the current username
  initialize_waydroid_paths

  choose_backup_file  # List and choose backup file

  optional_cleanup  # Optionally clean up Waydroid directories

  # Ensure the selected backup file exists
  if [[ ! -f "${backup_file}" ]]; then
    echo "Error: Backup file ${backup_file} does not exist."
    return 1
  fi

  # Extract the tarball and restore files to each specific folder
  echo "Restoring backup from tarball: $(basename "${backup_file}")..."
  sudo tar -xzvf "${backup_file}" -C / || {
    echo "Failed to restore from ${backup_file}"
    return 1
  }

  echo "Restore completed successfully."
}

# Menu to set a new backup directory and save it
set_backup_dir() {
  while true; do
    # Pre-fill the current backup directory in the prompt for easy editing, fallback to DEFAULT_BACKUP_ROOT
    read -e -p "Enter the new backup directory path: " -i "${BACKUP_ROOT:-${DEFAULT_BACKUP_ROOT}}" new_dir

    if [[ -d "${new_dir}" ]]; then
      BACKUP_ROOT="${new_dir}"
      save_config
      echo "Backup directory set to: ${BACKUP_ROOT}"
      break
    else
      read -p "Warning: Directory does not exist. Do you want to create it? (y/n): " create_choice
      if [[ "${create_choice}" == "y" || "${create_choice}" == "Y" ]]; then
        mkdir -p "${new_dir}" || {
          echo "Failed to create directory: ${new_dir}"
          return 1
        }
        BACKUP_ROOT="${new_dir}"
        save_config
        echo "Backup directory created and set to: ${BACKUP_ROOT}"
        break
      else
        echo "Please enter a valid or existing directory."
      fi
    fi
  done
}

# Menu to set a new username and save it
set_username() {
  while true; do
    # Pre-fill the current username in the prompt, allowing for easy editing
    read -e -p "Enter your username for Waydroid: " -i "${USERNAME:-user}" new_username

    local new_waydroid_local="/home/${new_username}/.local/share/waydroid"
    if [[ -d "${new_waydroid_local}" ]]; then
      USERNAME="${new_username}"
      save_config  # Save the new username to the config file
      echo "Username updated to: ${USERNAME}"
      break
    else
      echo "Warning: The directory ${new_waydroid_local} does not exist. Please check the username."
    fi
  done
}

# Main menu to display options for backup, restore, and other settings
menu() {
  while true; do
    clear
    echo "===== WayBak Menu ====="

    # Display backup and restore only if config is complete
    if check_config; then
      echo "1) Backup"
      echo "2) Restore"
    fi

    # Show current settings in menu
    echo "----"
    echo "Optional Settings:"
    echo "3) Set Backup Directory [current: ${BACKUP_ROOT:-not set}]"
    echo "4) Set Username [current: ${USERNAME:-not set}]"
    echo "5) Help"
    echo "6) Exit"

    if check_config; then
      read -p "Enter your choice [1-6]: " choice
    else
      echo "Note: Backup directory and username must be set before Backup/Restore."
      read -p "Enter your choice [3-6]: " choice
    fi

    case $choice in
      1)
        if check_config; then
          backup
        else
          echo "Error: Both backup directory and username must be set before using backup."
        fi
        ;;
      2)
        if check_config; then
          restore
        else
          echo "Error: Both backup directory and username must be set before using restore."
        fi
        ;;
      3)
        set_backup_dir
        ;;
      4)
        set_username
        ;;
      5)
        usage
        ;;
      6)
        echo "Exiting script."
        exit 0
        ;;
      *)
        echo "Invalid option. Please try again."
        ;;
    esac
  done
}

# Parse command-line arguments or show menu if no arguments are given
if [[ $# -eq 0 ]]; then
  menu
else
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--backup)
        if check_config; then
          backup
        else
          echo "Error: Both backup directory and username must be set before using backup."
          exit 1
        fi
        ;;
      -r|--restore)
        if check_config; then
          restore
        else
          echo "Error: Both backup directory and username must be set before using restore."
          exit 1
        fi
        ;;
      --set-dir)
        shift
        if [[ $# -gt 0 ]]; then
          set_backup_dir "$1"
        else
          echo "Error: --set-dir requires a directory argument."
          return 1
        fi
        ;;
      --set-username)
        shift
        if [[ $# -gt 0 ]]; then
          set_username "$1"
        else
          echo "Error: --set-username requires a username argument."
          return 1
        fi
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
    shift
  done
fi

