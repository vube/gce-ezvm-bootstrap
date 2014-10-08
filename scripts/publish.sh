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
#
# DO NOT MODIFY ANYTHING BELOW HERE
#

if [ "$GS_EZVM_LOCAL_ARCHIVE" = "__CONFIGURE_GS_ARCHIVE_URL__" ]; then
    echo "CONFIGURATION ERROR: You did not configure GS_EZVM_LOCAL_ARCHIVE in $0" 1>&2
    exit 1
fi

if [ "$GS_BOOTSTRAP_SH" = "__CONFIGURE_GS_ARCHIVE_URL__" ]; then
    echo "CONFIGURATION ERROR: You did not configure GS_BOOTSTRAP_SH in $0" 1>&2
    exit 1
fi


cd "$(dirname $0)"
BASE_DIR="$(dirname $(pwd))"

# Create the build dir if needed
[ -d "$BASE_DIR/build" ] || mkdir -p "$BASE_DIR/build" || exit 1

archive=$(basename "$GS_EZVM_LOCAL_ARCHIVE")

echo "# Building $archive"

cd "$BASE_DIR/local" || exit 1

tar -czf "$BASE_DIR/build/$archive" * || exit 1

# Copy files up to Google Cloud Storage

echo "# Uploading to Google Cloud Storage"

cd "$BASE_DIR" || exit 1

gsutil cp scripts/bootstrap.sh "$GS_BOOTSTRAP_SH" || exit 1

gsutil cp "build/$archive" "$GS_EZVM_LOCAL_ARCHIVE" || exit 1
