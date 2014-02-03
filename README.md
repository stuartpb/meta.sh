# meta.sh(1)

A curl-able repository of shell scripts

## USAGE

The root meta.sh index serves a script to non-browser UAs that will download
any script on meta.sh and prompt for review/editing before execution. For
example, if you wanted to install dogecoind on Ubuntu using the script
available on meta.sh, you could request the script for editing and review like
so:

```bash
bash <(curl meta.sh) setup/dogecoin/ubuntu
```

Since piping the output from an untrusted command directly into bash is a
pretty wildly reckless thing to do, it's recommended that you download the
meta.sh index script locally first, review it manually, then save it somewhere
like your home bin directory so that you don't have to trust the remote every
time you request a script from meta.sh. See
[meta.sh/install](http://meta.sh/install) for a guide.

On the other side of recklessness, the contents of all scripts on meta.sh are
accessible directly, so if you're confident that you don't need to review a
script before you pipe it into bash, you can just request it directly. For
example, to use aur.sh:

```bash
bash <(curl meta.sh/aur) -si packer
```
