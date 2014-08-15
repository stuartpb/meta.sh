#!/usr/bin/env bash

if [[ $EUID != 0 ]]; then
  echo "You need to be root to install Plusku" >&2
  exit 1
fi

# Install Plusku dependencies
pacman --noconfirm -Syu
pacman --noconfirm --needed -S docker nginx git
systemctl enable docker nginx
systemctl start docker nginx

# Install Plushu
git clone https://github.com/plushu/plushu /home/plushu
/home/plushu/install.sh

# Install Plusku
plushu plugins:install plusku
