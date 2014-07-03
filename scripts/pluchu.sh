#!/usr/bin/env bash

# This is a client script that will find the plushu server for the working
# Git repository, and then run any commands given to it on that server via SSH.
# To install, add it as an executable script in your local ~/bin directory
# under the name you want to call it as.

# The name of the user / remote.
# Changing this to "dokku" will make a client script for dokku.
SERVNAME="plushu"

# Set the "REMOTE" variable according to any "remote" command-line arg.
case $1 in
  --remote)
    shift
    REMOTE=$1
    shift
    ;;
  --remote=*)
    REMOTE=${1#--remote=}
    shift
esac

# The name of the Git remote to read the server URL from.
# By default, the remote name is $SERVNAME ("plushu"):
# you can change that here.
REMOTE=${REMOTE:-$SERVNAME}
REMOTE_URL=$(git config --get remote.$REMOTE.url)

if [ $? -ne 0 ]; then
    echo "Remote \"$REMOTE\" not found"
    exit 1
fi

# Safety check that the remote user name is the same as the expected service
if [ ${REMOTE_URL%%@*} != $SERVNAME ]; then
    echo "Remote \"$REMOTE\" does not appear to be a $SERVNAME server"
    exit 1
fi

REMOTE_HOST=${REMOTE_URL%%:*}
ssh -t "$REMOTE_HOST" "$@"
