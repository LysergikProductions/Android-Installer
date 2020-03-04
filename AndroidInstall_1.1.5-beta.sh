#!/bin/bash
# AndroidInstall_1.1.5-beta.sh
# 2020 © Nikolas A. Wagner
# License: GNU GPLv3
# Build_0141

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

# temp file that includes all system variables on script execution
( set -o posix ; set ) >/tmp/variables.before

# some global variables
build="0141"
scriptVersion="1.1.5-beta"; scriptPrefix="AndroidInstall_"; scriptFileName=$(basename "$0"); scriptTitle=" MONKEY INSTALLER "
adbVersion=$(adb version); bashVersion=${BASH_VERSION}; author="Nikolas A. Wagner"; license="GNU GPLv3"

loopFromError="false"; errorMessage=" ..no error is saved here.. " deviceConnect="true"; currentVersion="error while getting properties.txt"
export OBBdone="false"; export APKdone="false"; upToDate="error checking version"; export UNINSTALL="true"
#oops=$(figlet -F metal -t "Oops!"); export oops="$oops"

# text-UI elements and related variables
UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
export UItrouble="-- Troubleshooting --"; waitMessage="-- waiting for device --"

update(){
	trap "" SIGINT
	clear; printf "\n%*s\n\n" $((COLS/2)) "Updating Script:"

	cpSource="$HOME/upt/Android-Installer/$scriptPrefix$currentVersion.sh"
	cp "$cpSource" "$scriptDIR"; wait; export upToDate="true"

	rm -f "$scriptDIR/$scriptFileName"; wait
	rm -rf ~/upt; wait

	echo "Launching updated version of the script!"; sleep 1
	exec "$scriptDIR/$scriptPrefix$currentVersion.sh"
	trap - SIGINT
}

