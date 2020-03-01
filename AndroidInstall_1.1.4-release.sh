#!/bin/bash
# AndroidInstall_1.1.4-release.sh
# 2020 © Nikolas A. Wagner
# License: GNU GPLv3

	#This program is free software: you can redistribute it and/or modify
    #it under the terms of the GNU General Public License as published by
    #the Free Software Foundation, either version 3 of the License, or
    #(at your option) any later version.

    #This program is distributed in the hope that it will be useful,
    #but WITHOUT ANY WARRANTY; without even the implied warranty of
    #MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    #GNU General Public License for more details.

    #You should have received a copy of the GNU General Public License
    #along with this program.  If not, see <https://www.gnu.org/licenses/>.

#                                          -- Description --
# Simplifies the process of installing builds on Android devices via Mac OSX using Android Debug Bridge
#                                          --  -  ---  -  --

# allow user to see copyright or license without running the script
if [ "$1" = "show-c" ] || [ "$1" = "-c" ]; then echo "2020 © Nikolas A. Wagner"; exit
elif [ "$1" = "show-l" ] || [ "$1" = "-l" ]; then echo "GNU GPLv3: https://www.gnu.org/licenses/"; exit; fi

# help option '--help' or '-h'
help(){
	printf "\noptions\n  show-c      show the copyright information\n  show-l      show the license information\n"
	printf "\nskip OBB step using one of the following\n  'na', 'no', 'none', '0', '.'      OBB not applicable\n  'fire'                            Amazon build\n"
}
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then help; exit; fi

# make a temp file that includes all variables in the system to later compare to after this script is run; for error logging
( set -o posix ; set ) >/tmp/variables.before

# some global variables
scriptVersion="1.1.4-release"; scriptPrefix="AndroidInstall_"; bashVersion=${BASH_VERSION}; adbVersion=$(adb version)
scriptFileName=`basename "$0"`; scriptTitle=" MONKEY INSTALLER "; author="Nikolas A. Wagner"; license="GNU GPLv3"

loopFromError="false"; errorMessage=" ..no error is saved here.. " deviceConnect="true"; currentVersion="error while getting properties.txt"
export OBBdone="false"; export APKdone="false"; upToDate="error checking version"; #oops=$(figlet -F metal -t "Oops!"); export oops="$oops"

COLS=$(tput cols) # text-UI elements and related variables
UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
UItrouble="-- Troubleshooting --"; waitMessage="-- waiting for device --"

