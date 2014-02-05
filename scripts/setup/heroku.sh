#!/bin/bash

HEROKU_CLIENT_URL="https://s3.amazonaws.com/assets.heroku.com/heroku-client/heroku-client.tgz"

DEST=$HOME/.heroku

mkdir -p $DEST
cd $DEST
curl $HEROKU_CLIENT_URL | tar xz
mv heroku-client client

mkdir -p $HOME/bin
ln -s $DEST/client/bin/heroku $HOME/bin/heroku

echo "Installation complete"