checkVersion(){
	export terminalPath=""; terminalPath=$(pwd)
	mkdir ~/upt > /dev/null 2>&1

	# clone repo or update it with git pull if it exists already
	(cd ~/upt; git clone https://github.com/LysergikProductions/Android-Installer.git > /dev/null 2>&1) || cd ~/upt/Android-Installer; git pull > /dev/null 2>&1
	wait; cd "$terminalPath"

	# determine value of most up-to-date version and show the user
	currentVersion=$(grep -n "_version " ~/upt/Android-Installer/properties.txt) > /dev/null 2>&1; export currentVersion="${currentVersion##* }" > /dev/null 2>&1

	printf "\n\n\n\n\n%*s\n" $((COLS/2)) "This script: v$scriptVersion"
	printf "%*s\n" $((COLS/2)) "Latest version: v$currentVersion"

	if [ "$scriptVersion" = "$currentVersion" ]; then
		export upToDate="true"
		printf "\n%*s" $((COLS/2)) "This script is up-to-date!"; sleep 1.1
	else
		export upToDate="false"
		printf "\n%*s" $((COLS/2)) "Update required..."; sleep 1.6
		#update # calling update only if necessary
	fi
}

INIT(){ # initializing, then calling checkVersion
	export scriptStartDate=""; scriptStartDate=$(date)
	scriptDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	mkdir ~/logs/ >/dev/null 2>&1

	osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" > /dev/null 2>&1
	COLS=$(tput cols)
	checkVersion; wait
}

help(){
	printf "\noptions\n  -c      also [show-c]; show the copyright information\n  -l      also [show-l]; show the license information\n"
	printf "  -d      also [--debug]; run the script in debug (verbose) mode\n  -h      also [--help]; show this information\n"
	printf "\nskip the OBB step using one of the following:\n  'na', '0', '.'      OBB not applicable\n"
	printf "  'fire'                    Amazon build\n\n"
}

# allow user to see the copyright, license, or the help page without running the script, or to run script in verbose/debug mode
if [ "$*" = "show-c" ] || [ "$*" = "-c" ]; then echo "2020 © Nikolas A. Wagner"; exit
elif [ "$*" = "show-l" ] || [ "$*" = "-l" ]; then echo "GNU GPLv3: https://www.gnu.org/licenses/"; exit
elif [ "$*" = "--help" ] || [ "$*" = "-h" ]; then help; exit
elif [ "$*" = "--debug" ] || [ "$*" = "-d" ]; then clear; verbose=1; echo "Initializing.."; INIT
else clear; verbose=0; echo "Initializing.."; INIT; fi

# set debug variant of core commands
if [ $verbose = 1 ]; then
	CMD_launch(){ printf "\n\nRunning monkey event to launch app..\n\n"; adb shell "$launchCMD"; }
	CMD_communicate(){ echo "Checking device connection status.."; adb shell exit; }

	CMD_pushOBB(){ adb push "$OBBfilePath" /sdcard/Android/OBB; }
	CMD_installAPK-ns(){ adb install -r --no-streaming "$APKfilePath"; }
	CMD_installAPK-def(){ adb install -r "$APKfilePath"; }
	CMD_uninstall(){ echo "Uninstalling $OBBname.."; adb uninstall "$OBBname"; }

	CMD_reset(){ reset; echo "Terminal was reset to prevent errors that could cause issues with SIGINT or tput"; }
	lastCatch(){
		scriptEndDate=$(date)
		printf "\nDebug: This is the last catch statement!\nI make a logfile with ALL system variables called ~/logs/FULL_$scriptEndDate.txt\n\n"
		( set ) > ~/logs/"FULL_$scriptEndDate".txt 2>&1
	}
else # set default variant of core commands
	CMD_launch(){ adb shell "$launchCMD" >/dev/null 2>&1; }
	CMD_communicate(){ adb shell exit >/dev/null 2>&1; }

	CMD_pushOBB(){ adb push "$OBBfilePath" /sdcard/Android/OBB 2>/dev/null; }
	CMD_installAPK-ns(){ adb install -r --no-streaming "$APKfilePath" 2>/dev/null; }
	CMD_installAPK-def(){ adb install -r "$APKfilePath" 2>/dev/null; }
	CMD_uninstall(){ echo "Uninstalling $OBBname.."; wait | adb uninstall "$OBBname" >/dev/null 2>&1; echo "Done!"; }

	CMD_reset(){ reset; }
	lastCatch(){
		scriptEndDate=$(date)
		( set ) > ~/logs/"FULL_$scriptEndDate".txt 2>&1
	}
fi

printHead(){
	if [ $loopFromError = "false" ]; then clear;
		printf "$scriptFileName | Build $build\n2020 © $author\n$UIsep_err0\n\n$adbVersion\n\nBash version $bashVersion\n"
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
	elif [ $loopFromError = "true" ]; then clear;
		printf "$scriptFileName | Build $build\n2020 © $author\n$UIsep_err0\n\n$adbVersion\n\nBash version $bashVersion\n"
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
		printf "$errorMessage\n\n"

		if [ $deviceConnect = "false" ]; then until CMD_communicate; do
			adbWAIT; done
			export deviceConnect="true"
			printf "\r%*s\n\n" $((COLS/2)) "!Device Connected!   "
		elif [ $deviceConnect = "true" ]; then echo
		else
			echo "Unexpected value for deviceConnect: $deviceConnect"
			export deviceConnect="true"
			export errorMessage="$errorMessage\n\n$UIsep_err0\n\n"
			export errorMessage+="ER1 - Script restarted; 'deviceConnect' had an unexpected value."

			printf "\nER1 - Unexpected value in 'deviceConnect'; resetting script in..\n"
			printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
			MAIN
		fi
  	else # if code sets loopFromError to not "true" or "false", then fix value and reset script
		export errorMessage="$errorMessage\n\n$UIsep_err0\n\n"
		export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value."
		export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
  	fi
}

printTitle(){
	#figlet -F border -F gay -t "$scriptTitle"
	printf "\n%*s\n" $((COLS/2)) "$scriptTitle"
	printf "%*s\n\n\n" $((COLS/2)) "$UIsep_title"
}

MAIN(){
	export deviceID=""; export deviceID2=""
	echo; printHead

	# try communicating with device, catch with adbWAIT, finally mount device
	(CMD_communicate && wait) || adb start-server; adbWAIT
	adb shell settings put global development_settings_enabled 1

	printTitle
	tput cnorm; trap - SIGINT # ensure cursor is visible and that crtl-C is functional

	# try running main functions, catch with running exit 1
	adbWAIT &&
	( getOBB && getAPK ) || {
		CMD_reset
		export scriptEndDate=""; scriptEndDate=$(date)
		export errorMessage="FE0 - Fatal Error. Copying all var data into ~/logs/$scriptEndDate.txt"
		printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"

		diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
		exit 1
	}
	exit
}

getOBB(){
	printf "\n%*s\n" $((COLS/2)) "Drag OBB anywhere here and press enter:"
	printf "\nTo skip, use: 'na', '0', or '.',\nor enter 'fire' if you are installing an Amazon build\n\n"
	read -p '' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName

	local cleanPath="${OBBfilePath#*:*}"; OBBname=$(basename "$cleanPath")

	if [ "$OBBfilePath" = "" ]; then
		export OBBvalid="false"
		printHead; printTitle
		#printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n" $((COLS/2)) "You forgot to drag the OBB!"
		getOBB
	elif [ "$OBBfilePath" = "fire" ]; then
		export OBBvalid="true"; OBBdone="true"
		printf "OBB Name: Amazon Build"
		#printf "OBB Name: Amazon Build.. Select your app from this list:"
		#case esac
		#export OBBname="com.budgestudios.amazon.$select"
		export launchCMD="monkey -p $OBBname -c android.intent.category.LAUNCHER 1"
	elif [ "$OBBfilePath" = "na" ] || [ "$OBBfilePath" = "0" ] || [ "$OBBfilePath" = "." ]; then
		export OBBvalid="true"; OBBdone="true"
		printf "OBB Name: N/A"
	elif [[ "$OBBname" == "com."* ]]; then
		export OBBvalid="true"
		printf "OBB Name: $OBBname\n\n"
		export launchCMD="monkey -p $OBBname -c android.intent.category.LAUNCHER 1"
	else
		export OBBvalid="false"
	fi

	until [ "$OBBvalid" = "true" ]; do
		printHead; adbWAIT; adb devices; printTitle
		#printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "\n%*s\n\n" $((COLS/2)) "That is not an OBB!"
		printf "%*s\n\n" $((COLS/2)) "I may be a monkey but I am no fool!"
		getOBB
	done

	if [ "$deviceConnect" = "true" ]; then getAPK; else export deviceConnect="false"; printHead; fi
}

getAPK(){
	APKvalid="true"
	printf "\n%*s\n" $((COLS/2)) "Drag APK anywhere here:"
	read -p '' APKfilePath

	local cleanPath="${APKfilePath#*:*}"; APKname=$(basename "$cleanPath")

	if [ "$APKfilePath" = "" ]; then
		printHead; printTitle
		export APKvalid="false"
		#printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $((COLS/2)) "You forgot to drag the APK!"
		getAPK
	elif [[ "$APKname" == *".apk" ]]; then
		export APKvalid="true"
		printf "APK Name: $APKname\n\n"
		if [ "$deviceConnect" = "true" ]; then INSTALL; else export deviceConnect="false"; printHead; fi
	else export APKvalid="false"; fi

	until [ "$APKvalid" = "true" ]; do
		printHead; adbWAIT; adb devices; printTitle
		#printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $((COLS/2)) "That is not an APK!"
		printf "%*s\n\n" $((COLS/2)) "I may be a monkey but I am no fool!"
		getAPK
	done
}

INSTALL(){
	printHead; adbWAIT; printTitle

	export deviceID=""; deviceID=$(adb devices)
	printf "\nMounting device...\n\n"; adb devices

	if [ "$UNINSTALL" = "true" ]; then
		wait | CMD_uninstall
		UNINSTALL="true"
	fi

	if (
		# install the OBB if it hasn't been installed already
		if [ "$OBBdone" = "false" ]; then
			printf "\nUploading OBB..\n"

			if [[ "$OBBname" == "com."* ]]; then
				trap "" SIGINT
				(CMD_pushOBB) || {
					(CMD_communicate) || deviceConnect="false"
					if [ "$deviceConnect" = "true" ]; then
						export errorMessage="FE1a - OBB could not be installed."
						printf "\n\nFE1a - OBB could not be installed.\n"

						( set -o posix ; set ) >/tmp/variables.after
						echo "Please report this error code (FE1a) to Nick."; exit 1
					fi
					trap - SIGINT; INSTALL
				}
				trap - SIGINT
			fi
			export OBBdone="true"
		fi

		# install the APK if it hasn't been installed already
		if [ "$APKdone" = "false" ]; then
			printf "\nInstalling APK..\n"

			if [[ "$APKname" == *".apk" ]]; then
				trap "" SIGINT
				((CMD_installAPK-ns || (trap - SIGINT; exit 1)) || {
					printf "\n--no-streaming option failed\n\nAttempting default install type..\n"
					CMD_installAPK-def
				}) || {
					(CMD_communicate) || deviceConnect="false"
					if [ "$deviceConnect" = "true" ]; then
						export errorMessage="FE1b - APK could not be installed."
						printf "\n\nFE1b - APK could not be installed.\n"

						( set -o posix ; set ) >/tmp/variables.after
						echo "Please report this error code (FE1b) to Nick."; exit 1
					fi
					UNINSTALL="false"; APKdone="false"; trap - SIGINT; INSTALL
				}
				trap - SIGINT
			fi
			export APKdone="true"
		fi
	); then # subshell did not throw error, so, launch the app if possible and otherwise skip launching and just call installAgain
		if [ "$OBBfilePath" = "fire" ] || [ "$OBBfilePath" = "." ] || [ "$OBBfilePath" = "0" ] || [ "$OBBfilePath" = "na" ]; then
			trap - SIGINT; adbWAIT; deviceID=$(adb devices)
			tput cnorm; installAgainPrompt; exit 1
		else
			CMD_launch
			printf "\n\nLaunching app."; sleep 0.4; printf " ."; sleep 0.4; printf " ."; sleep 0.4; printf " .\n"
			tput cnorm; installAgainPrompt; exit 1
		fi
	else
		export errorMessage="FE1b - APK could not be installed."
		printf "\n\nFE1b - APK could not be installed.\n"

		( set -o posix ; set ) >/tmp/variables.after

		echo "Please report this error code (FE1b) to Nick."; exit 1
	fi
}

# check if user wants to install again on another device, or the same device if they choose to
installAgainPrompt(){
	printf "\n%*s\n" $((COLS/2)) "Press 'q' to quit, or press any other key to install this build on another device.."

	read -n 1 -s -r -p ''
	if [ "$REPLY" = "q" ]; then
		echo; exit
	else
		export OBBdone="false"; export APKdone="false"
	fi
	installAgain
}

installAgain(){
	trap - SIGINT
	export deviceID2=""; adbWAIT
	deviceID2=$(adb devices); wait

	if [ "$deviceID" = "$deviceID2" ]; then
		printHead; adb devices; printTitle
		printf "\n\n%*s\n" $((COLS/2)) "This is the same device! Are you sure you want to install the build on this device again?"
		printf "\n%*s\n" $((COLS/2)) "Press 'y' to install on the same device, or any other key when you have plugged in another device."

		read -n 1 -s -r -p ''
		if [ "$REPLY" = "y" ]; then
			UNINSTALL="true"; INSTALL
		else
			adbWAIT; deviceID2=$(adb devices); wait; installAgainPrompt; exit 1
		fi
	else
		INSTALL
	fi
	tput cnorm
}

# update the script on status of adb connection and call waiting function until it is ready
adbWAIT(){
	if (CMD_communicate); then
		export deviceConnect="true"
	else
		tput civis
		printf "\n\n%*s\n" $((COLS/2)) "$waitMessage"
		until (CMD_communicate); do waiting; done

		export deviceConnect="true"; tput cnorm
		printf "\r%*s\n\n" $((COLS/2)) "!Device Connected!   "
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
	"101011011101001110011001" "011010110001101101110110" "101010010101100000100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111010" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000010111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110000100010" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	)

	for i in "${anim4[@]}"
	do
		printf "\r%*s" $((COLS/2)) "$i"
		sleep 0.04
	done
}

# try, catch
( MAIN && printf "\nDebug: There were no critical errors!\n\n" ) || lastCatch

# finally
rm -rf /tmp/variables.before /tmp/variables.after ~/upt >/dev/null 2>&1
printf "\nGoodbye!\n"; exit