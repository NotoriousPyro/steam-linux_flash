#!/bin/sh

# Steam-Linux Flash fixer v2.0.0
# Programmed by NotoriousPyro
# craigcrawford1988 AT gmail DOT com
# PyroNexus.com

# Defines
BOLD="tput bold"
NORM="tput sgr0"
# Directories
dirTemporary=/tmp/flash_steam
dirSteam=~/.steam/bin
dirSteamPlugins=$dirSteam/plugins
# Files
fileLog=$dirTemporary/error.log
fileArchive=install_flash_player_11_linux.i386.tar.gz
fileLibrary=libflashplayer.so
# Links
linkFlash=http://fpdownload.macromedia.com/pub/flashplayer/current
# Error Messages
msgError_Generic="An error occurred."
msgError_Fatal=`${BOLD}`"FATAL ERROR:"`${NORM}`
msgError_DownloadFailure="There was a problem downloading flash, the server may be down or the file may have been removed."
msgError_ExtractFailure="There was a problem extracting the archive."
msgError_CopyingFailure="There was a problem copying the library."
msgError_FlashRemovalFailure="Unable to uninstall Flash..."
msgError_dirTemporary="There was a problem writing to a temporary directory!"
msgError_dirSteam="There was a problem locating your Steam directory!"
msgError_dirSteamPlugins="There was a problem with your Steam plugins directory."

# Messages
msgGeneric_RestartSteam="Changes may not take effect until Steam is restarted."
msgInstall_Successful="Sucessfully installed."
msgInstall_FlashDetected="Flash has already been detected, try running $0 --uninstall"
msgUninstall_NothingToDo="Flash not found! Nothing to do!"
msgUninstall_Successful="Successfully removed."

msgError_LogFile="Please check `${BOLD}`$fileLog`${NORM}` as it may provide hints as to what went wrong."

# Extra logging
log() {
  # Output to user?
  if [ "$2" = "1" ]; then
    echo "$1"
  fi
  # Output to file
  echo "$1" >> $fileLog
}

# Error fuction
error() {
  log "$msgError_Fatal" 1
  log "$1" 1
  log "$msgError_LogFile" 1
  end "e"
}

# Install function
flashInstall() {
  # Check if Flash is already installed
  if [ -e $dirSteamPlugins/$fileLibrary ]; then
    end "fd"
  fi
  
  # Attempt to download flash player gzip archive.
  log "`${BOLD}`Downloading:`${NORM}` $linkFlash/$fileArchive to $dirTemporary/$fileArchive..." 1
  wget -nv -a $fileLog -O $dirTemporary/$fileArchive $linkFlash/$fileArchive || error "$msgError_DownloadFailure"
  
  # Extract the archive to /tmp/flash_steam/libflashplayer.so.
  log "`${BOLD}`Extracting:`${NORM}` $fileLibrary from $dirTemporary/$fileArchive to $dirTemporary/$fileLibrary" 1
  log "`(tar xzvf $dirTemporary/$fileArchive -C $dirTemporary $fileLibrary)`" || error "$msgError_ExtractFailure"
  
  # Create the directory and copy the file.
  log "`${BOLD}`Copying:`${NORM}` $dirTemporary/$fileLibrary to $dirSteamPlugins/..." 1
  log "`(cp -fv $dirTemporary/$fileLibrary $dirSteamPlugins)`" || error "$msgError_CopyingFailure"
  end "i"
}

# Uninstall function
flashUninstall() {
  if [ -e $dirSteamPlugins/$fileLibrary ]; then
    log "`(rm -v $dirSteamPlugins/$fileLibrary)`" || {
      error "$error_FlashRemovalFailed"
    }
  else
    end "un"
  fi
  end "u"
}

end() {

  # Install: Success
  if [ "$1" = "i" ]; then
    echo
    echo "$msgInstall_Successful"
    echo "$msgGeneric_RestartSteam"
  # Install: Flash Detected
  elif [ "$1" = "fd" ]; then
    echo "$msgInstall_FlashDetected"
    exit 1
  # Uninstall: Success
  elif [ "$1" = "u" ]; then
    echo "$msgUninstall_Successful"
    echo "$msgGeneric_RestartSteam"
  # Uninstall: Nothing to do
  elif [ "$1" = "un" ]; then
    echo "$msgUninstall_NothingToDo"
  # Generic: Error
  elif [ "$1" = "e" ]; then
    echo "$msgError_Generic"
    exit 1
  fi
  sleep 5
  exit 0
}

# Remove the previous temporary directory, if any.
rm -rf $dirTemporary

# Run some checks first...
# Check if the temporary dir exists, if not make it
if [ ! -d $dirTemporary ]; then
  mkdir $dirTemporary || {
    error "$msgError_dirTemporary"
  }
fi
# Check if the Steam dir exists
if [ ! -d $dirSteam ]; then
  error "$msgError_dirSteam"
fi
# Check if the Steam Plugins dir exists, if not make it
if [ ! -d $dirSteamPlugins ]; then
  log "`(mkdir -v $dirSteamPlugins)`" || {
    error "$msgError_dirSteamPlugins"
  }
fi

echo `${BOLD}`"Steam-Linux Flash fixer v2.0.0"`${NORM}`

if [ "$1" = "--uninstall" ]; then
  flashUninstall
else
  flashInstall
fi