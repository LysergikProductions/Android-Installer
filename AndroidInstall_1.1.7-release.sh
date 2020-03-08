#!/bin/bash
# AndroidInstall_1.1.7-release.sh
# 2020 (C) Nikolas A. Wagner
# License: GNU GPLv3
# Build_0213

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
build="0213"; author="Nikolas A. Wagner"; license="GNU GPLv3"; gitName="Android-Installer"
scriptTitleDEF=" MONKEY INSTALLER "; scriptPrefix="AndroidInstall_"; scriptFileName=$(basename "$0")
export scriptVersion=1.1.7-release; adbVersion=$(adb version); bashVersion=${BASH_VERSION}; currentVersion="_version errorGettingProperties.txt"

# studio specific variables
fireAPPS=( "GO BACK" "option1" "option2" "option3" "option4" "option5" "option6" "option7" )
studio=""

help(){
	clear; printf "$scriptTitle help page:\n\n"
	printf " - OPTIONS -\n\n  -c      also [show-c]; show the copyright information\n  -l      also [show-l]; show the license information\n"
	printf "  -u      also [--update]; run the script in update mode\n\n"
	printf "  -d      also [--debug]; run the script in debug (verbose) mode\n"
	printf "  -t      also [--top]; show device CPU and RAM usage\n\n"
	printf "  -h      also [--help]; show this information\n\n"
	printf " - INSTRUCTIONS -\n\nskip the OBB step using one of the following:\n  'na', '0', '.'      OBB not applicable\n"
	printf "  'fire'                    Amazon build\n\n"
}

# allow user to see the copyright, license, top, or the help page without running the script
if [ "$*" = "show-c" ] || [ "$*" = "-c" ]; then echo "2020 © Nikolas A. Wagner"; exit
elif [ "$*" = "show-l" ] || [ "$*" = "-l" ]; then echo "GNU GPLv3: https://www.gnu.org/licenses/"; exit
elif [ "$*" = "--help" ] || [ "$*" = "-h" ]; then help; exit
elif [[ "$*" == *"--top"* ]] || [[ "$*" == *"-t"* ]]; then adb shell top -d 2 -m 5 -o %MEM -o %CPU -o CMDLINE -s 1; fi

# check for mode flags
if [[ "$*" == *"--update"* ]] || [[ "$*" == *"-u"* ]]; then echo "update mode"; sleep 1; UNINSTALL="false"; OBBdone="true"; fi
if [[ "$*" == *"--debug"* ]] || [[ "$*" == *"-d"* ]]; then verbose=1
else verbose=0; fi

# prepare script for running the MAIN function
INIT(){
	echo "Initializing.." &
	loopFromError="false"; upToDate="error checking version"; errorMessage=" ..no error is saved here.. "
	deviceConnect="true"; OBBdone="false"; APKdone="false"; UNINSTALL="true"

	# text-UI elements and related variables
	UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
	waitMessage="-- waiting for device --"

	if figlet -t -w 0 -F metal "TEST FULL FIG"; clear; then
		echo "Initializing.." &
		oops=$(figlet -F metal -t "Oops!")
		printTitle(){
			figlet -F border -F gay -t "$scriptTitle"
		}
	elif figlet -w 0 -f small "TEST SIMPLE FIG"; clear; then
		echo "Initializing.." &
		oops=$(figlet -f small "Oops!")
		printTitle(){
			figlet "$scriptTitle"
		}
	else
		oops="Oops!"
		printTitle(){
			printf "\n%*s\n" $((COLS/2)) "$scriptTitle"
			printf "%*s\n\n\n" $((COLS/2)) "$UIsep_title"
		}
	fi

	OBBinfo="\nSkip? Type: na, 0, or .\nAmazon? Type: fire\n\n"

	scriptStartDate=""; scriptStartDate=$(date)
	scriptDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	# make logs directory, but do not overwrite if already present
	mkdir ~/logs/ >/dev/null 2>&1

	# mac osx only; set font size to 15p
	osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" > /dev/null 2>&1
}

clear; INIT # initializing now..
# nothing up until the first call of MAIN will be run; only being loaded into memory

