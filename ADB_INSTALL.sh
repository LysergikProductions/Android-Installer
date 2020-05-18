#!/bin/bash

success="false"

# install platform-tools
if brew cask install android-platform-tools; then success="true"
else
	set -x
	# error, so install Homebrew and try again
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

	reset # reset terminal to remove set -x and clear the screen
	if brew cask install android-platform-tools; then success="true"; fi
fi

xcode-select --install >/dev/null || return

if [ "$success" = "true" ]; then
	printf "\nSuccess!\n\n Type 'adb devices' after connecting an Android device.\nThen accept the USB debugging prompt on the device to get started!\n"
else
	printf "\nFailure!\n\n"
fi