# salt-master update procedure

The scripts in this directory *are not executed* by ezvm by default.

If/when you want to run these, you must specify `ezvm-updates=salt-master` in your
VM instance's metadata before it executes the [bootstrap.sh](../../../scripts/bootstrap.sh)
startup script.