# set debug variant of core commands
if [ $verbose = 1 ]; then
	CMD_communicate(){ printf "\n\nChecking device connection status..\n"; adb shell exit; }
	CMD_uninstall(){ echo "Uninstalling $OBBname.."; adb uninstall "$OBBname"; sleep 0.5; }
	CMD_launch(){ printf "\n\nRunning monkey event to launch app..\n\n"; adb shell "$launchCMD"; }

	CMD_pushOBB(){ adb push "$OBBfilePath" /sdcard/Android/OBB; }
	CMD_installAPK(){ (adb install -r --no-streaming "$APKfilePath" && exit) || (
		printf "\n--no-streaming option failed\n\nAttempting default install type..\n"
		trap - SIGINT
		adb install -r "$APKfilePath"
	) }

	CMD_gitGet(){ git clone https://github.com/LysergikProductions/Android-Installer.git && {
			printf "\nGIT CLONED\n\n"; echo "Getting configs.." & sleep 2
		} || { git pull printf "\nGIT PULLED\n\n"; sleep 2; }
	}

	refreshUI(){ printTitle; }

	CMD_rmALL(){ rm -rf /tmp/variables.before /tmp/variables.after ~/upt; echo "rm -rf /tmp/variables.before /tmp/variables.after ~/upt"; }
	CMD_reset(){ printf "\n\nTerminal was NOT reset like would occur in default mode; there could be issues in the terminal.\n"; }

	lastCatch(){
		scriptEndDate=$(date)
		printf "\nFINAL: caught error in MAINd's error handling\nI make a logfile with ALL system variables called ~/logs/FULL_$scriptEndDate.txt\n\n"
		( set ) > ~/logs/"FULL_$scriptEndDate".txt 2>&1
	}
else # set default variant of core commands
	CMD_communicate(){ adb shell exit 2>/dev/null; }
	CMD_uninstall(){ echo "Uninstalling $OBBname.."; wait | adb uninstall "$OBBname" >/dev/null 2>&1; sleep 0.5; echo "Done!"; }
	CMD_launch(){ adb shell "$launchCMD" >/dev/null 2>&1; }

	CMD_pushOBB(){ adb push "$OBBfilePath" /sdcard/Android/OBB 2>/dev/null; }
	CMD_installAPK(){ (adb install -r --no-streaming "$APKfilePath" 2>/dev/null && exit) || (
		printf "\n--no-streaming option failed\n\nAttempting default install type..\n"
		trap - SIGINT
		adb install -r "$APKfilePath" 2>/dev/null && exit
	) }

	CMD_gitGet(){ git clone https://github.com/LysergikProductions/Android-Installer.git >/dev/null 2>&1 || {
			git pull >/dev/null 2>&1
		}
	}

	refreshUI(){ printHead; adb devices; printTitle; }

	CMD_rmALL(){ rm -rf /tmp/variables.before /tmp/variables.after ~/upt >/dev/null 2>&1; }
	CMD_reset(){ reset; }

	lastCatch(){
		scriptEndDate=$(date)
		( set ) > ~/logs/"FULL_$scriptEndDate".txt 2>&1
	}
fi

update(){
	trap "" SIGINT
	clear; printf "\n%*s\n\n" $((COLS/2)) "Updating Script:"

	cpSource=~/upt/Android-Installer/$scriptPrefix$currentVersion.sh
	cp "$cpSource" "$scriptDIR" && upToDate="true"

	trap - SIGINT
	#rm -f "$scriptDIR/$scriptFileName"

	echo "Launching updated version of the script!"; sleep 1
	exec "$scriptDIR/$scriptPrefix$currentVersion.sh"
}

