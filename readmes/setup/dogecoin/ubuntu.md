# Compiling and Installing dogecoind on Ubuntu

## Usage

This script can be reviewed and executed by running:

```bash
$ bash <(curl meta.sh) setup/dogecoin/ubuntu
```

## Post-installation

You need to be running as a user with access to /home/dogecoin (so either
`root` or `dogecoin` via `sudo`) to interact with the Dogecoin daemon.

To list all available functions of the Dogecoin daemon, run:

```bash
/home/dogecoin/bin/dogecoind help
```

After you first start dogecoind, it will take a while (about an hour as of
February 2014) to download the blockchain. Use

```bash
/home/dogecoin/bin/dogecoind getinfo
```

and look at the "blocks" entry to see how many blocks have been downloaded. No
transactions will be processed until the blockchain is synchronized.

## Attribution

This script has its origins in the [Compiling Dogecoind on Ubuntu/Debian][1]
article on the Dogecoin wiki.

[1]: http://www.dogeco.in/wiki/index.php/Compiling_Dogecoind_on_Ubuntu/Debian
