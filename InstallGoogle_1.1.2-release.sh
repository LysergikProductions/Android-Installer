#!/bin/bash
#InstallGoogle_1.1.2-release.sh
#Nikolas A. Wagner © 2020
#License: GNU GPLv3

#                                          -- Description --
# Simplifies the process of installing builds on Android devices via Mac OSX using Android Debug Bridge

#some global variables
scriptName="InstallGoogle_1.1.2-release"; scriptTitle="*MONKEY INSTALLER*"; author="Nikolas A. Wagner"
scriptVersion="1.1.2"; scriptVersionType="release"; license="GNU GPLv3"

loopFromError="false"; errorMessage=" ..no error is saved here.. " deviceConnect="true"; adbVersion=$(adb version)

COLS=$(tput cols) #Text-UI elements and related variables
UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
UItrouble="-- Troubleshooting --"

function printHead(){
	if [ $loopFromError = "false" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n$UIsep_head\n\n"
	elif [ $loopFromError = "true" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n$UIsep_head\n\n"
    	printf "$errorMessage\n\n"

    	if [ $deviceConnect = "false" ]; then
			until adb shell exit
			do
				clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n$UIsep_head\n\n"
    			printf "$errorMessage\n\n\n -- waiting for device --\n"
				printf " ."; sleep 1; printf " ."; sleep 1; printf " ."; sleep 1
				$deviceConnect = "false"
			done
			$deviceConnect = "true"
		elif [ $deviceConnect = "true" ]; then
			echo
		else
			echo "Unexpected value for deviceConnect: $deviceConnect"
			export deviceConnect="true"
			exit status 1
		fi
		echo
  	else
    	export errorMessage="$errorMessage\n\n$UIsep_err0\n\n"
    	export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value."
    	export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
  	fi
}

function printTitle(){
	printf "\n%*s\n" $[$COLS/2] "$scriptTitle"
	printf "%*s\n\n" $[$COLS/2] "$UIsep_title"
}

#Check for device connection; reset script in case of error
function adbWAIT(){ #update the script on status of adb connection
	if (adb shell settings put global development_settings_enabled 1); then
		export deviceConnect="true"
	else
		loopFromError="true"; deviceConnect="false"
		export errorMessage="RE0 - No devices found, or found more than one connected.\n\n"
    	export errorMessage+="             $UItrouble\n"
    	export errorMessage+="Ensure only one device is connected and that is has USB Debugging permissions..\n"
    	export errorMessage+="For more help on this, search 'ADB fixAll' in google drive."

		sleep 1; printf "\nRE0 - Could not connect to just one device; resetting script in..\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
	fi
}

function MAIN(){
	#checking for fatal error while calling the main functions of the script
	if {
		printHead; printf "\nMounting device...\n\n"
		adbWAIT; adb devices
		printTitle
		getOBB; adbWAIT
		getAPK; adbWAIT
		INSTALL
	}; then printf "\nGoodbye!\n"; echo; exit
	else
		printf "\nFE0 - Fatal Error; problem calling main functions.\nPlease report this error code to Nick.\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		echo; exit 1
	fi
}

function getOBB(){ #this function gets the OBB name needed to isolate the monkey events to the app being tested
	read -r -p 'Drag OBB anywhere in here: ' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName
	if [ "$OBBfilePath" == "" ]; then
		export OBBvalid="false"; printHead | wait
		printTitle
		printf "\n%*s\n" $[$COLS/2] "You forgot to drag the OBB!"
		getOBB
	elif [[ ! "$OBBfilePath" == *"com."* ]]; then
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

	until [ $OBBvalid == "true" ]
	do
		printf "%*s\n\n" $[$COLS/2] "That\'s not an OBB!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getOBB
	done

	adbWAIT
	if [[ $deviceConnect == "true" ]]; then
		getAPK
	else
		export deviceConnect="false"; printHead
	fi
}

function getAPK(){
	APKvalid="true"; echo
	read -r -p 'Drag APK anywhere in here: ' APKfilePath

	if [ "$APKfilePath" == "" ]; then
		export APKvalid="false"
		printf "%*s\n\n" $[$COLS/2] "You forgot to drag the APK!"
		getAPK
	elif [[ "$APKfilePath" == *".apk"* ]]; then
		export APKvalid="true"
		local cleanPath="${APKfilePath#*:*}"
		export APKname=$(basename "$cleanPath")

		printf "APK Name: $APKname\n\n"

		adbWAIT
		if [[ $deviceConnect == "true" ]]; then
			INSTALL
		else
			export deviceConnect="false"
			printHead
		fi
	else
		export APKvalid="false"
	fi

	until [ "$APKvalid" == "true" ]
	do
		echo
		printf "%*s\n\n" $[$COLS/2] "That\'s not an APK!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getAPK
	done
}

function INSTALL(){
	if {
		printf "\nUploading OBB..\n"
		adb push "$OBBfilePath" /sdcard/Android/OBB
		printf "\nInstalling APK..\n"
		adb install --no-streaming "$APKfilePath"
	}; then
		printf "\n\nLaunching app."
		adb shell "$launchCMD" > /dev/null 2>&1; sleep 1; printf " ."; sleep 1; printf " .\n"

		errorMessage="Any previous error messages will be printed to a log at this time in the next release!"
		printf "\nGoodbye!\n\n"; exit
	else
			export loopFromError="true"
    		export errorMessage="RE1 - Fatal error while executing INSTALL function.\n\n"
    		export errorMessage+="             $UItrouble\n"
    		export errorMessage+="Ensure only one device is connected and that is has USB Debugging permissions..\n"
    		export errorMessage+="For more help on this, search for ADB fixAll in google drive."

		sleep 1; printf "\nRE1 - The install process could not be executed; resetting script in..\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1

		MAIN
	fi
}

MAIN