#!/bin/bash

# Exit on any error
set -e

# Check if running with sudo/root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to be run with sudo privileges" >&2
    exit 1
fi

# Check if /usr/local/bin exists
if [ ! -d "/usr/local/bin" ]; then
    echo "Directory /usr/local/bin does not exist. Creating it..."
    mkdir -p /usr/local/bin
fi

# Counter for installed scripts
installed=0
errors=0

# Find all .sh files in current directory
for script in *.sh; do
    # Check if any .sh files exist
    if [ ! -e "$script" ]; then
        echo "No .sh files found in current directory"
        exit 1
    fi
    
    # Get the base name without .sh
    base_name=$(basename "$script" .sh)
    target="/usr/local/bin/$base_name"
    
    echo "Processing $script..."
    
    # Check if file is executable
    if [ ! -x "$script" ]; then
        echo "Making $script executable..."
        chmod +x "$script"
    fi
    
    # Check if target already exists
    if [ -e "$target" ]; then
        echo "Warning: $target already exists. Skipping..."
        ((errors++))
        continue
    fi
    
    # Create symbolic link
    echo "Creating symbolic link for $script as $base_name in /usr/local/bin..."
    ln -s "$(pwd)/$script" "$target"
    ((installed++))
done

echo "Installation complete."
echo "$installed script(s) installed successfully."
if [ $errors -gt 0 ]; then
    echo "$errors script(s) skipped due to existing targets."
fi