gitConfigs(){
	terminalPath=""; terminalPath=$(pwd)
	rm -rf ~/upt; mkdir ~/upt; cd ~/upt || return

	# clone repo or update it with git pull if it exists already
	(CMD_gitGet); wait
	cd "$terminalPath" || return
	
	# get config values from the master branch's properties.txt
	currentVersionLine=$(grep -n "_version " ~/upt/$gitName/properties.txt)
	currentVersion="${currentVersionLine##* }"; currentVersion=${currentVersion%$'\r'}

	newVersionLine=$(grep -n "_newVersion " ~/upt/$gitName/properties.txt)
	newVersion="${newVersionLine##* }"; newVersion=${newVersion%$'\r'}

	gitMESSAGELine=$(grep -n "_gitMESSAGE " ~/upt/$gitName/properties.txt)
	gitMESSAGE="${gitMESSAGELine##* }"; gitMESSAGE=${gitMESSAGE%$'\r'}

	dispGitTimeLine=$(grep -n "_dispGitTime " ~/upt/$gitName/properties.txt)
	dispGitTime="${dispGitTimeLine##* }"; dispGitTime=${dispGitTime%$'\r'}

	# set scriptTitle to match config, else use default
	if scriptTitle=$(grep -n "_scriptTitle " ~/upt/Android-Installer/properties.txt); then
		scriptTitle="${scriptTitle##* }"
	else scriptTitle="$scriptTitleDEF"; fi

	if [ "$currentVersion" = "$scriptVersion" ]; then
		upToDate="true"
		printf "\n%*s" $((COLS/2)) "This script is up-to-date!"; sleep 1
	elif [ "$newVersion" = "$scriptVersion" ]; then
		upToDate="true"
		printf "\n%*s" $((COLS/2)) "This script is up-to-date!"; sleep 1
	else
		upToDate="false"
		printf "\n\n\n\n\n%*s\n" $((COLS/2)) "This script: v$scriptVersion"
		printf "\n%*s\n" $((COLS/2)) "Latest version: v$currentVersion"
		printf "%*s\n" $((COLS/2)) "Version in progress: v$newVersion"
		
		printf "\n%*s" $((COLS/2)) "Update required..."; sleep 2
		update
	fi

	# display gitMESSAGE if there is one
	if [ "$dispGitTime" = "" ]; then dispGitTime=0; fi
	if [ ! "$gitMESSAGE" = "" ]; then clear; echo "$gitMESSAGE"; sleep "$dispGitTime"; fi
}

printHead(){
	if [ $loopFromError = "false" ]; then clear;
		printf "$scriptFileName | Build $build\n2020 (C) $author\n$UIsep_err0\n\n$adbVersion\n\nBash version $bashVersion\n"
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
	elif [ $loopFromError = "true" ]; then clear;
		printf "$scriptFileName | Build $build\n2020 (C) $author\n$UIsep_err0\n\n$adbVersion\n\nBash version $bashVersion\n"
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
		printf "$errorMessage\n\n"
  	else # if bug causes loopFromError to be NOT "true" or "false", then fix value and reset script
		export errorMessage="$errorMessage\n\n$UIsep_err0\n\n"
		export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value."
		export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAINd
  	fi
}

# default MAIN function that uninstalls first in case of existing version of the app on the device
MAINd(){
	deviceID=""; deviceID2=""

	printf '\e[8;50;150t'; printf '\e[3;290;50t'
	COLS=$(tput cols)
	gitConfigs; printHead

	# try communicating with device, catch with adbWAIT, finally mount device
	(CMD_communicate && wait) || adb start-server
	adb shell settings put global development_settings_enabled 1

	printTitle
	tput cnorm; trap - SIGINT # ensure cursor is visible and that crtl-C is functional

	getOBB; getAPK; INSTALL && echo || {
		CMD_reset; printf "\nMAINd: caught fatal error in INSTALL\nSave varLog now\n"

		export scriptEndDate=""; scriptEndDate=$(date)
		export errorMessage="FE0 - Fatal Error. Copying all var data into ~/logs/$scriptEndDate.txt"
		printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"

		diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
		trap - SIGINT
	} || (echo "catch fails"; trap - SIGINT; exit 1)
}

# update MAIN function that does not delete app data, and only updates the build (beta feature)
MAINu(){
	deviceID=""; deviceID2=""; scriptTitle="  MONKEY UPDATER  "

	COLS=$(tput cols)
	printf '\e[8;50;150t'; printf '\e[3;290;50t'
	gitConfigs; printHead

	# try communicating with device, catch with adbWAIT, finally mount device
	(CMD_communicate && wait) || adb start-server
	adb shell settings put global development_settings_enabled 1

	printTitle
	tput cnorm; trap - SIGINT # ensure cursor is visible and that crtl-C is functional

	echo "OBB will not actually be replaced on your device, but it is still required.."
	getOBB; getAPK; UPSTALL && echo || {
		CMD_reset; printf "\nMAINd: caught fatal error in INSTALL\nSave varLog now\n"

		export scriptEndDate=""; scriptEndDate=$(date)
		export errorMessage="FE0 - Fatal Error. Copying all var data into ~/logs/$scriptEndDate.txt"
		printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"

		diff /tmp/variables.before /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
		trap - SIGINT
	} || (echo "catch fails"; trap - SIGINT; exit 1)
}

