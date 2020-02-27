#!/bin/bash
#AndroidInstall_1.1.4-release.sh
#Nikolas A. Wagner © 2020
#License: GNU GPLv3

#                                          -- Description --
# Simplifies the process of installing builds on Android devices via Mac OSX using Android Debug Bridge

# make a temp file that includes all variables in the system to later compare to after this script is run..
# this allows the script to print out the value of every variable in this script into a log file on fatal exit
( set -o posix ; set ) >/tmp/variables.before

#some global variables
scriptName="AndroidInstall_1.1.4-release"; scriptTitle=" MONKEY INSTALLER "; author="Nikolas A. Wagner"; license="GNU GPLv3"
scriptVersion="1.1.4"; scriptVersionType="release"; bashVersion=${BASH_VERSION}; adbVersion=$(adb version)

loopFromError="false"; errorMessage=" ..no error is saved here.. " deviceConnect="false"
export OBBdone="false"; export APKdone="false"; oops=$(figlet -F border -F gay -t "Oops!"); export oops="$oops"

COLS=$(tput cols) # Text-UI elements and related variables
UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
UItrouble="-- Troubleshooting --"; waitMessage="-- waiting for device --"

function INIT(){
	osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" > /dev/null 2>&1 # set font size on Mac OSX Terminal
	clear; echo "Initializing.."; sleep 0.8
	scriptStartDate=$(date)
	checkADB > /dev/null 2>&1

	#if toilet -h > /dev/null 2>&1; then echo;
	#else
	#	printf "\n\nInstalling missing packages.."
	#	echo ""; sleep 2
	#	brew install toilet || sudo apt install toilet
	#fi
}; INIT

function printHead(){
	if [ $loopFromError = "false" ]; then clear;
		printf "$scriptName\nby $author\n\n$adbVersion\nBash version $bashVersion\n\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
	elif [ $loopFromError = "true" ]; then clear;
		printf "$scriptName\nby $author\n\n$adbVersion\nBash version $bashVersion\n\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
		printf "$errorMessage\n\n"

		if [ $deviceConnect = "false" ]; then
			until adb shell exit >/dev/null 2>&1; do
				export deviceConnect="false"
				waiting
			done
			printf "\r%*s\n\n" $[$COLS/2] "!Device Connected!   "
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
		printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
  	fi
}

function printTitle(){
	#toilet -t --gay "$scriptTitle"
	figlet -F border -F gay -t "$scriptTitle"
	#printf "\n%*s\n" $[$COLS/2] "$scriptTitle"
	#printf "%*s\n\n\n" $[$COLS/2] "$UIsep_title"
}

function MAIN(){
	printHead
	if (adb shell settings put global development_settings_enabled 1); then
		printf "\nMounting device...\n\n"; adb devices; export deviceID=$(adb devices)
		printTitle
	else
		printf "\n\n%*s\n" $[$COLS/2] "$waitMessage"; adbWAIT
		printf "\nMounting device...\n\n"; adb devices; export deviceID=$(adb devices)
		printTitle
	fi

	#checking for fatal error while calling the main functions of the script
	if {
		getOBB; getAPK; adbWAIT; INSTALL
	}; then printf "\nGoodbye!\n"; echo; exit
	else
		export errorMessage="FE0 - Fatal Error; problem calling main functions."
		scriptEndDate=$(date)
		printf "\nFE0 - Fatal Error; problem calling main functions.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"; sleep 1

		mkdir ~/logs/ > /dev/null 2>&1;
		( set -o posix ; set ) >/tmp/variables.after
		diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt
		rm /tmp/variables.before /tmp/variables.after

		sleep 1; echo "Please report this error code (FE0) to Nick."; exit 1
	fi
}

#check if the user has ADB installed, and if not then it install it on Mac OSX using HomeBrew
function checkADB(){
	local instruct="Would you like to install ADB now?"
	local options=("OK" "Cancel and Exit")

	#check if a network is available and update netReady boolean
	ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && export netReady="true" || export netReady="false"

	if adb version > /dev/null 2>&1; then
		wait; clear
	else #ADB is not installed; attempt to install it with HomeBrew..
		if [ "$netReady" = "false" ]; then
			until [ "$netReady" = "true" ]
			do
				clear; ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && export netReady="true" || export netReady="false"
				printf "\nWaiting for an available network ."; sleep 1; printf " ."; sleep 1; printf " ."; sleep 1; wait
			done
			echo
			checkADB
		elif [ "$netReady" = "true" ]; then
			echo
		else
			echo "error in netReady"
		fi

		echo "Connected to network!"
		printf "\nADB is not installed on this computer.. ADB is required to run this script.\n\n"; sleep 1
		echo "$instruct" #here the user is asked if they want to install ADB on their machine
		select opt in "${options[@]}"
		do
			case $opt in
	        "OK")
				echo
				if {brew cask install android-platform-tools}; then
					wait; echo; adbVersion=$(adb version)
					wait; sleep 3; printf "\nAndroid Debug Bridge (ADB) has been successfully installed. Launching MONKEY STRESS in..\n"
					printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
				else #HomeBrew is not installed; installing HomeBrew..
					printf "\nHomeBrew needs to be installed for this. Installing HomeBrew..\n"
					if {ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"}; then
						wait; sleep 3; printf "\nHomebrew has been successfully installed. Installing ADB next..\n"
					else
						printf "\nFE2a - Fatal Error; ADB not installed and there was a problem while trying to install HomeBrew.\nPlease report this error code (FE2a) to Nick.\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						echo; exit 1
					fi
					#now that HomeBrew is installed, install ADB using HomeBrew
					if {brew cask install android-platform-tools}; then
						wait; echo; adbVersion=$(adb version)
						wait; sleep 3; printf "\nAndroid Debug Bridge (ADB) has been successfully installed. Launching MONKEY STRESS in..\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
					else
						printf "\nFE2b - Fatal Error; ADB not installed and there was a problem while trying to install platform-tools.\nPlease report this error code (FE2b) to Nick.\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						echo; exit 1
					fi
				fi
				break
					;;
			"Cancel and Exit")
				printf "\nGoodbye!\n"; sleep 1
				exit
				break
					;;
			*) printf "\nSorry, $REPLY is not an option!\n";;
			esac
		done
	fi
}

