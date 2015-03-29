# ezvm local update directory

In order to get `ezvm-updates` metadata to work, you must keep the [get-update-list](get-update-list)
script in this directory.

Any other scripts that you add in this directory are considered GLOBAL and will run
regardless of the `ezvm-updates` list.

Empty list?  Run GLOBAL.

Non-empty list?  Run GLOBAL, then run the list.

You can customize the order in which it runs things by modifying [get-update-list](get-update-list).
The order it outputs the files is the order in which ezvm runs them.

## Recommended ezvm-updates for a salt master server:

`"ezvm-updates=salt-common salt-master gce-startup-reset"`

Note: We don't specify `salt-highstate` here, since when creating a salt master, there is no master
to connect to to get the configs!  So you'll want to login manually, install your salt configs,
and then manually run a highstate.

We `gce-startup-reset` to remove the bootstrap process from the VM startup, so when you reboot
the VM it won't keep bootstrapping itself.

## Recommended ezvm-updates for a salt minion server:

`"ezvm-updates=salt-common salt-minion salt-highstate gce-startup-reset"`

Note: Here we automatically run `salt-highstate` on the minion, as we expect that the master already
exists and can serve us configs when the minion comes online.

We `gce-startup-reset` to remove the bootstrap process from the VM startup, so when you reboot
the VM it won't keep bootstrapping itself.
