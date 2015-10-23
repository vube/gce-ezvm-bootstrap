#!/bin/sh
#
# Bootstrap a new Google Compute Engine VM with ezvm
#
# Usage: sudo ./bootstrap.sh
#

######################################################################
# BEGIN CONFIGURATION SECTION
######################################################################

GS_EZVM_LOCAL_ARCHIVE="__CONFIGURE_GS_ARCHIVE_URL__"

# Where to install ezvm
EZVM="/usr/local/ezvm"

# Where to create an ezvm symlink so it's automatically in your path
LOCAL_BIN_DIR="/usr/local/bin"

######################################################################
# END CONFIGURATION SECTION
######################################################################

# Temporary build directory
BUILD_DIR=$(mktemp -d build.XXX)

# Exit with a specific code after writing a message to STDERR
fatal() { r=$1; shift; echo "FATAL ERROR: $@" 1>&2; exit $r; }

# Get metadata about this instance and/or project, by path
# Prints value to stdout so you should capture it like value=$(get_metadata "path")
get_metadata() {
	path="$1"

	# Execute curl and it writes to stdout
	# curl -s means no progress meter;
	#      -f means fail silently (don't print content and exit non-zero)
	curl -fs "http://metadata/computeMetadata/v1/instance/$path" \
		-H "Metadata-Flavor: Google"

    r=$?
    case $r in
        22) ;; # This is a 404 error, as in the $path doesn't exist; no problem. Return empty value.
        0) ;; # Success we got the $path
        *) echo "ERROR: Querying metadata [$path] (code=$r)" 1>&2 ;;
    esac

    exit $r
}


# Get metadata attribute about this instance and/or project, by key name
# Prints value to stdout so you should capture it like value=$(get_metadata_attribute "key")
get_metadata_attribute() {
	key="$1"

    get_metadata "attributes/$key"
}

# TODO- DEBIAN-SPECIFIC
# Install a package
package() {
	
	r=2
	package="$1"
	catalog="${2:-default}"

	case "$catalog" in
		*)
			sudo apt-get install -y "$package" || fatal $r "Cannot install package $package"
			;;
	esac
}

# Install any packages that are required in order to download/install/execute ezvm
install_ezvm_dependencies() {

	# Install packages we require BEFORE we can load and run ezvm
	package "git" ""
}

# Copy ezvm from cloud storage to local disk
install_ezvm() {
	r=4

	if [ -d "$EZVM" -a -x "$EZVM/bin/ezvm" ]; then
		echo "ezvm already exists, skipping"
		return 0
	fi

	echo "Installing ezvm"

	# Install dependencies before we can clone and execute anything
	install_ezvm_dependencies

    # Figure out what branch to install
    branch=$(get_metadata_attribute "ezvm-branch")
    r=$?
    case $r in
        22) branch="master" ;; # This is a 404 error, as in the metadata doesn't exist; no problem. Return empty value.
        0) ;; # Success we got the metadata
        *) fatal $? "Error querying ezvm-branch metadata" ;;
    esac

	# Clone to temp build path
	sudo rm -rf "$EZVM" 2> /dev/null || fatal $r "Cannot clean up $EZVM before install"
	git clone https://github.com/vube/ezvm || fatal $r "Clone ezvm failed"

    # Check out the correct branch of ezvm
    if [ "$branch" != "master" ]; then
        echo "Checking out '$branch' branch"
        cd ezvm || fatal $? "Cannot cd to ezvm"
        git checkout "$branch" || fatal $? "Failed to 'git checkout $branch'"
        cd .. || fatal $? "Cannot cd .."
    fi

	# Install to /usr/local/ezvm
	echo "Installing ezvm"
	sudo mv ezvm "$EZVM" || fatal $r "Cannot move ezvm to $EZVM"

	# Create /usr/local/bin/ezvm symlink so `ezvm` is in the path
	cd $LOCAL_BIN_DIR || fatal $r "Cannot cd to $LOCAL_BIN_DIR"
	sudo ln -sfT "$EZVM/bin/ezvm" ezvm || fatal $r "Cannot symlink $LOCAL_BIN_DIR/ezvm"
}


install_ezvm_local() {
	r=5

	echo "Installing ezvm-local content"

	local_dir="$EZVM/etc/local"

	if [ ! -d "$local_dir" ]; then
		mkdir -p -m 0775 "$local_dir" || fatal $r "Cannot create $local_dir"
	fi
	cd "$local_dir" || fatal $r "Cannot cd $local_dir"

	file=$(basename "$GS_EZVM_LOCAL_ARCHIVE")
	[ -e "$file" ] && rm -f "$file"

	gsutil cp "$GS_EZVM_LOCAL_ARCHIVE" "$file" || fatal $r "Failed to copy ezvm-local archive: $GS_EZVM_LOCAL_ARCHIVE"
	tar -zxf "$file" || fatal $r "Error unpacking ezvm-local archive"

	rm -f "$file"
}

### MAIN

# Update apt cache so we don't install outdated packages
# TODO- DEBIAN-SPECIFIC
sudo apt-get update || fatal 2 "cannot update apt"


# Install ezvm
install_ezvm
install_ezvm_local


# Execute ezvm
ezvm update || fatal 99 "ezvm update failed"