function getOBB(){ #this function gets the OBB name needed to isolate the monkey events to the app being tested
	printf "\n%*s\n" $[$COLS/2] "Drag OBB anywhere here:"
	read -p '' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName
	local cleanPath="${OBBfilePath#*:*}"; export OBBname=$(basename "$cleanPath")

	if [ "$OBBfilePath" = "" ]; then
		export OBBvalid="false"
		printHead; printTitle
		printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n" $[$COLS/2] "You forgot to drag the OBB!"
		getOBB
	elif [ "$OBBfilePath" = "fire" ]; then
		export OBBvalid="true"
		printf "OBB Name: Amazon Build"
	elif [ "$OBBfilePath" = "no" ] || [ "$OBBfilePath" = "0" ]; then
		export OBBvalid="true"
		printf "OBB Name: N/A"
	elif [[ ! "$OBBname" == "com."* ]]; then
		export OBBvalid="false"
	else
		export OBBvalid="true"
		printf "OBB Name: $OBBname\n\n"
		export launchCMD="monkey -p $OBBname -v 1"
		adb uninstall $OBBname > /dev/null 2>&1; wait
	fi

	until [ "$OBBvalid" = "true" ]; do
		printHead; printTitle
		printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "\n%*s\n\n" $[$COLS/2] "That is not an OBB!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getOBB
	done

	adbWAIT
	if [ "$deviceConnect" = "true" ]; then getAPK; else export deviceConnect="false"; printHead; fi
}

function getAPK(){
	APKvalid="true"
	printf "\n%*s\n" $[$COLS/2] "Drag APK anywhere here:"
	read -p '' APKfilePath
	local cleanPath="${APKfilePath#*:*}"
	export APKname=$(basename "$cleanPath")

	if [ "$APKfilePath" = "" ]; then
		printHead; printTitle
		export APKvalid="false"
		printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $[$COLS/2] "You forgot to drag the APK!"
		getAPK
	elif [[ "$APKname" == *".apk" ]]; then
		export APKvalid="true"
		printf "APK Name: $APKname\n\n"

		adbWAIT
		if [ "$deviceConnect" = "true" ]; then INSTALL; else export deviceConnect="false"; printHead; fi
	else export APKvalid="false"; fi

	until [ "$APKvalid" = "true" ]; do
		printHead; printTitle
		printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $[$COLS/2] "That is not an APK!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getAPK
	done
}

function INSTALL(){
	adbWAIT
	if {
		printf "\nUploading OBB..\n"
		if [ "$OBBdone" = "false" ]; then
			if (adb push "$OBBfilePath" /sdcard/Android/OBB); then export OBBdone="true"; adbWAIT
			else
				if [ "$OBBfilePath" = "bw" ]; then
					echo
				else
					adbWAIT
					echo; printf "\nRE1 - Invalid OBB; resetting script in..\n"
					printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 0.5
					MAIN
				fi
			fi
		fi

		printf "\nInstalling APK..\n"
		if [ "$APKdone" = "false" ]; then
			if (
				if (adb install --no-streaming "$APKfilePath" 2>/dev/null); then wait; export APKdone="true"; else adb install "$APKfilePath"; wait; export APKdone="true"; fi
			); then wait; export APKdone="true"; fi
		fi
	}; then
		printf "\n\nLaunching app."
		adb shell "$launchCMD" > /dev/null 2>&1; sleep 1; printf " ."; sleep 1; printf " .\n"

		installAgain
	else
		export errorMessage="FE1 - Fatal Error; install was unsuccesful for unknown reasons."
		scriptEndDate=$(date)
		printf "\n\nFE1 - Fatal Error; install was unsuccesful for unknown reasons.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"; sleep 1

		mkdir ~/logs/ > /dev/null 2>&1;
		( set -o posix ; set ) >/tmp/variables.after
		diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt
		rm /tmp/variables.before /tmp/variables.after

		sleep 1; echo "Please report this error code (FE1) to Nick."; exit 1
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

	if [ "$scriptVersion" = "$currentVersion" ]; then
		printf "\n%*s" $[$COLS/2] "This script is up-to-date!"
	else printf "\n%*s" $[$COLS/2] "Update required..."; fi
}; checkVersion; sleep 2

