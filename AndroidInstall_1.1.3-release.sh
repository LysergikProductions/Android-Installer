#!/bin/bash
#AndroidInstall_1.1.3-release.sh
#Nikolas A. Wagner © 2020
#License: GNU GPLv3

#                                          -- Description --
# Simplifies the process of installing builds on Android devices via Mac OSX using Android Debug Bridge

#some global variables
scriptName="AndroidInstall_1.1.3-release"; scriptTitle="*MONKEY INSTALLER*"; author="Nikolas A. Wagner"
scriptVersion="1.1.3"; scriptVersionType="release"; license="GNU GPLv3"

loopFromError="false"; errorMessage=" ..no error is saved here.. " deviceConnect="false"; adbVersion=$(adb version)

COLS=$(tput cols) # Text-UI elements and related variables
UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
UItrouble="-- Troubleshooting --"

# set font size on Mac OSX Terminal
osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" >/dev/null 2>&1

function INIT(){
	clear; echo "Initializing.."; sleep 0.8
	if toilet -h; then clear
	else
		printf "\n\nUpdating toilet:"
		echo "cmd"
		sleep 2
		sudo apt install toilet
	fi
}

INIT

function printHead(){
	if [ $loopFromError = "false" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n$UIsep_head\n\n"
	elif [ $loopFromError = "true" ]; then
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n$UIsep_head\n\n"
		printf "$errorMessage\n\n"

		if [ $deviceConnect = "false" ]; then
			until adb shell exit >/dev/null 2>&1; do
				export deviceConnect="false"
				waiting
			done
			printf "\r%*s\n\n" $[$COLS/2] "Device Connected!   "
		elif [ $deviceConnect = "true" ]; then
			echo
		else
			echo "Unexpected value for deviceConnect: $deviceConnect"
			export deviceConnect="true"
			exit status 1
		fi
		export deviceConnect="true"
  	else
    		export errorMessage="$errorMessage\n\n$UIsep_err0\n\n"
    		export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value."
    		export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
  	fi
  	printf "\nMounting device...\n\n"; adb devices
}

function printTitle(){
	toilet -t -F gay "Monkey Installer"
	#printf "\n%*s\n" $[$COLS/2] "$title"
	#printf "%*s\n\n\n" $[$COLS/2] "$UIsep_title"
}

function MAIN(){
	printHead; checkConnect; printTitle

	#checking for fatal error while calling the main functions of the script
	if {
		getOBB; adbWAIT; getAPK; adbWAIT; INSTALL
	}; then printf "\nGoodbye!\n"; echo; exit
	else
		printf "\nFE0 - Fatal Error; problem calling main functions.\nPlease report this error code to Nick.\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		echo; exit 1
	fi
}

#Check for device connection; reset script in case of error
function checkConnect(){	
	if (adb shell settings put global development_settings_enabled 1); then
		export deviceConnect="true"
	else
		loopFromError="true"; deviceConnect="false"
		export errorMessage="RE0 - No devices found, or found more than one connected.\n\n"
    	export errorMessage+="				$UItrouble\n"
    	export errorMessage+="Ensure only one device is connected and that is has USB Debugging permissions..\n"
    	export errorMessage+="For more help on this, search 'ADB fixAll' in google drive."

		echo; printf "\nRE0 - Could not connect to just one device; resetting script in..\n"; sleep 0.5
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 0.5
		echo; echo "debug back to printHead"; sleep 1
		printHead
	fi
}

#update the script on status of adb connection
function adbWAIT(){
	if (adb shell exit >/dev/null 2>&1); then
		export deviceConnect="true"
	else
		until (adb shell exit >/dev/null 2>&1); do waiting; done
		export deviceConnect="true"
		printf "\r%*s\n\n" $[$COLS/2] "Device Connected!   "
		printTitle
	fi
}

function getOBB(){ #this function gets the OBB name needed to isolate the monkey events to the app being tested
	printf "\n%*s\n" $[$COLS/2] "Drag OBB anywhere here:"
	read -p '' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName
	if [ "$OBBfilePath" == "" ]; then
		export OBBvalid="false"
		printHead; printTitle
		printf "%*s\n" $[$COLS/2] "You forgot to drag the OBB!"
		getOBB
	elif [[ ! "$OBBfilePath" == "com."* ]]; then
		export OBBvalid="false"
	elif [ "$OBBfilePath" == "fire" ]; then
		export OBBvalid="true"
		local cleanPath="${OBBfilePath#*:*}"
		export OBBname=$(basename "$cleanPath"); printf "OBB Name: $OBBname\n\n"
		export launchCMD="monkey -p $OBBname -v 1"
	else
		export OBBvalid="true"
		local cleanPath="${OBBfilePath#*:*}"
		export OBBname=$(basename "$cleanPath"); printf "OBB Name: $OBBname\n\n"
		export launchCMD="monkey -p $OBBname -v 1"
	fi

	until [ $OBBvalid == "true" ]; do
		printHead; printTitle
		printf "\n%*s\n\n" $[$COLS/2] "That is not an OBB!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getOBB
	done

	adbWAIT
	if [[ $deviceConnect == "true" ]]; then getAPK; else export deviceConnect="false"; printHead; fi
}

function getAPK(){
	APKvalid="true"
	printf "%*s\n" $[$COLS/2] "Drag APK anywhere here:"
	read -p '' APKfilePath

	if [ "$APKfilePath" == "" ]; then
		printHead; printTitle
		export APKvalid="false"
		printf "%*s\n\n" $[$COLS/2] "You forgot to drag the APK!"
		getAPK
	elif [[ "$APKfilePath" == *".apk" ]]; then
		export APKvalid="true"
		local cleanPath="${APKfilePath#*:*}"
		export APKname=$(basename "$cleanPath")

		printf "APK Name: $APKname\n\n"

		adbWAIT
		if [[ $deviceConnect == "true" ]]; then INSTALL; else export deviceConnect="false"; printHead; fi
	else export APKvalid="false"; fi

	until [ "$APKvalid" == "true" ]; do
		printHead; printTitle
		printf "%*s\n\n" $[$COLS/2] "That is not an APK!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getAPK
	done
}

function INSTALL(){
	if {
		printf "\nUploading OBB..\n"; adb push "$OBBfilePath" /sdcard/Android/OBB
		printf "\nInstalling APK..\n"; adb install --no-streaming "$APKfilePath"
	}; then
		printf "\n\nLaunching app."
		adb shell "$launchCMD" > /dev/null 2>&1; sleep 1; printf " ."; sleep 1; printf " .\n"

		errorMessage="Any previous error messages will be printed to a log at this time in the next release!"
		printf "\nGoodbye!\n\n"; exit
	else
		printf "\nFE1 - Fatal Error; install was unsuccesful for unknown reasons.\nPlease report this error code to Nick.\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		echo; exit 1
	fi
}

function checkVersion(){
	clear
	{ #clone repo; if error then update with git pull
		pushd ~ > /dev/null 2>&1; git clone https://github.com/LysergikProductions/Android-Installer.git > /dev/null 2>&1; popd > /dev/null 2>&1 ||
		pushd ~/Android-Installer > /dev/null 2>&1; git pull > /dev/null 2>&1; popd > /dev/null 2>&1
	}
	currentVersion=$(grep -n "_version " properties.txt); export currentVersion="${currentVersion##* }"
	
	printf "\n\n\n\n\n%*s\n" $[$COLS/2] "This script: v$scriptVersion"
	printf "%*s\n" $[$COLS/2] "Latest version: v$currentVersion"

	if [ "$scriptVersion" == "$currentVersion" ]; then
		printf "\n%*s" $[$COLS/2] "This script is up-to-date!"
	else printf "\n%*s" $[$COLS/2] "Update required..."; fi
}
checkVersion; sleep 2

function waiting(){
	waitMessage="-- waiting for device --"
	local anim1=( "" " ." " . ." " . . ." " . . . ." " . . . . ." )
	local anim2=(
	"oooooooooooooooooooooooo"
	"Oooooooooooooooooooooooo" "oOoooooooooooooooooooooo" "ooOooooooooooooooooooooo" "oooOoooooooooooooooooooo" "ooooOooooooooooooooooooo" "oooooOoooooooooooooooooo"
	"ooooooOooooooooooooooooo" "oooooooOoooooooooooooooo" "ooooooooOooooooooooooooo" "oooooooooOoooooooooooooo" "ooooooooooOooooooooooooo" "oooooooooooOoooooooooooo"
	"ooooooooooooOooooooooooo" "oooooooooooooOoooooooooo" "ooooooooooooooOooooooooo" "oooooooooooooooOoooooooo" "ooooooooooooooooOooooooo" "oooooooooooooooooOoooooo"
	"ooooooooooooooooooOooooo" "oooooooooooooooooooOoooo" "ooooooooooooooooooooOooo" "oooooooooooooooooooooOoo" "ooooooooooooooooooooooOo" "oooooooooooooooooooooooO"
	)

	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n$UIsep_head\n\n"
    printf "$errorMessage\n\n\n"
    printf "\n%*s\n" $[$COLS/2] "$waitMessage"

	for i in "${anim2[@]}"
	do
		printf "\r%*s" $[$COLS/2] "$i"
		sleep 0.1
	done
}

{ # try to run the script
    MAIN &&
    printf "\nDebug: MAIN completed without errors!\n"
} || {
    printf "\nDebug: MAIN is caught having an error!\n"
}

#Say goodbye when done everything, regardless of an exit
printf "\nGoodbye!\n"; exit
