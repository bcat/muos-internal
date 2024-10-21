#!/bin/sh

. /opt/muos/script/var/init/system.sh

FB_SWITCH() {
	WIDTH="$1"
	HEIGHT="$2"
	DEPTH="$3"

	echo 4 >/sys/class/graphics/fb0/blank
	cat /dev/zero >/dev/fb0 2>/dev/null

	fbset -fb /dev/fb0 -g 0 0 0 0 "${DEPTH}"
	sleep 0.25
	fbset -fb /dev/fb0 -g "${WIDTH}" "${HEIGHT}" "${WIDTH}" "$((HEIGHT * 2))" "${DEPTH}"
	sleep 0.25

	echo 0 >/sys/class/graphics/fb0/blank
}

# Prints current system uptime in hundredths of a second. Unlike date or
# EPOCHREALTIME, this won't decrease if the system clock is set back, so it can
# be used to measure an interval of real time.
UPTIME() {
	cut -d ' ' -f 1 /proc/uptime
}

PARSE_INI() {
	INI_FILE="$1"
	SECTION="$2"
	KEY="$3"
	sed -nr "/^\[$SECTION\]/ { :l /^${KEY}[ ]*=[ ]*/ { s/^[^=]*=[ ]*//; p; q; }; n; b l; }" "${INI_FILE}"
}

SET_VAR() {
	printf "%s" "$3" >"/run/muos/$1/$2"
}

GET_VAR() {
	cat "/run/muos/$1/$2"
}

LOGGER() {
	if [ "$(GET_VAR "global" "boot/factory_reset")" -eq 1 ]; then
		/opt/muos/extra/muxstart "$(printf "%s\n\n%s\n" "$2" "$3")" && sleep 0.5
	fi
	printf "%s\t[%s] :: %s - %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1" "$2" "$3" >>"$MUOS_BOOT_LOG"
}

CRITICAL_FAILURE() {
	case "$1" in
		device) MESSAGE=$(printf "Critical Failure\n\nFailed to mount '%s'!\n\n%s" "$2" "$3") ;;
		directory) MESSAGE=$(printf "Critical Failure\n\nFailed to mount '%s' on '%s'!" "$2" "$3") ;;
		udev) MESSAGE="Critical Failure\n\nFailed to initialise udev!" ;;
		*) MESSAGE="Critical Failure\n\nAn unknown error occurred!" ;;
	esac

	/opt/muos/extra/muxstart "$MESSAGE"
	sleep 10
	/opt/muos/script/system/halt.sh poweroff
}

RUMBLE() {
	echo 1 >"$1"
	sleep "$2"
	echo 0 >"$1"
}
