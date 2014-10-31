#!/bin/sh
#
# Common routines for Salt
#

install_salt() {

    extraFlags="${1:-}"
    flags="-i $(hostname -s) -n -G"
    version="git v2014.1.13"

    sudo sh ../files/bootstrap-salt.sh $flags $extraFlags $version || fatal $? "bootstrap-salt.sh failed"
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
