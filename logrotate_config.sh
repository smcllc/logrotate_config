#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check for dry-run flag
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "Running in dry-run mode - no changes will be made"
fi

# Directory containing logrotate configurations
CONFIG_DIR="/etc/logrotate.d"

# Backup directory (only created if not dry-run)
BACKUP_DIR="/etc/logrotate.d/backup-$(date +%Y%m%d_%H%M%S)"

# Function to process each config file
process_config() {
    local file="$1"
    local temp_file="/tmp/$(basename "$file").tmp"
    
    # Check if file is readable
    if [[ ! -r "$file" ]]; then
        echo "Skipping $file - insufficient permissions"
        return
    fi

    # Check if this is the wtmp config file - skip if it is
    local basename=$(basename "$file")
    if [[ "$basename" == "wtmp" ]]; then
         echo "Skipping $file - wtmp config excluded from processing"
    return
    fi    

    # Check if file is empty
    if [[ ! -s "$file" ]]; then
        echo "Skipping $file - empty file"
        return
    fi

    # Create backup if not in dry-run mode
    if [[ "$DRY_RUN" != true ]]; then
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
    fi

    # Create temporary file and process it
    if grep -q "rotate" "$file"; then
        sed 's/rotate [0-9]*/rotate 6/' "$file" > "$temp_file"
    else
        sed '/\/var\/log/ a\    rotate 6' "$file" > "$temp_file"
    fi
    
    # Handle maxage
    if grep -q "maxage" "$temp_file"; then
        sed -i 's/maxage [0-9]*/maxage 60/' "$temp_file"
    else
        sed -i '/rotate 6/ a\        maxage 60' "$temp_file"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "Would update: $file"
        echo "Proposed changes:"
        diff "$file" "$temp_file" || echo "  No changes needed"
        rm "$temp_file"
    else
        mv "$temp_file" "$file"
        echo "Updated: $file"
    fi
}

# Main processing loop
echo "Processing logrotate configurations..."
if [[ "$DRY_RUN" != true ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "Backups stored in: $BACKUP_DIR"
else
    echo "In dry-run mode, backups would be stored in: $BACKUP_DIR"
fi

for config_file in "$CONFIG_DIR"/*; do
    if [[ -f "$config_file" && "$(basename "$config_file")" != "wtmp" ]]; then
        process_config "$config_file"
    fi
done

echo "Configuration processing complete."
if [[ "$DRY_RUN" != true ]]; then
    # Verify the changes (only in non-dry-run mode)
    echo "Verifying changes..."
    for config_file in "$CONFIG_DIR"/*; do
        if [[ -f "$config_file" ]]; then
            echo "Checking $(basename "$config_file"):"
            grep -E "rotate|maxage" "$config_file" || echo "  No rotate/maxage settings found"
        fi
    done
    
    # Restart logrotate service if it exists and not dry-run
    if systemctl is-active logrotate >/dev/null 2>&1; then
        systemctl restart logrotate
        echo "Logrotate service restarted"
    fi
else
    echo "Dry run complete - no changes were made"
fi

exit 0