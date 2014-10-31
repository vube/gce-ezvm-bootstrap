# Files

## bootstrap-salt.sh

Downloaded from [https://bootstrap.saltstack.com](https://bootstrap.saltstack.com), this is a cached
copy of the salt installer.

We must periodically update this to ensure we're installing Salt correctly.  The alternative is we can
install Salt from packages, but that doesn't work very well since it is under active development and
the packages are often outdated.

## saltstack.gpg

[saltstack.gpg](saltstack.gpg) is the SaltStack Debian packages public key.

I fetched it with the
following command, feel free to update it if you feel the need:

`wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" > saltstack.gpg`

Installation instructions (and that command) are [documented here](http://docs.saltstack.com/en/latest/topics/installation/debian.html).

`saltstack.gpg` is used by [1000-saltstack-apt-sources](../local/update/salt-master/1000-saltstack-apt-sources)
