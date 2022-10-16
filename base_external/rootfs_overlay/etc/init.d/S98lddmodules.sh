#!/bin/sh
# Simple script to load kernel modules and create devices or destroy devices and
# unload modules adapted from code provided in class 
# Usage:
#   ./S98lddmodules.sh {start|stop}

case "$1" in
    start)
        driverdir="/lib/modules/5.15.18/extra/"
        modprobe hello

        module="scull"
        device="scull"
        mode="664"

        # Group: since distributions do it differently, look for wheel or use staff
        if grep -q '^staff:' /etc/group; then
            group="staff"
        else
            group="wheel"
        fi

        # invoke insmod with all arguments we got
        # and use a pathname, as insmod doesn't look in . by default
        insmod ${driverdir}$module.ko || exit 1

        # retrieve dynamic major number
        major=$(awk "\$2==\"$module\" {print \$1}" /proc/devices)

        # Remove stale nodes and replace them, then give gid and perms
        # Usually the script is shorter, it's scull that has several devices in it.

        rm -f /dev/${device}[0-3]
        mknod /dev/${device}0 c $major 0
        mknod /dev/${device}1 c $major 1
        mknod /dev/${device}2 c $major 2
        mknod /dev/${device}3 c $major 3
        ln -sf ${device}0 /dev/${device}
        chgrp $group /dev/${device}[0-3] 
        chmod $mode  /dev/${device}[0-3]

        rm -f /dev/${device}pipe[0-3]
        mknod /dev/${device}pipe0 c $major 4
        mknod /dev/${device}pipe1 c $major 5
        mknod /dev/${device}pipe2 c $major 6
        mknod /dev/${device}pipe3 c $major 7
        ln -sf ${device}pipe0 /dev/${device}pipe
        chgrp $group /dev/${device}pipe[0-3] 
        chmod $mode  /dev/${device}pipe[0-3]

        rm -f /dev/${device}single
        mknod /dev/${device}single  c $major 8
        chgrp $group /dev/${device}single
        chmod $mode  /dev/${device}single

        rm -f /dev/${device}uid
        mknod /dev/${device}uid   c $major 9
        chgrp $group /dev/${device}uid
        chmod $mode  /dev/${device}uid

        rm -f /dev/${device}wuid
        mknod /dev/${device}wuid  c $major 10
        chgrp $group /dev/${device}wuid
        chmod $mode  /dev/${device}wuid

        rm -f /dev/${device}priv
        mknod /dev/${device}priv  c $major 11
        chgrp $group /dev/${device}priv
        chmod $mode  /dev/${device}priv

        module="faulty"
        # Use the same name for the device as the name used for the module
        device="faulty"
        # Support read/write for owner and group, read only for everyone using 664
        mode="664"

        set -e
        # Group: since distributions do it differently, look for wheel or use staff
        # These are groups which correspond to system administrator accounts
        if grep -q '^staff:' /etc/group; then
            group="staff"
        else
            group="wheel"
        fi

        echo "Load faulty module, exit on failure"
        insmod ${driverdir}$module.ko || exit 1
        echo "Get the major number (allocated with allocate_chrdev_region) from /proc/devices"
        major=$(awk "\$2==\"$module\" {print \$1}" /proc/devices)
        if [ ! -z ${major} ]; then
            echo "Remove any existing /dev node for /dev/${device}"
            rm -f /dev/${device}
            echo "Add a node for our device at /dev/${device} using mknod"
            mknod /dev/${device} c $major 0
            echo "Change group owner to ${group}"
            chgrp $group /dev/${device}
            echo "Change access mode to ${mode}"
            chmod $mode  /dev/${device}
        else
            echo "No device found in /proc/devices for driver ${module} (this driver may not allocate a device)"
        fi
        ;;
    stop)
        module="scull"
        device="scull"

        # invoke rmmod with all arguments we got
        rmmod $module || exit 1

        # Remove stale nodes

        rm -f /dev/${device} /dev/${device}[0-3] 
        rm -f /dev/${device}priv
        rm -f /dev/${device}pipe /dev/${device}pipe[0-3]
        rm -f /dev/${device}single
        rm -f /dev/${device}uid
        rm -f /dev/${device}wuid

        module="faulty"
        device="faulty"

        # invoke rmmod with all arguments we got
        rmmod faulty || exit 1
        # Remove stale nodes
        rm -f /dev/faulty

        rmmod hello || exit 1
        ;;
    *)
        echo "Usage: $0 {start|stop}"
    exit 1
esac

exit 0

