# Heroku client toolbelt installation

This script will install the Heroku toolbelt to your home directory (as the
`heroku update` command does), no root privileges required.

It also creates a symbolic link to the `heroku` script in your private bin
directory. This allows you to use the `heroku` command from the command line,
under the assumption that your $PATH already includes your private bin
directory if present. If your `~/.profile` doesn't contain a stanza that looks
like the following snippet (or if the file doesn't exist), you will need to add
it:

```bash
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
```

For this stanza to take effect, you will either need to log out and then back
in, or force your shell to reload its login source configuration. You can
reload your shell by running a command like this one, for bash:

```bash
exec -l bash
```
