# ezvm local update directory

In order to get `ezvm-updates` metadata to work, you must keep the [get-update-list]
script in this directory.

Any other scripts that you add in this directory are considered GLOBAL and will run
regardless of the `ezvm-updates` list.

Empty list?  Run GLOBAL.

Non-empty list?  Run GLOBAL, then run the list.

You can customize the order in which it runs things by modifying [get-update-list].
The order it outputs the files is the order in which ezvm runs them.
