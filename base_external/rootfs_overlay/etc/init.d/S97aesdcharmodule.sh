#!/bin/sh
# Simple script to load aesdchar kernel module on startup
# Usage:
#   ./S97aesdcharmodule.sh {start|stop}

case "$1" in
    start)
        echo "load /dev/aesdchar"
        /etc/aesdchar/aesdchar_load
        ;;
    stop)
        echo "unload /dev/aesdchar"
        /etc/aesdchar/aesdchar_unload
        ;;
    *)
        echo "Usage: $0 {start|stop}"
    exit 1
esac

exit 0

