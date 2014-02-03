#!/bin/bash

# By default, install to your home directory
${INSTALL_BASE=${1-$HOME/bin}}

# You can use a different name than "meta.sh" if you want
${INSTALL_NAME:=meta.sh}

INSTALL_PATH="$INSTALL_BASE/$INSTALL_NAME"

# Create the destination directory if it doesn't already exist
mkdir -p "$INSTALL_BASE"

# Download meta.sh to the install location
curl http://meta.sh/index.sh > "$INSTALL_PATH"

# Inspect the script
$EDITOR "$INSTALL_PATH"

# Set the downloaded script executable
chmod +x $INSTALL_PATH

echo "meta.sh has been installed to $INSTALL_PATH"
echo "Make sure $INSTALL_BASE is exported to your PATH"
echo "in ~/.profile or ~/.bashrc as relevant."
