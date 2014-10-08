#!/bin/sh
#
# Install bootstrap.sh and ezvm local content to Google Cloud Storage
# where it can be accessed by new VMs as they come online.
#

######################################################################
# BEGIN CONFIGURATION SECTION
######################################################################

GS_EZVM_LOCAL_ARCHIVE="__CONFIGURE_GS_ARCHIVE_URL__"

GS_BOOTSTRAP_SH="__CONFIGURE_GS_BOOTSTRAP_URL__"

######################################################################
# END CONFIGURATION SECTION
######################################################################

cd "$(dirname $0)"
BASE_DIR="$(pwd)"

# Create the build dir if needed
[ -d "$BASE_DIR/build" ] || mkdir -p "$BASE_DIR/build" || exit 1

echo "# Building ezvm-local.tar.gz"

pushd local > /dev/null || exit 1
tar -czf "$BASE_DIR/build/ezvm-local.tar.gz" * || exit 1
popd > /dev/null

# Copy files up to Google Cloud Storage

echo "# Uploading to Google Cloud Storage"

gsutil cp scripts/bootstrap.sh "$GS_BOOTSTRAP_SH" || exit 1

gsutil cp build/ezvm-local.tar.gz "$GS_EZVM_LOCAL_ARCHIVE" || exit 1
