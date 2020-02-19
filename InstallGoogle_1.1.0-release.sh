#!/bin/bash
#InstallGoogle_1.1.0-release.sh
#Nikolas A. Wagner © 2020

scriptName="InstallGoogle_1.1.0-release"; scriptTitle="MONKEY INSTALLER"; author="Nikolas A. Wagner"
scriptVersion="1.1.0"; scriptVersionType="release"; license="GNU GPLv3"
loopFromError="false"; errorMessage=" ..no error is saved here.. " deviceConnect="true"; adbVersion=$(adb version)

#this script simplifies the process of manually installing builds on Android devices via Mac OSX using Android Debug Bridge

function MAIN() {
	if [ $loopFromError = "false" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
	elif [ $loopFromError = "true" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "$errorMessage\n\n"

    	if [ $deviceConnect = "false" ]; then
			until adb shell exit
			do
				clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
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
  	else
    	export errorMessage="$errorMessage\n\n--------------------------------\n\n"
    	export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value."
    	export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
  	fi
	wait
	
	#Check for device connection; reset script in case of error
	printf "\nMounting device...\n\n"
	if adb shell exit && adb devices; then
		deviceConnect="true"; adbVersion=$(adb version)
	else
		loopFromError="true"; deviceConnect="false"
		export errorMessage="RE0 - Script restarted; could not connect to just one device.\n\n"
    	export errorMessage+="             -- Troubleshooting --\n"
    	export errorMessage+="Ensure only one device is connected and that is has USB Debugging permissions..\n"
    	export errorMessage+="For more help on this, search 'ADB fixAll' in google drive."

		sleep 1; printf "\nRE0 - Could not connect to just one device; resetting script in..\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
	fi
	
	getOBB; getAPK; INSTALL
	exit
}

function getOBB(){ #this function gets the OBB name needed to isolate the monkey events to the app being tested
	read -p 'Drag OBB here: ' OBBfilePath #i.e. Server:\ folder/folder/folder/com.studio.platform.appName
	if [ "$OBBfilePath" == "" ]; then
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "Most Recent Error:\n$errorMessage\n\n--------------------------------\n"
		printf "You forgot to drag the OBB!\n\n"
		export OBBvalid="false"; getOBB
	elif [ "$OBBfilePath" == *".amazon."* ]; then
		export amazonBuild="true"; export OBBvalid="true"
		export OBBname=$(basename "$OBBfilePath"); printf "OBB Name: $OBBname\n\n"
	elif [ "$OBBfilePath" == "bw" ]; then
		export OBB="com.budgestudios.googleplay.BudgeWorld"
		export OBBname="com.budgestudios.googleplay.BudgeWorld"; printf "OBB Name: $OBBname\n\n"
		export OBBvalid="true"
		export launchCMD="monkey -p $OBBname -v 1"
	else
		export OBBname=$(basename "$OBBfilePath"); printf "OBB Name: $OBBname\n\n"
		export launchCMD="monkey -p $OBBname -v 1"; export amazonBuild="false"
		export OBBvalid="true"
	fi
	
	until [ $OBBvalid == "true" ]
	do
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "Most Recent Error:\n$errorMessage\n\n--------------------------------\n"
		printf "That's not an OBB! I may be a monkey but I am no fool!\n\n"; getOBB
	done
}

function getAPK(){
	read -p 'Drag APK here: ' APKfilePath
	if [ "$APKfilePath" == "" ]; then
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "Most Recent Error:\n$errorMessage\n\n--------------------------------\n"
		printf "You forgot to drag the APK!\n\n"; getAPK
	else
		until [[ "$APKfilePath" == *".apk"* ]]
		do
			clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    		printf "Most Recent Error:\n$errorMessage\n\n--------------------------------\n"
			printf "That's not an APK! I may be a monkey but I am no fool!\n\n"; getAPK
		done
		export APKname=$(basename "$APKfilePath")
	fi
}

function INSTALL(){
	if {
		printf "\nUploading OBB..\n"
		adb push "$OBBfilePath" /sdcard/Android/OBB
		printf "\nInstalling APK..\n"
		adb install --no-streaming "$APKfilePath"
	}; then
		printf "\nSuccess! Launching app..\n\n"
		adb shell "$launchCMD"
		
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
		printf "Success!\n\n"
	else
		export loopFromError="true"
    	export errorMessage="RE1 - Script restarted; the app could not be installed.\n\n"
    	export errorMessage+="             -- Troubleshooting --\n"
    	export errorMessage+="Ensure only one device is connected and that is has USB Debugging permissions..\n"
    	export errorMessage+="For more help on this, search 'ADB fixAll' in google drive."

		sleep 1; printf "\nRE0 - The install process could not be executed; resetting script in..\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		
		MAIN
	fi
}

MAIN
