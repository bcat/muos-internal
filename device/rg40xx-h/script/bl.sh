#!/bin/sh

DISPLAY_WRITE() {
	printf '%s\n' "$1" >/sys/kernel/debug/dispdbg/name
	printf '%s\n' "$2" >/sys/kernel/debug/dispdbg/command
	printf '%s\n' "$3" >/sys/kernel/debug/dispdbg/param
	printf '1\n' >/sys/kernel/debug/dispdbg/start
}

DISPLAY_READ() {
	printf '%s\n' "$1" >/sys/kernel/debug/dispdbg/name
	printf '%s\n' "$2" >/sys/kernel/debug/dispdbg/command
	printf '1\n' >/sys/kernel/debug/dispdbg/start
	cat /sys/kernel/debug/dispdbg/info
}

case "$#" in
	# Get backlight level.
	0) DISPLAY_READ lcd0 ;;

	# Set backlight level.
	1)
		if [ "$1" -eq 0 ]; then
			printf '4\n' >/sys/class/graphics/fb0/blank
		else
			printf '0\n' >/sys/class/graphics/fb0/blank
		fi
		DISPLAY_WRITE lcd0 setbl "$1"
		;;

	*)
		printf 'Usage: bl.sh [LEVEL]\n'
		exit 1
		;;
