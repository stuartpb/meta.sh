#!/usr/bin/env bash

if [[ $EUID != 0 ]]; then
  echo "You need to be root to install Plusku" >&2
  exit 1
fi

# Determine distro
distro=`[[ -f /etc/os-release ]] &&
  sed -n 's/^ID=\(.*\)$/\1/p' /etc/os-release`

case "$distro" in
  arch)
    # update the system
    pacman -Syu --noconfirm

    # Add dependencies
    pacman -S --noconfirm --needed sudo git docker

    # Set up and start services
    systemctl enable docker
    systemctl start docker
    ;;

  ubuntu)
    # Get Docker
    curl -s https://get.docker.io/ubuntu/ | sh

    # Update apt-get lists
    apt-get update

    # Install other dependencies
    apt-get install -y git dnsutils
    ;;
  *)
    echo "This setup script does not support this distro." >&2
    exit 1
    ;;
esac

# Install Plushu
git clone https://github.com/plushu/plushu /home/plushu
/home/plushu/install.sh

# Install Plusku
plushu plugins:install plusku
