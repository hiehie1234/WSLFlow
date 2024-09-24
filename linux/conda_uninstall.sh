#!/bin/bash
HOUSE="`cat /etc/passwd |grep ^${SUDO_USER:-$(id -un)}: | cut -d: -f 6`"
HOUSE=${HOUSE:-$HOME}

# Check if Miniconda is installed
if [ -d "$HOUSE/miniconda3" ]; then
    # Prompt the user to confirm uninstallation
    read -p "Are you sure you want to uninstall Miniconda? (y/n): " CONFIRM
    if [ "$CONFIRM" == "y" ]; then
        # Uninstall Miniconda
        sudo rm -rf "$HOUSE/miniconda3"
        echo "Miniconda removed successfully."
    fi
else
    echo "Miniconda is not installed. "
fi