checkVersion(){
	# clone repo or update it with git pull if it exists already
	export terminalPath=$(pwd)
	mkdir ~/upt > /dev/null 2>&1
	(cd ~/upt; git clone https://github.com/LysergikProductions/Android-Installer.git > /dev/null 2>&1) || (cd ~/upt/Android-Installer; git pull > /dev/null 2>&1)
	wait; cd "$terminalPath"

	# determine value of most up-to-date version and show the user
	currentVersion=$(grep -n "_version " ~/upt/Android-Installer/properties.txt) > /dev/null 2>&1; export currentVersion="${currentVersion##* }" > /dev/null 2>&1
	printf "\n\n\n\n\n%*s\n" $[$COLS/2] "This script: v$scriptVersion"
	printf "%*s\n" $[$COLS/2] "Latest version: v$currentVersion"

	if [ "$scriptVersion" = "$currentVersion" ]; then
		upToDate="true"
		printf "\n%*s" $[$COLS/2] "This script is up-to-date!"; sleep 1.1
	else
		upToDate="false"
		printf "\n%*s" $[$COLS/2] "Update required..."; sleep 1.6
		#update
	fi
}

update(){
	clear; printf "\n%*s\n\n" $[$COLS/2] "Updating Script:"

	cpSource="~/upt/Android-Installer/$scriptPrefix$currentVersion.sh"
	cp "$cpSource" "$scriptDIR"; wait; upToDate="true"

	rm -f "$scriptDIR/$scriptFileName"; wait
	rm -rf "~/upt"; wait

	echo "Launching updated version of the script!"; sleep 1
	exec "$scriptDIR/$scriptPrefix$currentVersion.sh"
}

INIT(){
	clear; echo "Initializing.."; sleep 0.5
	scriptStartDate=$(date)
	scriptDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	mkdir ~/logs/ > /dev/null 2>&1

	osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" > /dev/null 2>&1
	checkVersion; wait
}; INIT

printHead(){
	if [ $loopFromError = "false" ]; then clear;
		printf "$scriptFileName\nby $author\n\n$adbVersion\nBash version $bashVersion\n\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
	elif [ $loopFromError = "true" ]; then clear;
		printf "$scriptFileName\nby $author\n\n$adbVersion\nBash version $bashVersion\n\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
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

printTitle(){
	#toilet -t --gay "$scriptTitle"
	#figlet -F border -F gay -t "$scriptTitle"
	printf "\n%*s\n" $[$COLS/2] "$scriptTitle"
	printf "%*s\n\n\n" $[$COLS/2] "$UIsep_title"
}

MAIN(){
	printHead
	if (adb shell settings put global development_settings_enabled 1); then
		printf "\nMounting device...\n\n"; adb devices; export deviceID=$(adb devices)
		printTitle
	else
		adbWAIT
		printf "\nMounting device...\n\n"; adb devices; export deviceID=$(adb devices)
		printTitle
	fi

	# check for fatal error while calling the main functions of the script
	if (
		getOBB; getAPK; INSTALL
	); then printf "\nGoodbye!\n"; echo; exit
	else
		scriptEndDate=$(date)
		printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"
		sleep 1; exit 1
	fi
}

getOBB(){
	printf "\n%*s\n" $[$COLS/2] "Drag OBB anywhere here:"
	read -p '' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName
	local cleanPath="${OBBfilePath#*:*}"; export OBBname=$(basename "$cleanPath")

	if [ "$OBBfilePath" = "" ]; then
		export OBBvalid="false"
		printHead; printTitle
		#printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n" $[$COLS/2] "You forgot to drag the OBB!"
		getOBB
	elif [ "$OBBfilePath" = "fire" ]; then
		export OBBvalid="true"; OBBdone="true"
		printf "OBB Name: Amazon Build"
	elif [ "$OBBfilePath" = "no" ] || [ "$OBBfilePath" = "none" ] || [ "$OBBfilePath" = "na" ] || [ "$OBBfilePath" = "0" ] || [ "$OBBfilePath" = "." ]; then
		export OBBvalid="true"; OBBdone="true"
		printf "OBB Name: N/A"
	elif [[ "$OBBname" == "com."* ]]; then
		export OBBvalid="true"
		printf "OBB Name: $OBBname\n\n"
		export launchCMD="monkey -p $OBBname -v 1"
	else
		export OBBvalid="false"
	fi

	until [ "$OBBvalid" = "true" ]; do
		printHead; printTitle
		#printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "\n%*s\n\n" $[$COLS/2] "That is not an OBB!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getOBB
	done

	if [ "$deviceConnect" = "true" ]; then getAPK; else export deviceConnect="false"; printHead; fi
}

getAPK(){
	APKvalid="true"
	printf "\n%*s\n" $[$COLS/2] "Drag APK anywhere here:"
	read -p '' APKfilePath
	local cleanPath="${APKfilePath#*:*}"
	export APKname=$(basename "$cleanPath")

	if [ "$APKfilePath" = "" ]; then
		printHead; printTitle
		export APKvalid="false"
		#printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $[$COLS/2] "You forgot to drag the APK!"
		getAPK
	elif [[ "$APKname" == *".apk" ]]; then
		export APKvalid="true"
		printf "APK Name: $APKname\n\n"
		if [ "$deviceConnect" = "true" ]; then INSTALL; else export deviceConnect="false"; printHead; fi
	else export APKvalid="false"; fi

	until [ "$APKvalid" = "true" ]; do
		printHead; printTitle
		#printf "%*s\n" $(($COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $[$COLS/2] "That is not an APK!"
		printf "%*s\n\n" $[$COLS/2] "I may be a monkey but I am no fool!"
		getAPK
	done
}

INSTALL(){
	adbWAIT; adb uninstall "$OBBname" > /dev/null 2>&1; wait
	if (
		# install the OBB if it hasn't been installed already
		if [ "$OBBdone" = "false" ]; then
			printf "\nUploading OBB..\n"
			if (adb push "$OBBfilePath" /sdcard/Android/OBB); then
				export OBBdone="true"
				adbWAIT
			else
				if [ "$OBBname" = "bw" ]; then
					adbWAIT
					echo; printf "\nRE1 - Invalid OBB; resetting script in..\n"
					printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 0.5
					MAIN
				else
					export errorMessage="FE1a - OBB could not be installed."
					printf "\n\nFE1a - OBB could not be installed.\n\n"; sleep 1

					scriptEndDate=$(date)
					( set -o posix ; set ) >/tmp/variables.after
					diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt

					sleep 1; echo "Please report this error code (FE1a) to Nick."; exit 1
				fi
			fi
		fi

		# install the APK if it hasn't been installed already
		if [ "$APKdone" = "false" ]; then
			printf "\nInstalling APK..\n"
			if (
				if (adb install --no-streaming "$APKfilePath"); then
					wait; export APKdone="true"
				else
					printf "\n\n--no-streaming option unavailable, attempting default install type..\n\n"
					if (adb install "$APKfilePath"); then
						wait; export APKdone="true"
					else
						exit
					fi
				fi
			); then
				export APKdone="true"
			else exit; fi
		fi
	); then # subshell did not exit unexpectedly, so launch the app if possible, otherwise skip launching and just call installAgain
		if (adb shell "$launchCMD" > /dev/null 2>&1); then
			printf "\n\nLaunching app."; sleep 0.5; printf " ."; sleep 0.5; printf " ."; sleep 0.5; printf " ."; sleep 0.5; printf " .\n"
			installAgain
		else
			installAgain
		fi
	else
		export errorMessage="FE1b - APK could not be installed."
		printf "\n\nFE1b - APK could not be installed.\n\n"; sleep 1

		scriptEndDate=$(date)
		( set -o posix ; set ) >/tmp/variables.after
		diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt

		sleep 1; echo "Please report this error code (FE1b) to Nick."; exit 1
	fi
}

# check if user wants to install again on another device, or the same device if they choose to
installAgain(){
	printf "\n%*s\n" $[$COLS/2] "Press 'q' to quit, or press any other key to install this build on another device.."
	adbWAIT
	read -n 1 -s -r -p ''
	if [ "$REPLY" = "q" ]; then
		echo; exit
	else
		export OBBdone="false"; export APKdone="false"
		export deviceID2=$(adb devices); wait
		if [ "$deviceID" = "$deviceID2" ]; then
			printf "\n\n%*s\n" $[$COLS/2] "This is same device! Are you sure you want to install the build on this device again?"
			printf "\n%*s\n" $[$COLS/2] "Press 'y' to install on the same device, or any other key when you have plugged in another device."
			read -n 1 -s -r -p ''
			if [ "$REPLY" = "y" ]; then
				export launchCMD="monkey -p $OBBname -v 1"; INSTALL
			else
				adbWAIT; export deviceID=$(adb devices); wait
				installAgain
			fi
		else
			INSTALL
		fi
	fi
}

# update the script on status of adb connection and call waiting function until it is ready
adbWAIT(){
	if (adb shell exit >/dev/null 2>&1); then
		export deviceConnect="true"
	else
		tput civis
		printf "\n\n%*s\n" $[$COLS/2] "$waitMessage"
		until (adb shell exit >/dev/null 2>&1); do waiting; done
		export deviceConnect="true"; tput cnorm
		printf "\r%*s\n\n" $[$COLS/2] "!Device Connected!   "
	fi
}

# show the waiting 'animation'
waiting(){
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
	"100011011101001110011001" "011010110001101101110110" "101010010101110100100010" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"101011011101001110011001" "011010110001101101110110" "101010010101110000100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111010" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000010111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110000100010" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	)

	for i in "${anim4[@]}"
	do
		printf "\r%*s" $(($COLS/2)) "$i"
		sleep 0.04
	done
}

# try, catch, finally
(MAIN) && (printf "\nDebug: There were no critical errors!\n") || printf "\nDebug: This is the catch statement!\n"

# this is the finally statement
rm /tmp/variables.before /tmp/variables.after >/dev/null 2>&1
printf "\nGoodbye!\n"; exit
