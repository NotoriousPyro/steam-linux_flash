#!/bin/sh

# Steam-Linux Flash fixer v1.3.0
# Programmed by NotoriousPyro
# craigcrawford1988 AT gmail DOT com
# PyroNexus.com

# Defines
BOLD="tput bold"
NORM="tput sgr0"
dirTemporary=/tmp/flash_steam
dirSteam=~/.steam/bin
dirSteamPlugins=$dirSteam/plugins

fileLog=$dirTemporary/error.log
fileArchive=install_flash_player_11_linux.i386.tar.gz
fileLibrary=libflashplayer.so

linkFlash=http://fpdownload.macromedia.com/pub/flashplayer/current

errorFatal=`${BOLD}`"FATAL ERROR:"`${NORM}`
error_dirSteam="There was a problem locating your Steam directory!"
error_dirTemporary="There was a problem writing to a temporary directory!"
error_dirSteamPlugins="There was a problem with your Steam plugins directory."
errorDownload="There was a problem downloading flash, the server may be down or the file may have been removed."
errorExtract="There was a problem extracting the archive."
errorCopying="There was a problem copying the library."
errorLogFileMessage="Please check `${BOLD}`$fileLog`${NORM}` as it may provide hints as to what went wrong."

error() {
	log "$errorFatal" 1
	log "$1" 1
	log "$errorLogFileMessage" 1
	exit 1
}

log() {
	if [ "$2" = "1" ]; then
		echo "$1"
	fi
	echo "$1" >> $fileLog
}

echo `${BOLD}`"Steam-Linux Flash fixer v1.3.0"`${NORM}`

# Remove the previous temporary directory, if any.
rm -rf $dirTemporary

# Run some checks first...
if [ ! -d $dirTemporary ]; then
	mkdir $dirTemporary || {
		error "$error_dirTemporary"
	}
fi
if [ ! -d $dirSteam ]; then
	error "$error_dirSteam"
fi
if [ ! -d $dirSteamPlugins ]; then
	log "$(mkdir -v $dirSteamPlugins)" || {
		error "$error_dirSteamPlugins"
	}
fi
if [ -e $dirSteamPlugins/$fileLibrary ]; then
	log "$(rm -v $dirSteamPlugins/$fileLibrary)" || {
		error "$error_dirSteamPlugins"
	}
fi

# Attempt to download flash player gzip archive.
log "`${BOLD}`Downloading:`${NORM}` $linkFlash/$fileArchive to $dirTemporary/$fileArchive..." 1
wget -nv -a $fileLog -O $dirTemporary/$fileArchive $linkFlash/$fileArchive || error "$errorDownload"

# Extract the archive to /tmp/flash_steam/libflashplayer.so.
log "`${BOLD}`Extracting:`${NORM}` $fileLibrary from $dirTemporary/$fileArchive to $dirTemporary/$fileLibrary" 1
log "$(tar xzvf $dirTemporary/$fileArchive -C $dirTemporary $fileLibrary)" || error "$errorExtract"

# Create the directory and copy the file.
log "`${BOLD}`Copying:`${NORM}` $dirTemporary/$fileLibrary to $dirSteamPlugins/..." 1
log "$(cp -fv $dirTemporary/$fileLibrary $dirSteamPlugins)" || error "$errorCopying"

# End
echo
echo "Successfully installed."
echo "It is recommended you restart Steam for Flash to start working."
