#!/bin/sh

# Steam-Linux Flash fixer v1.2
# Programmed by NotoriousPyro
# craigcrawford1988 AT gmail DOT com
# PyroNexus.com

# Defines
BOLD="tput bold"
NORM="tput sgr0"
D_TEMP=/tmp/flash_steam
D_STEA=~/.steam/bin
D_PLUG=$D_STEA/plugins
F_ARCH=flash.tar.gz
F_LIBR=libflashplayer.so
L_LINK=http://fpdownload.macromedia.com/pub/flashplayer/current/
L_FILE=install_flash_player_11_linux.i386.tar.gz

E_LOG=$D_TEMP/error.log
E_STEA="There was a problem locating your Steam directory!"
E_TEMP="There was a problem writing to a temporary directory!"
E_PLUG="There was a problem with your Steam plugins directory."
E_DOWN="There was a problem downloading flash, the server may be down or the file may have been removed."
E_EXTR="There was a problem extracting the archive."

error() {
	log `${BOLD}`"FATAL ERROR:"`${NORM}` 1
	log "$1" 1
	log "Please check `${BOLD}`$E_LOG`${NORM}` as it may provide hints as to what went wrong." 1
	exit 1
}

log() {
	if [ "$2" = "1" ]; then
		echo "$1"
	fi
	echo "$1" >> $E_LOG
}

log `${BOLD}`"Steam-Linux Flash fixer v1.2"`${NORM}` 1
log "" 1

# Remove the previous temporary directory, if any.
rm -rf $D_TEMP

# Run some checks first...
if [ ! -d $D_TEMP ]; then
	mkdir $D_TEMP || {
		error "$E_TEMP"
	}
fi
if [ ! -d $D_STEA ]; then
	error "$E_STEA"
fi
if [ ! -d $D_PLUG ]; then
	log "$(mkdir -v $D_PLUG)" || {
		error "$E_PLUG"
	}
fi
if [ -e $D_PLUG/$F_LIBR ]; then
	log "$(rm -v $D_PLUG/$F_LIBR)" || {
		error "$E_PLUG"
	}
fi

# Attempt to download flash player gzip archive.
log "`${BOLD}`Downloading:`${NORM}` $L_FILE to $D_TEMP/$F_ARCH..." 1
wget -nv -a $E_LOG -O $D_TEMP/$F_ARCH $L_LINK/$L_FILE || error "$E_DOWN"

# Extract the archive to /tmp/flash_steam/libflashplayer.so.
log "`${BOLD}`Extracting:`${NORM}` $F_LIBR from $D_TEMP/$F_ARCH to $D_TEMP/$F_LIBR" 1
log "$(tar xzvf $D_TEMP/$F_ARCH -C $D_TEMP $F_LIBR)" || error "$E_EXTR"

# Create the directory and copy the file.
log "`${BOLD}`Copying:`${NORM}` $D_TEMP/$F_LIBR to $D_STEA/..." 1
log "Copying: $(cp -fv $D_TEMP/$F_LIBR $D_PLUG)"

# End
log "" 1
log "Successfully installed." 1
log "It is recommended you restart Steam for Flash to start working." 1
