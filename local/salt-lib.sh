#!/bin/sh
#
# Common routines for Salt
#

install_salt() {

    extraFlags="${1:-}"
    flags="-i $(hostname -s) -n -G"

    # __SET_SALT_VERSION__ -- keep this comment so we can easily find where to set the salt version
    version="git v2015.8.8"

    # Load the 'xclusv' branch of xclusv's salt repo, where Ross has changes pending
#    flags="$flags -g https://github.com/xclusv/salt.git"
#    version="git xclusv"

    # Here we tell salt to fully Upgrade (-U) the system
    # and to use PIP (-P) to install dependencies.
    #
    flags="$flags -U -P"

    log_msg 1 "EXEC: sh $BUILD_DIR/bootstrap-salt.sh $flags $extraFlags $version"
    sudo             sh $BUILD_DIR/bootstrap-salt.sh $flags $extraFlags $version || fatal $? "bootstrap-salt.sh failed"
}

fix_salt_init_path() {
    service=$1
    restart=${2:-true}

    # Add /usr/local/bin to the $service path
    if ! egrep -q '^PATH=(.*:)?/usr/local/bin(:|$)' /etc/init.d/$service > /dev/null; then

        temp=$(mktemp -t init.XXXXXX)
        cat /etc/init.d/$service \
            | sed -e 's,^\(PATH=.*\),\1:/usr/local/bin,' \
            > $temp
        chmod 555 $temp

        mv $temp /etc/init.d/$service || fatal $? "Cannot install /etc/init.d/$service"

        if [ "$restart" = "true" ]; then
            /etc/init.d/$service stop
            sleep 5
            /etc/init.d/$service start || fatal $? "Cannot restart $service"
        fi
    fi

}