getOBB(){
	printf "\n%*s\n" $((COLS/2)) "Drag OBB and press enter:"; printf "$OBBinfo"
	read -p '' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName

	local cleanPath="${OBBfilePath#*:*}"; OBBname=$(basename "$cleanPath")

	if [ "$OBBfilePath" = "" ]; then
		printHead; adb devices; printTitle
		printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $((COLS/2)) "You forgot to drag the OBB!"
		getOBB
	elif [ "$OBBfilePath" = "fire" ]; then
		OBBvalid="true"; OBBdone="true"
		UNINSTALL="false"; LAUNCH="false"

		refreshUI; warnFIRE

		printf "Which Amazon app would you like to install?\n"
		select opt in "${fireAPPS[@]}"
		do
			case $opt in
			"GO BACK")
					refreshUI; getOBB
				break
					;;
			*)
				export OBBname="com.$studio.amazon.$opt"
				printf "OBB Name: $OBBname\n\n"
				export launchCMD="monkey -p $OBBname -c android.intent.category.LAUNCHER 1"
				break
					;;
			esac
	      done
	elif [ "$OBBfilePath" = "na" ] || [ "$OBBfilePath" = "0" ] || [ "$OBBfilePath" = "." ]; then
		OBBvalid="true"; OBBdone="true"; LAUNCH="false"
		printf "OBB Name: N/A"
	elif [[ "$OBBname" == "com."* ]]; then
		OBBvalid="true"; LAUNCH="true"
		printf "OBB Name: $OBBname\n\n"
		launchCMD="monkey -p $OBBname -c android.intent.category.LAUNCHER 1"
	else
		OBBvalid="false"
	fi

	until [ "$OBBvalid" = "true" ]; do
		printHead; adb devices; printTitle
		printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "\n%*s\n\n" $((COLS/2)) "That is not an OBB!"
		getOBB
	done
}

getAPK(){
	APKvalid="true"
	printf "\n%*s\n" $((COLS/2)) "Drag APK anywhere here:"
	read -p '' APKfilePath

	local cleanPath="${APKfilePath#*:*}"; APKname=$(basename "$cleanPath")

	if [ "$APKfilePath" = "" ]; then
		printHead; adb devices; printTitle
		APKvalid="false"
		printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $((COLS/2)) "You forgot to drag the APK!"
		getAPK
	elif [[ "$APKname" == *".apk" ]]; then
		APKvalid="true"
		printf "APK Name: $APKname\n\n"
	else
		APKvalid="false"
	fi

	until [ "$APKvalid" = "true" ]; do
		printHead; adb devices; printTitle
		printf "%*s\n" $((COLS/2)) "$oops"; sleep 0.05
		printf "%*s\n\n" $((COLS/2)) "That is not an APK!"
		getAPK
	done
}

INSTALL(){
	scriptTitle="Installing.."

	printHead; adbWAIT
	printf "\nMounting device...\n"
	adb devices

	# uninstall app, unless APK step wants to continue from where it left off
	if [ "$UNINSTALL" = "true" ]; then
		wait | CMD_uninstall
		UNINSTALL="true"
	fi

	echo; printTitle

	# upload OBB, only if it isn't already uploaded on deviceID
	if [ "$OBBdone" = "false" ] && [[ "$OBBname" == "com."* ]]; then
		printf "\nUploading OBB..\n"
		if (CMD_pushOBB && exit) || (
				(CMD_communicate && deviceConnect="true") || { trap - SIGINT; deviceConnect="false"; }
				if [ "$deviceConnect" = "true" ]; then
					errorMessage="FE1a - OBB could not be installed."
					printf "\n\nFE1a - OBB could not be installed.\n"

					( set -o posix ; set ) >/tmp/variables.after
					echo "Please report this error code (FE1a) to Nick."; exit 1
				else OBBdone="false"; INSTALL; fi
			); then
				OBBdone="true"
				adbWAIT; deviceConnect="true"; deviceID=$(adb devices)
		else (trap - SIGINT; exit 1); fi
	fi

	adbWAIT

	# install APK, only if APKdone=false
	if [ "$APKdone" = "false" ] && [[ "$APKname" == *".apk" ]]; then
		if [ "$OBBname" = "fire" ]; then
			printf "\n%*s\n\n" $((COLS/2)) "It may take a long time to install builds on this device.."
		fi

		printf "\nInstalling APK..\n"

		if CMD_installAPK || (
			(CMD_communicate && deviceConnect="true") || { trap - SIGINT; deviceConnect="false"; }
			if [ "$deviceConnect" = "true" ]; then
				errorMessage="FE1b - APK could not be installed."
				printf "\n\nFE1b - APK could not be installed.\n"

				( set -o posix ; set ) >/tmp/variables.after
				echo "Please report this error code (FE1b) to Nick."; exit 1
			else APKdone="false"; UNINSTALL="false"; INSTALL; fi
		); then
			APKdone="true"
			adbWAIT; deviceConnect="true"; deviceID=$(adb devices)

			if [ "$LAUNCH" = "true" ]; then
				CMD_launch &
				printf "\n\nLaunching app."; sleep 0.4; printf " ."; sleep 0.4; printf " ."; sleep 0.4; printf " .\n"
				wait; tput cnorm; installAgainPrompt
			else
				tput cnorm; installAgainPrompt
			fi
		else (trap - SIGINT; exit 1); fi
	fi
}

