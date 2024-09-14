#!/bin/bash

# Check if Miniconda is installed
if [ -d "$HOME/miniconda3" ]; then
    # Prompt the user to confirm uninstallation
    read -p "Are you sure you want to uninstall Miniconda? (y/n): " CONFIRM
    if [ "$CONFIRM" == "y" ]; then
        # Uninstall Miniconda
        sudo rm -rf "$HOME/miniconda3"
        echo "Miniconda removed successfully."
    fi
else
    echo "Miniconda is not installed."
fi