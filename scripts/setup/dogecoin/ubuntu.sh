#!/bin/bash

# Change to a temporary directory to download source
${SOURCE_DIR=`mktemp -d`}
cd "$SOURCE_DIR"

# Update and install dependency packages
sudo apt-get update && apt-get upgrade
sudo apt-get install ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev

# Download and build the packageless miniupnpc dependency
curl http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz |tar -xz
cd miniupnpc-1.8/
make
sudo make install
cd ..

# Download the dogecoind source
git clone https://github.com/dogecoin/dogecoin

# TODO: determine if swapfile is needed and automatically make it if so

# Enter the source directory and build dogecoind
cd dogecoin/src
make -f makefile.unix USE_UPNP=1 USE_QRCODE=1
strip dogecoind

# Make the user for dogecoind and install the binary for the new user
sudo useradd -mN dogecoin
sudo chmod 0700 /home/dogecoin
sudo mkdir /home/dogecoin/bin
sudo cp ~/dogecoin/src/dogecoind /home/dogecoin/bin/dogecoind
sudo chown -R dogecoin:users /home/dogecoin/bin

# Delete the (no longer needed) source files
cd && rm -rf "$SOURCE_DIR"

# As the daemon user:
sudo -u dogecoin bash <<END_SUDO

# Run the command once without a config to get a suggested username/password
cd && bin/dogecoind

read -p "Enter RPC username for config: " username
read -p "Enter RPC password for config: " password

# Write an initial config
cat >~/.dogecoin/dogecoin.conf <<EOF
daemon=1
rpcuser=$username
rpcpassword=$password
rpcthreads=100
irc=0
dnsseed=1
EOF

# Set the config file to owner-rw only
chmod 0600 ~/.dogecoin/dogecoin.conf

# Start the daemon downloading the blockchain with the new conf
dogecoind &

# Exit daemon user context
END_SUDO
