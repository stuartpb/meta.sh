# pluchu

Client script for running commands on a plushu Git remote

This script allows you to run `plushu` commands in a Git repository with a
remote that is named "plushu" without having to specify the server.

This imitates the workflow of the Heroku toolbelt, which sends commands to the
Heroku servers for the app specified by the "heroku" remote.

This is just a small convenience command to make this specific use case
slightly less verbose: you don't actually have to install this script to run
commands on a plushu server.

## Usage / installation

Place the `pluchu` script into your home bin directory (or anywhere on your
$PATH), with whatever filename you wish (for example, you could use `plushu` if
you want to use the exact same command name on the client and server, or
`pluchu` if you want to install the client script on a plushu server where the
executable name `plushu` is already taken).

Then, in a Git repository that has had a plushu remote added (like so, for
instance):

    git remote add plushu plushu@example.com:myapp

You can run plushu commands on that server by calling this client script (named
`pluchu` in this example):

    pluchu domains

In this example repository, this line is functionally equivalent to:

    ssh -qt plushu@example.com -- --app=myapp domains
