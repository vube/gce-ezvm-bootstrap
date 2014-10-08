# ezvm-local Directory

This is the ezvm-local directory.

The `publish.sh` script will make an archive out of this directory and its contents.

The `bootstrap.sh` will copy the archive onto new VM images and unzip it into the
`/usr/local/ezvm/etc/local` directory.

Then every time you `ezvm update` on the VM, your update procedure will be run.

Generally speaking the `bootstrap.sh` will `ezvm update` the first time the machine
comes up, and you won't ever need to do it again.  However it can be useful to manually
run `sudo ezvm update` on your VM to debug your update procedure during development.

# Files

## lib.sh

This is a set of common routines that you can/should use by your update scripts.
It's optional but recommended.  Look through there to see what the sub-routines do.

## self-update-hook

This is only really needed if you are developing/debugging your update procedure.

If you run `sudo ezvm update -s` then ezvm will update itself, including this, the
contents of its ezvm-local directory.  It doesn't know how to update this directory,
so it executes the `self-update-hook` here in ezvm-local.

This script just downloads the new bootstrap archive archive from Google Cloud Storage,
the same basic thing that the `bootstrap.sh` did.

In production you can optionally remove this file; that would stop `ezvm` from ever
updating the contents of this ezvm-local directory.
