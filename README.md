GCE ezvm Bootstrap
==================

Bootstrap a Google Compute Engine VM with ezvm

Why do this?  Well say you use SaltStack, Ansible, Chef or Puppet.  You need to install
those on the new VM image before you can actually use them right?

ezvm is a painless way to make that happen.  Just drop in your update files to `local/update`
and when you create the VM you bootstrap it with `bootstrap.sh`.  When the VM boots, it
runs your update procedure.

The last step of your update procedure should be running your node management software,
so fire up chef-client or whatever you want.  At that point, ezvm is out of the picture
and Chef is now in control of the machine.  Or Salt, or whatever floats your boat.

# Usage

## Initial Setup

- Fork or clone this repository.
- Configure URLs to match your project. (See [Configuration](#configuration) below)
- Add your ezvm update procedure to the [local/update](local/update) directory.

## Before Bootstrapping

IF you have changed the update procedure, on your local workstation, run

```bash
user@workstation:~/gce-ezvm-bootstrap$ scripts/publish.sh
```

## Each time you create a new VM instance

Create a new VM, bootstrap it with `bootstrap.sh` by setting the metadata `startup-script-url`
to be the URL of the bootstrap.sh script.

### Example VM creation command

```bash
gcloud compute --project "my-project" instances create "my-instance" --zone "us-central1-a" --machine-type "n1-highcpu-1" --network "default" --metadata "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__" --maintenance-policy "MIGRATE" --scopes "https://www.googleapis.com/auth/userinfo.email" "https://www.googleapis.com/auth/compute" "https://www.googleapis.com/auth/devstorage.read_write" --image "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140904"
```

For the above command to work, you must replace the following settings with your own:

    "my-project"
    "my-instance"
    "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__"

# Configuration

There are 2 settings that need to change before you can start using this.

These are used when you publish your new update procedure
up to cloud storage, and also when the VMs initialize themselves on creation.

## bootstrap.sh URL

This is the URL where you will store the `bootstrap.sh`.  It is automatically uploaded for you
by the publish.sh script, you just have to choose the location.

You can choose any bucket, any URL, as long as the VMs you are creating have access to read it.

Example: `gs://my-bucket-name/bootstrap.sh`

Replace `__CONFIGURE_GS_BOOTSTRAP_URL__` in the following files:

- [publish.sh](scripts/publish.sh)

## Bootstrap Archive URL

This is the URL where you want to store a tarball of the `local/update` directory and its contents.
It is automatically generated and uploaded for you by the publish.sh script, you just have to
choose the location.

You can choose any bucket, any URL, as long as the VMs you are creating have access to it.

Example: `gs://my-bucket-name/bootstrap-update.tar.gz`

Replace `__CONFIGURE_GS_ARCHIVE_URL__` in the following files:

- [bootstrap.sh](scripts/bootstrap.sh)
- [local/lib.sh](local/lib.sh)
- [publish.sh](scripts/publish.sh)

# Advanced Configuration

You can optionally create different update routines, and run only the one or more
that you want for a specific VM instance.

To do that, you would create sub-directories under the `local/update` directory.

Say your `local/update` directory looks like this:

    - local/update/chef
        - 100-install-chef
        - 500-configure-chef
        - 900-execute-chef

    - local/update/salt
        - 100-install-salt
        - 500-configure-salt
        - 900-execute-chef

You've now defined 2 different ways to set up a machine.

The first, the `chef` update procedure, installs, configures and executes chef-client.

The second, the `salt` update procedure, installs, configures and executes a salt minion.

## Triggering a specific execution procedure

Unless otherwise specified, [get-update-list](local/update/get-update-list) simply
lists out the files in the [local/update](local/update) directory.

You can manage multiple update procedures by setting Google Compute metadata to tell
it which specific procedure to execute.

### Default behavior - global updates only

For example, in this compute command

```bash
gcloud compute --project "my-project" instances create "my-instance" --zone "us-central1-a" --machine-type "n1-highcpu-1" --network "default" --metadata "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__" --maintenance-policy "MIGRATE" --scopes "https://www.googleapis.com/auth/userinfo.email" "https://www.googleapis.com/auth/compute" "https://www.googleapis.com/auth/devstorage.read_write" --image "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140904"
```

The significant element of the command is the metadata, like

    --metadata "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__"

We did NOT specify some optional metadata "ezvm-updates" and so the default updates are run,
e.g. only the global updates existing in the `local/update` directory.
Sub-directories are ignored.

### Advanced behavior - specific updates

We can tell ezvm to include one specific update procedure by adding more metadata like this

    --metadata "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__" "ezvm-updates=chef"

Now we created a metadata attribute named "ezvm-updates" whose value is "chef", so ezvm 
will look for the "chef" directory in the updates, and run those commands.

In this case, ezvm will first execute the global updates (all of those in the main
local/update directory) and will then execute the specific chef updates.

### Advanced behavior - multiple specific updates

You can specify multiple update procedures, and ezvm runs them in the order you listed.

For example:

    --metadata "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__" "ezvm-updates=salt chef"

The above will install global updates first, then salt and then chef.  You probably don't want to install
both chef and salt, but you get the idea how it works.

# Functional Example

As a functional example I've included an update procedure to install a salt master server.
Once you have the master up and running, it's pretty easy to have it create minions, so
there isn't any real value in using ezvm for that.  But creating the master takes a few
steps, and this automates it.

To create a salt master, run this command:

```bash
gcloud compute --project "my-project" instances create "salt" --zone "us-central1-a" --machine-type "n1-highcpu-1" --network "default" --metadata "startup-script-url=__CONFIGURE_GS_BOOTSTRAP_URL__" "ezvm-updates=salt-master" --maintenance-policy "MIGRATE" --scopes "https://www.googleapis.com/auth/userinfo.email" "https://www.googleapis.com/auth/compute" "https://www.googleapis.com/auth/devstorage.read_write" --image "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140904"
```

Notice the metadata `ezvm-updates=salt-master`, that is what causes it to run the
update routines in [local/update/salt-master](local/update/salt-master), which is what
actually does the work.

Without listing the "salt-master" directory in the "ezvm-updates" metadata, that directory
would have been ignored and no salt master would have been installed.

Note: That is a 1-core machine, you probably don't want to use that for an actual
production server.  Change the machine-type to a beefier machine if you are using a large
installation.
