#!/usr/bin/env bash

# This is a client script that will find the plushu server for the working
# Git repository, and then run any commands given to it on that server via SSH.
# To install, add it as an executable script in your local ~/bin directory
# under the name you want to call it as.

# The name of the user / remote.
# Changing this to "dokku" will make a client script for dokku.
# (If making a client script for Dokku, you'll probably also want to disable
# the implicit "--app" below.)
servname="plushu"

# Set the "REMOTE" variable according to any "remote" command-line arg.
case "$1" in
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
# By default, the remote name is $servname ("plushu"):
# you can change that here.
REMOTE=${REMOTE:-$servname}
remote_url=$(git config --get remote.$REMOTE.url)

if [[ "$?" -ne 0 ]]; then
  echo "Remote \"$REMOTE\" not found"
  exit 1
fi

# Safety check that the remote user name is the same as the expected service
if [[ "${remote_url%%@*}" != "$servname" ]]; then
  echo "Remote \"$REMOTE\" does not appear to be a $servname server"
  exit 1
fi

# The hostname to connect to.
host=${remote_url%:*}

# The name of the repo on the remote.
remote_repo=${remote_url##*:}

# The name of the app to implicitly define via the "--app" option.
# Undefine this to disable. (Not supported by Dokku.)
APP=${APP-${remote_repo%.git}}

if [[ -n "$APP" ]]; then
  set -- "--app=$APP" "$@"
fi

ssh -qt "$host" -- "$(printf '%q ' "$@")"
