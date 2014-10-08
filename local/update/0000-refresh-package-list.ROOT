#!/bin/sh
#
# 0000-refresh-package-list
#
# On multi-platform (if we support that) refresh the package lists so as we
# go through we know we're always working with the latest stuff.
#

. "$(dirname "$0")/../lib.sh" || { echo "Cannot include ../lib.sh" 1>&2; exit 1; }


# TODO: If needed, add multi-platform support

# Debian
apt-get update -y || die $? "apt-get update -y failed"
