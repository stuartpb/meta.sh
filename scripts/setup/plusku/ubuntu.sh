#!/usr/bin/env bash

if [[ $EUID != 0 ]]; then
  echo "You need to be root to install Plusku" >&2
  exit 1
fi

# Install Plusku dependencies
curl -s https://get.docker.io/ubuntu/ | sh
add-apt-repository -y ppa:nginx/stable
apt-get update
apt-get install -y nginx dnsutils

# Install Plushu
git clone https://github.com/plushu/plushu /home/plushu
/home/plushu/install.sh

# Install Plusku
plushu plugins:install plusku