UPSTALL(){
	scriptTitle=" INSTALLING.. "

	printHead; adbWAIT; UNINSTALL="false"
	printf "\nMounting device...\n"
	adb devices

	# uninstall app, unless APK step wants to continue from where it left off
	if [ "$UNINSTALL" = "true" ]; then
		wait | CMD_uninstall
		UNINSTALL="true"
	fi

	deviceID=$(adb devices); echo; printTitle

	# install APK, only if APKdone=false
	if [ "$APKdone" = "false" ] && [[ "$APKname" == *".apk" ]]; then
		printf "\nInstalling APK..\n"

		if CMD_installAPK || (
			(CMD_communicate && deviceConnect="true") || { trap - SIGINT; deviceConnect="false"; }
			if [ "$deviceConnect" = "true" ]; then
				errorMessage="FE1b - APK could not be installed."
				printf "\n\nFE1b - APK could not be installed.\n"

				( set -o posix ; set ) >/tmp/variables.after
				echo "Please report this error code (FE1b) to Nick."; exit 1
			else APKdone="false"; UNINSTALL="false"; INSTALL; fi
		); then
			printf "\ncheck for proper connect, and define deviceID(1)\nLaunch App\n"
			APKdone="true"
			adbWAIT; deviceConnect="true"; deviceID=$(adb devices)

			if [ "$LAUNCH" = "true" ]; then
				CMD_launch
				printf "\n\nLaunching app."; sleep 0.4; printf " ."; sleep 0.4; printf " ."; sleep 0.4; printf " .\n"
				tput cnorm; installAgainPrompt
			else
				tput cnorm; installAgainPrompt
			fi
		else (trap - SIGINT; exit 1); fi
	fi
}

# check if user wants to install again on another device, or the same device if they choose to
installAgainPrompt(){
	scriptTitle="Install Again?"; refreshUI
	printf "\n%*s\n" $((COLS/2)) "Press 'q' to quit, or press any other key to install this build on another device.."
	read -n 1 -s -r -p ''
	if [ ! "$REPLY" = "q" ]; then
		OBBdone="false"; APKdone="false"
		installAgain
	fi
	(exit)
}

installAgain(){
	trap - SIGINT
	adbWAIT
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

warnFIRE(){
	flashWarn=(
		"!Remember!" "" "!Remember!" "" "!Remember!"
	)
	tput civis
	for i in "${flashWarn[@]}"
	do
		printf "\r%*s" $((COLS/2)) "$i"
		sleep 0.3
	done
	printf "\r%*s\n\n" $((COLS/2)) "To test the store, use the download link method"
	tput cnorm
}

# update the script on status of adb connection and call waiting function until it is ready
adbWAIT(){
	if (CMD_communicate); then
		export deviceConnect="true"
	else
		tput civis
		printf "\n\n%*s\n" $((COLS/2)) "$waitMessage"
		{ sleep 4; printf "        Ensure only one device is connected!"; } & { 
			until (CMD_communicate)
			do waiting; deviceConnect="true"; done
		}
		tput cnorm
		printf "\r%*s\n\n" $((COLS/2)) "!Device Connected!   "
	fi
}

# show the waiting animation
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

# the following lines lead to calling every above function starting after INIT for the first time

if [[ "$*" == "--update" ]] || [[ "$*" == *"-u"* ]]; then
	# try update, catch
	MAINu && echo || lastCatch
else
	# try install, catch
	MAINd && echo || lastCatch
fi

# finally remove temporary data created by the script and exit
CMD_rmALL
printf "\nGoodbye!\n"; exit
