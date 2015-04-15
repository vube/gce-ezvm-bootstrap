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

`"ezvm-updates=salt-master gce-startup-reset"`

We `gce-startup-reset` to remove the bootstrap process from the VM startup, so when you reboot
the VM it won't keep bootstrapping itself.

### Implicit salt-master updates

When you execute the `salt-master` update, it implicitly executes the `salt-common` update before `salt-master`.

## Recommended ezvm-updates for a salt minion server:

`"ezvm-updates=salt-minion gce-startup-reset"`

We `gce-startup-reset` to remove the bootstrap process from the VM startup, so when you reboot
the VM it won't keep bootstrapping itself.

### Implicit salt-minion updates

When you execute the `salt-minion` update, it implicitly executes the following updates in this order:

- `salt-common`
- `salt-minion`
- `salt-minion-reset`
- `salt-highstate`

## Recommended ezvm-updates for a salt minion server created from an existing minion image:

`"ezvm-updates=salt-minion-reset salt-highstate gce-startup-reset"`

Note that we DO NOT install/update `salt-minion` in this case, since it's already there on the
existing minion image that we cloned.

We do however need to `salt-minion-reset`, which clears out the key in the master and makes room
for the new key.

And we need to explicitly `salt-highstate` to recompute configs and bring the application up to
date with any changes that may have been made since the image was last snapshot.

We `gce-startup-reset` to remove the bootstrap process from the VM startup, so when you reboot
the VM it won't keep bootstrapping itself.
