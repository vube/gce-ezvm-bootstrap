#!/bin/sh
#
# Common routines for local update procedures
#

# Exit with a specific code after writing a message to STDERR
fatal() { r=$1; shift; echo "FATAL ERROR: $@" 1>&2; exit $r; }


. $EZVM_BASE_DIR/libs/plugin-init.sh || fatal 1 "Cannot include ezvm plugin-init.sh"


BUILD_DIR="$EZVM_LOCAL_CONTENT_DIR/build"


# Usage: debug_output "Some stuff" "to" "echo"
debug_output() {
    if [ ! -z "$DEBUG" ]; then
        echo "DEBUG: $@" | sed -e 's,\n,\nDEBUG: ,'
    fi
}

# Usage: url_encode "&weird characters/+here"
url_encode() {
    str="$1"
    python -c "import sys, urllib as ul; print ul.quote_plus('$1')"
}


# Usage: url_decode "%26encoded+string%26"
url_decode() {
    str="$1"
    python -c "import sys, urllib as ul; print ul.unquote_plus('$1')"
}


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
        22) ;; # This is a 404 error, as in the $path doesn't exist; no problem.
        6) ;; # Cannot resolve host; assume we're not running in GCE
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


# Query dpkg to find out what version of a given package is installed
# Usage: version=$(get_installed_package_version "nginx") || exit $?; \
#        [ "$version" = "" ] && echo "Package not installed"
get_installed_package_version() {

	package="$1"

    # Send STDERR to /dev/null, for our purposes we don't want messages
    # like "package-name is not installed", we fully expect to get those.
	output=$(dpkg-query -W -f='${Status} ${Version}\n' "$package" 2> /dev/null)

	# If the software is in any state OTHER than "install ok installed"
	# then we do NOT want to return a valid version number for it
	if [ "$(echo "$output" | grep "^install ok installed ")" = "" ]; then
		return 0
	fi

	# The software is in "install ok installed" status, so return
	# the version that's installed
	echo "$output" | sed -e "s,^install ok installed ,,"
}


# Install a Debian package if it is not already installed
# Usage: install_package nginx
#        install_package nginx backports
install_package() {
	
	r=2
	package="$1"
	catalog="${2:-default}"
	force="${3:-}"

    # If we are not forcing the install
    if [ "force" != "$(echo "$force" | tr '[:upper:]' '[:lower:]')" ]; then
    	# Check to see if this package is already installed
	    version="$(get_installed_package_version "$package")" || exit $?
    	if [ "$version" != "" ]; then
	    	# It is installed. Do not install it again.
		    echo "Notice: Package $package already installed; version $version"
		    return 0
		fi
	fi

	# Package is not installed, we need to install it
	case "$catalog" in
		backports)
			echo "Installing backports package $package"
			sudo DEBIAN_FRONTEND=noninteractive apt-get -t wheezy-backports install --yes --force-yes "$package" || fatal $r "Cannot install backports package $package"
			;;
		default)
			echo "Installing package $package"
			sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --force-yes "$package" || fatal $r "Cannot install package $package"
			;;
		# Any other value for $catalog is a special catalog we must have installed
		# and we'll just pass the value directly as `apt-get -t $catalog`
		*)
			echo "Installing $catalog package $package"
			sudo DEBIAN_FRONTEND=noninteractive apt-get -t "$catalog" install --yes --force-yes "$package" || fatal $r "Cannot install $catalog package $package"
			;;
	esac
}


# Create a directory; on failure, die
# Usage: create_dir /path/to/dir
#        create_dir /path/to/dir -p -m 0775 -o owner_user -g owner_group
create_dir() {

	path="$1"
	args="$@"

	if [ ! -d "$path" ]; then

		echo "Creating dir: $path"
		mkdir -p $args "$path" || fatal $? "Cannot create dir: $path"
	fi
}


# Create a directory as root; on failure, die
# Usage: root_create_dir /path/to/dir
#        root_create_dir /path/to/dir -p -m 0775 -o owner_user -g owner_group
root_create_dir() {

	path="$1"
	args="$@"

	if [ ! -d "$path" ]; then

		echo "Creating dir: $path"
		sudo mkdir -p $args "$path" || fatal $? "Cannot create dir: $path"
	fi
}


# Change to a directory; on failure, die
change_dir() {

	path="$1"

	cd "$path" || fatal 1 "Cannot cd $path"
}
