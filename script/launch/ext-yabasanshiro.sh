#!/bin/sh

. /opt/muos/script/var/func.sh

NAME=$1
CORE=$2
ROM=$3
BIOS="/run/muos/storage/bios/saturn_bios.bin"

mkdir -p /run/muos/storage/save/file/YabaSanshiro-Ext
mkdir -p /run/muos/storage/save/state/YabaSanshiro-Ext

if [ "$CORE" = "ext-yabasanshiro-hle" ]; then
	YABA_BIN="./yabasanshiro -r 3 -a -i"
elif [ "$CORE" = "ext-yabasanshiro-bios" ] && [ ! -f "$BIOS" ] ; then
	YABA_BIN="./yabasanshiro -r 3 -a -i"
elif [ "$CORE" = "ext-yabasanshiro-bios" ] ; then
	YABA_BIN="./yabasanshiro -b $BIOS -r 3 -a -i"
fi

export SDL_HQ_SCALER="$(GET_VAR "device" "sdl/scaler")"
export SDL_ROTATION="$(GET_VAR "device" "sdl/rotation")"
export SDL_BLITTER_DISABLED=1

SET_VAR "system" "foreground_process" "yabasanshiro"

EMUDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/yabasanshiro"
export HOME="$EMUDIR"

chmod +x "$EMUDIR"/yabasanshiro

cd "$EMUDIR" || exit

export LD_LIBRARY_PATH="$EMUDIR/libsark:$LD_LIBRARY_PATH"

SDL_GAMECONTROLLERCONFIG=$(grep "Deeplay" "/usr/lib/gamecontrollerdb.txt") SDL_ASSERT=always_ignore $YABA_BIN "$ROM"

unset SDL_HQ_SCALER
unset SDL_ROTATION
unset SDL_BLITTER_DISABLED
