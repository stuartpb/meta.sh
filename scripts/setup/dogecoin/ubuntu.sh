#!/bin/bash

apt-get update && apt-get upgrade
apt-get install ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev

curl http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz |tar -xz
cd miniupnpc-1.8/
make
make install
cd ..

git clone https://github.com/dogecoin/dogecoin

# TODO: determine if swapfile is needed and automatically make it if so

cd dogecoin/src
make -f makefile.unix USE_UPNP=1 USE_QRCODE=1
strip dogecoind

adduser dogecoin && usermod -g users dogecoin && delgroup dogecoin && chmod 0701 /home/dogecoin
mkdir /home/dogecoin/bin
cp ~/dogecoin/src/dogecoind  /home/dogecoin/bin/dogecoind
chown -R dogecoin:users /home/dogecoin/bin
cd && rm -rf dogecoin

su dogecoin
cd && bin/dogecoind

read -p "Enter RPC username for config: " username
read -p "Enter RPC password for config: " password

cat >~/.dogecoin/dogecoin.conf <<EOF
daemon=1
rpcuser=$username
rpcpassword=$password
rpcthreads=100
irc=0
dnsseed=1
EOF

chmod 0600 ~/.dogecoin/dogecoin.conf
dogecoind
