#!/bin/sh

. /opt/muos/script/var/func.sh

LED_CONTROL=/opt/muos/device/current/script/led_control.sh
RGBCONF=/run/muos/storage/theme/active/rgb/rgbconf.sh

DISPLAY_IDLE() {
	if [ "$(/opt/muos/device/current/script/bl.sh)" -gt 10 ]; then
		/opt/muos/device/current/script/bl.sh 10
	fi
	case "$(GET_VAR device board/name)" in
		rg40xx*) "$LED_CONTROL" 1 0 0 0 0 0 0 0 ;;
	esac
}

DISPLAY_ACTIVE() {
	BL="$(cat "$BRIGHT_FILE")"
	if [ "$(/opt/muos/device/current/script/bl.sh)" -ne "$BL" ]; then
		/opt/muos/device/current/script/bl.sh "$BL"
	fi
	case "$(GET_VAR device board/name)" in
		rg40xx*) [ -x "$RGBCONF" ] && "$RGBCONF" ;;
	esac
}

# Monitor for specific programs that should inhibit idle timeout and prevent us
# from dimming the display or going to sleep.
while true; do
	case "$(GET_VAR system foreground_process)" in
		fbpad | mpv | ffplay | muxcharge | muxcredits | muxstart) IDLE_INHIBIT=1 ;;
		*) IDLE_INHIBIT=0 ;;
	esac
	SET_VAR system idle_inhibit "$IDLE_INHIBIT"
	sleep 5
done &