# update the script on status of adb connection and wait until it is ready
function adbWAIT(){
	if (adb shell exit >/dev/null 2>&1); then
		export deviceConnect="true"
	else
		until (adb shell exit >/dev/null 2>&1); do waiting; done
		export deviceConnect="true"
		printf "\r%*s\n\n" $[$COLS/2] "!Device Connected!   "
	fi
}

# show the waiting 'animation'
function waiting(){
	local anim1=( "" " ." " . ." " . . ." " . . . ." " . . . . ." )
	local anim2=(
	"oooooooooooooooooooooooo"
	"Oooooooooooooooooooooooo" "oOoooooooooooooooooooooo" "ooOooooooooooooooooooooo" "oooOoooooooooooooooooooo" "ooooOooooooooooooooooooo" "oooooOoooooooooooooooooo"
	"ooooooOooooooooooooooooo" "oooooooOoooooooooooooooo" "ooooooooOooooooooooooooo" "oooooooooOoooooooooooooo" "ooooooooooOooooooooooooo" "oooooooooooOoooooooooooo"
	"ooooooooooooOooooooooooo" "oooooooooooooOoooooooooo" "ooooooooooooooOooooooooo" "oooooooooooooooOoooooooo" "ooooooooooooooooOooooooo" "oooooooooooooooooOoooooo"
	"ooooooooooooooooooOooooo" "oooooooooooooooooooOoooo" "ooooooooooooooooooooOooo" "oooooooooooooooooooooOoo" "ooooooooooooooooooooooOo" "oooooooooooooooooooooooO"
	)
	local anim3=(
	"oooooooooooooooooooooooo"
	"ooooooooooo00ooooooooooo" "oooooooooo0oo0oooooooooo" "ooooooooo0oooo0ooooooooo" "oooooooo0oooooo0oooooooo" "ooooooo0oooooooo0ooooooo" "oooooo0oooooooooo0oooooo"
	"ooooo0oooooooooooo0ooooo" "oooo0oooooooooooooo0oooo" "ooo0oooooooooooooooo0ooo" "oo0oooooooooooooooooo0oo" "o0oooooooooooooooooooo0o" "0oooooooooooooooooooooo0"
	"oooooooooooooooooooooooo" "0oooooooooooooooooooooo0" "o0oooooooooooooooooooo0o" "oo0oooooooooooooooooo0oo" "ooo0oooooooooooooooo0ooo" "ooo0oooooooooooooooo0ooo"
	"oooo0oooooooooooooo0oooo" "ooooo0oooooooooooo0ooooo" "oooooo0oooooooooo0oooooo" "ooooooo0oooooooo0ooooooo" "oooooooo0oooooo0oooooooo" "ooooooooo0oooo0ooooooooo"
	"oooooooooo0oo0oooooooooo" "ooooooooooo00ooooooooooo" "oooooooooooooooooooooooo"
	)
	local anim4=(
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"100011011101001110011001" "011010110001101101110110" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"101011011101001110011001" "011010110001101101110110" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	)

	#printf "$scriptName\nby $author\n\n$adbVersion\nBash version $bashVersion\n\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
    #printf "$errorMessage\n\n\n"
    printf "\r%*s" $(($COLS/2)) "$waitMessage"

	for i in "${anim4[@]}"
	do
		printf "\r%*s" $(($COLS/2)) "$i"
		sleep 0.05
		#sleep 0.08
	done
}

function installAgain(){
	printf "\n%*s\n" $[$COLS/2] "Press 'q' to quit, or press any other key to install this build on another device.."
	read -n 1 -s -r -p ''
	if [ "$REPLY" = "q" ]; then
		echo; exit
	else
		export deviceID2=$(adb devices); wait
		if [ "$deviceID" = "$deviceID2" ]; then
			printf "\n\n%*s\n" $[$COLS/2] "This is same device! Are you sure you want to install the build on this device again?"
			printf "\n%*s\n" $[$COLS/2] "Press 'y' to install on the same device, or any other key when you have plugged in another device."
			read -n 1 -s -r -p ''
			if [ "$REPLY" = "y" ]; then OBBdone="false"; APKdone="false"; INSTALL; else export deviceID=$(adb devices); wait; installAgain; fi
		else
			INSTALL
		fi
	fi
}

{ # try to run the MAIN function
    MAIN &&
    printf "\nDebug: MAIN completed without errors!\n"
} || {
    printf "\nDebug: MAIN is caught having an error!\n"
}

#Say goodbye when done everything, regardless of an exit
printf "\nGoodbye!\n"; exit
