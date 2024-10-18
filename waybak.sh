#!/usr/bin/env bash

# Waybak - Simple Waydroid Backup and Restore Tool

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Default backup directory relative to script's path
BACKUP_DIR="$SCRIPT_DIR/backups"

# Waydroid data directories
WAYDROID_USER_HOME="$HOME/.local/share/waydroid"
WAYDROID_VAR="/var/lib/waydroid"
WAYDROID_ETC="/etc/waydroid-extra/images"

# Function to check if Waydroid is installed
check_waydroid_installed() {
  if ! command -v waydroid >/dev/null 2>&1; then
    echo "Waydroid is not installed. Please install it before running this script."
    exit 1
  fi
}

# Function to stop Waydroid session
stop_waydroid() {
  echo "Stopping Waydroid session..."
  sudo waydroid session stop || true
}

# Function to backup Waydroid data
backup_waydroid() {
  stop_waydroid
  echo "Starting backup..."

  mkdir -p "$BACKUP_DIR"

  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  BACKUP_FILE="$BACKUP_DIR/waydroid_backup_$TIMESTAMP.tar.gz"

  echo "Creating backup at $BACKUP_FILE..."

  sudo tar -czf "$BACKUP_FILE" \
    "$WAYDROID_USER_HOME" \
    "$WAYDROID_VAR" \
    "$WAYDROID_ETC" 2>/dev/null || true

  echo "Backup completed successfully."
}

# Function to restore Waydroid data
restore_waydroid() {
  stop_waydroid
  echo "Starting restore..."

  # Check for available backups
  shopt -s nullglob
  backups=("$BACKUP_DIR"/*.tar.gz)
  shopt -u nullglob

  if [ ${#backups[@]} -eq 0 ]; then
    echo "No backups found in $BACKUP_DIR."
    exit 1
  fi

  echo "Available backups:"
  select backup_file in "${backups[@]}"; do
    if [ -n "$backup_file" ]; then
      BACKUP_FILE="$backup_file"
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done

  # Confirmation prompt accepting 'y' or 'n' and re-prompting on invalid input
  while true; do
    echo -n "This will overwrite your current Waydroid data. Are you sure? (y/n): "
    read -r CONFIRM
    case "$CONFIRM" in
      y|Y)
        break
        ;;
      n|N)
        echo "Restore cancelled."
        return
        ;;
      *)
        echo "Invalid input. Please enter 'y' or 'n'."
        ;;
    esac
  done

  echo "Cleaning existing Waydroid data..."

  # Clean files within the directories but keep the directories themselves
  sudo rm -rf "$WAYDROID_USER_HOME/"* \
               "$WAYDROID_VAR/"* \
               "$WAYDROID_ETC/"*

  echo "Restoring from $BACKUP_FILE..."

  # Extract backup
  sudo tar -xzf "$BACKUP_FILE" -C /

  echo "Restore completed successfully."
}

# Function to display menu
show_menu() {
  echo
  echo "Waybak - Simple Waydroid Backup and Restore Tool"
  echo "-----------------------------------------------"
  echo "1) Backup"
  echo "2) Restore"
  echo "3) Exit"
  echo -n "Enter your choice [1-3]: "
  read -r choice
  case $choice in
    1) backup_waydroid ;;
    2) restore_waydroid ;;
    3) exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
}

# Main script logic
check_waydroid_installed

while true; do
  show_menu
done

