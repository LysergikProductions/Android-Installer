#!/bin/bash
# AndroidInstall_1.2.4-beta.sh
# 2020 (C) Nikolas A. Wagner
# License: GNU GPLv3

# Build_0328

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


#                                          -- Purpose --
# Simplify the process of installing and make it as convenient as possible to install builds on Android devices, via Android Debug Bridge
#                                          --  -  ---  -  --

# kill script if script would have root privileges
if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

# remove any pre-existing tmp files
rm -f $secureFile3 /tmp/variables.after /tmp/usrIPdata.xml /tmp/devIPdata.xml

# log all system variables at script execution, then check those files still exist
secureFile3=$(mktemp /tmp/$$.$RANDOM)
if ! ( set -o posix ; set ) > $secureFile3; then kill $( jobs -p ) 2>/dev/null || exit 1; fi
if ! file $secureFile3 1>/dev/null; then kill $( jobs -p ) 2>/dev/null || exit 1; fi

# some global variables
scriptStartDate=""; scriptStartDate=$(date)

build="0328"; scriptVersion=1.2.0-release; author="Nikolas A. Wagner"; license="GNU GPLv3"
scriptTitleDEF="StoicDroid"; scriptPrefix="AndroidInstall_"; scriptFileName=$(basename "$0")
adbVersion=$(adb version); bashVersion=${BASH_VERSION}; currentVersion="_version errorGettingProperties.txt"

#!# studio specific variables #!#
fireAPPS=( "GO BACK" "option1" "option2" "option3" "option4" "option5" "option6" "option7" )
studio=""; gitName="Android-Installer"

# make sure SIGINT always works even in presence of infinite loops
exitScript() {
	trap - SIGINT SIGTERM SIGTERM # clear the trap

	CMD_rmALL # remove temporary files
	IFS=$ORIGINAL_IFS # set original IFS

	#printf '\e[8;$usr_tHeight;{$usr_tWidth}t'; printf '\e[3;370;60t'

	kill -- -$$ # Send SIGTERM to child/sub processes
	kill $( jobs -p ) # kill any remaining processes

	# this is alpha and not in use atm
	if [ "$topRun" = "true" ]; then
		if [[ "$*" == "--update" ]] || [[ "$*" == *"-u"* ]]; then
			# try update, catch
			# MAINu && echo || lastCatch
			echo "topRun was $topRun (true)"
		else
			# try install, catch
			# MAINd && echo || lastCatch
			echo "topRun was $topRun (true)"
		fi
	fi
}; trap exitScript SIGINT SIGTERM # set trap

help(){
	printf '\e[8;40;130t'; printf '\e[3;303;60t'
	osascript -e "tell application \"Terminal\" to set the font size of window 1 to 16" > /dev/null 2>&1
	printf "%*s\n\n" $((0)) ""

	printf "  Help Page\n\n"
	printf " - OPTIONS -\n\n"
	printf "  -c      also [show-c]; show the copyright & license information\n"
	printf "  -l      also [show-l]; show the copyright & license information\n"
	printf "  -u      also [--update]; run the script in update mode (not working yet)\n"
	printf "  -q      also [--quiet]; run the script in quiet mode\n"
	printf "  -s      also [--safe]; disable network (and other) feature to improve performance\n"
	printf "  -d      also [--debug]; run the script in debug mode. Add a -v to increase verbosity!\n\n"
	printf "  -t      also [--top]; show device CPU and RAM usage\n"
	printf "  -h      also [--help]; show this information\n\n"
	printf " - INSTRUCTIONS -\n\n"
	printf "Skip the OBB step using:\n\n  na, 0, .      OBB not applicable\n"
	printf "  fire          Amazon build\n\n"
	printf "Other features:\n\n"
	printf "  tool    enter this during either OBB or APK step to access toolkit menu\n"
	printf "  q       enter this during either OBB or APK step to exit the script\n\n\n\n\n\n\n\n\n\n\n"
}

updateIP(){
	update_IPdata 2>/dev/null
	parse_IPdata
	deviceIP="$devIP"
	deviceLOC="$devCity, $devRegion, $devCountry"
	
	if [ "$usrIP" = "" ]; then
		if ! curl -V >/dev/null 2>&1; then usrIP="curl unavailable"; else usrIP="IP unavailable"; fi
	fi

	if [ "$devIP" = "" ]; then
		if ! adb -d shell curl -V >/dev/null 2>&1; then deviceLOC="curl unavailable"; else deviceLOC="IP unavailable"; fi
	fi
}

update_IPdata(){
	if [ "$verbose" = 1 ]; then printf "\n\nUpdating IP DATA\n\n"; fi

	# remove pre-existing files
	rm -f >/tmp/usrIPdata.xml >/tmp/devIPdata.xml

	usrIP=$(curl https://ipinfo.io/ip)
	devIP=$(adb -d shell curl https://ipinfo.io/ip)

	usrIP_XML=$(curl https://freegeoip.app/xml/$usrIP >/tmp/usrIPdata.xml)
	devIP_XML=$(adb -d shell curl https://freegeoip.app/xml/$devIP >/tmp/devIPdata.xml)
}

parse_IPdata(){
	if [ "$verbose" = 1 ]; then printf "\n\nParsing IP DATA\n\n"; fi

	# give 'parse_' functions a way to lookup the data from file using parameter expansion
	readXML(){
		IFS=\>
		read -d \< ENTITY CONTENT
		ret=$?
		TAG_NAME="${ENTITY%% *}"
		ATTRIBUTES="${ENTITY#* }"
		return $ret
	}

	# extract specific data into convenient little variables
	bounce_usrIPdata(){
		if [[ "$TAG_NAME" = "IP" ]] ; then usrIP=$CONTENT; fi
		if [[ "$TAG_NAME" = "CountryName" ]] ; then usrCountry=$CONTENT; fi
		if [[ "$TAG_NAME" = "RegionName" ]] ; then usrRegion=$CONTENT; fi
		if [[ "$TAG_NAME" = "City" ]] ; then usrCity=$CONTENT; fi
	}

	bounce_devIPdata(){
		if [[ "$TAG_NAME" = "IP" ]] ; then devIP=$CONTENT; fi
		if [[ "$TAG_NAME" = "CountryName" ]] ; then devCountry=$CONTENT; fi
		if [[ "$TAG_NAME" = "RegionName" ]] ; then devRegion=$CONTENT; fi
		if [[ "$TAG_NAME" = "City" ]] ; then devCity=$CONTENT; fi
	}

	while readXML; do
		bounce_usrIPdata
	done < /tmp/usrIPdata.xml

	while readXML; do
		bounce_devIPdata
	done < /tmp/devIPdata.xml

	IFS=$ORIGINAL_IFS
}

getBitWidth(){
	if [ "$verbose" = 1 ]; then printf "\n\nGetting bitwidth..\n\n"; fi

	bitWidth_raw=$(adb -d shell getprop ro.product.cpu.abi 2>/dev/null)
	if [[ "$bitWidth_raw" == *"arm64"* ]]; then
		bitWidth="64-bit"
	elif [[ "$bitWidth_raw" == *"armeabi"* ]]; then
		bitWidth="32-bit"
	else
		bitWidth="unknown"
	fi
}

# allow user to see the copyright, license, or the help page without running the script
COLS=$(tput cols)
if [[ "$*" == *"show-c"* ]] || [[ "$*" == *"-c"* ]] || [[ "$*" == *"show-l"* ]] || [[ "$*" == *"-l"* ]]; then
	if [[ "$*" == *"--help"* ]] || [[ "$*" == *"-h"* ]]; then echo; help; fi
	printf "\n2020 (C) Nikolas A. Wagner\nGNU GPLv3: https://www.gnu.org/licenses/\n\n"
	if [[ "$*" = *"--top"* ]] || [[ "$*" = *"-t"* ]]; then
		clear
		if adb -d shell exit; then
			updateIP
			{
				sleep 0.5
				while (trap exitScript SIGINT SIGTERM); do
					printf "\n%*s\n" $((COLS/2)) "Device Location: $deviceLOC"
					sleep 1.99
				done
			} & adb -d shell top -d 2 -m 5 -o %MEM -o %CPU -o CMDLINE -s 1 || exit
		else exit 1; fi		
	fi
	exit
fi

# if user didn't choose -c or -l at all, then check..
if [[ "$*" == *"--help"* ]] || [[ "$*" == *"-h"* ]]; then echo; help; exit
elif [[ "$*" == *"--top"* ]] || [[ "$*" == *"-t"* ]]; then
	clear
	if adb -d shell exit; then
		updateIP
		{
			sleep 0.5
			while (trap exitScript SIGINT SIGTERM); do
				printf "\n%*s\n" $((COLS/2)) "Device Location: $deviceLOC"
				sleep 1.99
			done
		} & adb -d shell top -d 2 -m 5 -o %MEM -o %CPU -o CMDLINE -s 1 || exit
	else exit 1; fi
fi

# if user did not choose any above options, then check for script mode flags
if [[ "$*" == *"--safe"* ]] || [[ "$*" == *"-s"* ]]; then sMode="true"; else sMode="false"; fi
if [[ "$*" == *"--update"* ]] || [[ "$*" == *"-u"* ]]; then updateAPK="true"; else updateAPK="false"; OBBdone="true"; fi
if [[ "$*" == *"--debug"* ]] || [[ "$*" == *"-d"* ]]; then
	verbose=1; qMode="false"
	if [[ "$*" == *"-v"* ]] || [[ "$*" == *"--verbose"* ]]; then verbose=2; fi
elif [[ "$*" == *"--quiet"* ]] || [[ "$*" == *"-q"* ]]; then verbose=0; qMode="true"
else verbose=0; qMode="false"; fi

# prepare script for running the MAIN function
INIT(){
	echo "Initializing.." & osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" > /dev/null 2>&1
	
	# some default/starting variables values
	loopFromError="false"; upToDate="error checking version"; errorMessage=" ..no error is saved here.. "
	deviceConnect="true"; OBBdone="false"; APKdone="false"; UNINSTALL="true"; errExec="false"; noInstall="true"
	usr_tWidth=$(tput cols); usr_tHeight=$(tput lines)

	if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
		echo "$usr_tWidth"; echo "$usr_tHeight"
	fi

	# text-UI elements and related variables
	UIsep_title="------------------"; UIsep_head="-----------------------------------------"; UIsep_err0="--------------------------------"
	waitMessage="-- waiting for device --"; toolHint="Enter 'tool' to access the toolkit"
	OBBquest="OBB"; APKquest="APK"; showIP="true"; OBBinfo=""; topRun="false"; OBBrepeat="false"

	anim1=( # doge so like
	"                        " "W                       " "Wo                      " "Wow                     " "Wow!                    " "Wow!                    " "Wow!                    "
	"Wow!                    " "Wow!                    " "Wow!                    " "Wow!                    " "Wow! V                  " "Wow! Ve                 "
	"Wow! Ver                " "Wow! Very               " "Wow! Very               " "Wow! Very l             " "Wow! Very lo            " "Wow! Very loa           "
	"Wow! Very load          " "Wow! Very loadi         " "Wow! Very loadin        " "Wow! Very loading       " "Wow! Very loading.      " "Wow! Very loading..     "
	"Wow! Very loading...    " "Wow! Very loading....   " "Wow! Very loading.....  " "Wow! Very loading...... " "Wow! Very loading......." "Wow! Very loading......." "Wow! Very loading......."
	"Wow! Very loading...... " "Wow! Very loading.....  " "Wow! Very loading....   " "Wow! Very loading...    " "Wow! Very loading..     " "Wow! Very loading.      "
	"Wow! Very loading       " "Wow! Very loading.      " "Wow! Very loading..     " "Wow! Very loading...    " "Wow! Very loading....   " "Wow! Very loading.....  "
	"Wow! Very loading...... " "Wow! Very loading......." "Wow! Very loading......." "Wow! Very loading......." "Wow! Very loading......." "Wow! Very loading......." "Wow! Very loading......."
	)
	anim2=( # simple / professional
	"oooooooooooooooooooooooo"
	"ooooooooooo00ooooooooooo" "oooooooooo0oo0oooooooooo" "ooooooooo0oooo0ooooooooo" "oooooooo0oooooo0oooooooo" "ooooooo0oooooooo0ooooooo" "oooooo0oooooooooo0oooooo"
	"ooooo0oooooooooooo0ooooo" "oooo0oooooooooooooo0oooo" "ooo0oooooooooooooooo0ooo" "oo0oooooooooooooooooo0oo" "o0oooooooooooooooooooo0o" "0oooooooooooooooooooooo0"
	"oooooooooooooooooooooooo" "0oooooooooooooooooooooo0" "o0oooooooooooooooooooo0o" "oo0oooooooooooooooooo0oo" "ooo0oooooooooooooooo0ooo" "ooo0oooooooooooooooo0ooo"
	"oooo0oooooooooooooo0oooo" "ooooo0oooooooooooo0ooooo" "oooooo0oooooooooo0oooooo" "ooooooo0oooooooo0ooooooo" "oooooooo0oooooo0oooooooo" "ooooooooo0oooo0ooooooooo"
	"oooooooooo0oo0oooooooooo" "ooooooooooo00ooooooooooo" "oooooooooooooooooooooooo"
	)
	anim3=( # matrix
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"100011011101001110011001" "011010110001101101110110" "101010010101110100100010" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"101011011101001110011001" "011010110001101101110110" "101010010101100000100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111010" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110100100011" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	"110010110110101100010100" "010010110111001001011110" "100110100011000010111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"110010110110101100010100" "010010110111001001011110" "100110100011000110111011" "100110010010001100110110" "100110010111001101101101" "101101101101011101010101"
	"101011011101001110011001" "010111010101110110101001" "101010010101110000100010" "100111010000110101101011" "101100001111010111101001" "010101010100010101010100"
	)

	# show a bunch of info to the user if quiet mode is off, with even more verbosity when debug mode is on
	if [ "$qMode" = "false" ]; then
		OBBquest1="Drag in the folder that contains the OBB file.."; OBBquest2="then press enter:"
		OBBinfo="  Skip? Type: na, 0, or .\n  Amazon? Type: fire\n"

		APKquest="Drag APK anywhere here:"

		
		if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then printf "\nTesting for figlet compatibility..\n"; sleep 1; fi
		if figlet -t -w 0 -F metal "TEST FULL FIG"; then
			if [ "$verbose" = 0 ]; then clear; fi
			echo "Initializing.." &

			oops=$(figlet -c -F metal -t "Oops!") || oops=$(figlet -F metal -t "Oops!")
			OBBtitle=$(figlet -c -F metal -t "OBB") || oops=$(figlet -F metal -t "OBB")
			if [ "$verbose" = 0 ]; then clear; fi

			printTitle(){
				figlet -c -F border -F gay -t "$scriptTitle" || figlet -F border -F gay -t "$scriptTitle"
			}
		elif figlet -w 0 -f small "TEST SIMPLE FIG"; then
			if [ "$verbose" = 0 ]; then clear; fi
			echo "Initializing.." &

			oops=$(figlet -c -f small -t "Oops!") || oops=$(figlet -f small -t "Oops!")
			OBBtitle=$(figlet -c -f small -w $COLS "OBB") || oops=$(figlet -f small -w $COLS "OBB")
			if [ "$verbose" = 0 ]; then clear; fi

			printTitle(){
				figlet -c -w $COLS "$scriptTitle" || figlet -w $COLS "$scriptTitle"
			}
		else
			oops="Oops!"; OBBtitle="OBB"

			printTitle(){
				printf "\n%*s\n" $((COLS/2)) "$scriptTitle"
				printf "%*s\n\n\n" $((COLS/2)) "$UIsep_title"
			}
		fi
		echo "Initializing.." &
	fi

	# get some more initial data for the script to use later	
	scriptDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	pkgs="$(adb shell pm list packages | grep 'budgestudios')"

	# make logs directory, but do not overwrite if already present
	mkdir ~/logs/ >/dev/null 2>&1

	# mac osx only; set font size to 15p
	osascript -e "tell application \"Terminal\" to set the font size of window 1 to 15" > /dev/null 2>&1
}

clear; INIT # initializing right away..

#!# set debug variant of core commands #!#
if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
	if [ "$verbose" = "2" ]; then set -x; fi
	CMD_communicate(){ printf "\n\nChecking device connection status..\n"; adb -d shell exit; }
	CMD_uninstall(){ 
		if [ "$updateAPK" = "true" ]; then
			echo "Keeping user data for $OBBname.."; adb shell cmd "$OBBname" uninstall -k; sleep 0.5
		else
			echo "Uninstalling $OBBname.."; adb shell cmd "$OBBname" uninstall -k; sleep 0.5
		fi
	}

	CMD_launch(){ printf "\n\nRunning monkey event to launch app..\n\n"; adb -d shell "$launchCMD"; }
	CMD_pushOBB(){ adb push "$OBBfilePath" /sdcard/Android/OBB; }

	CMD_installAPK(){
		if [ "$updateAPK" = "true" ]; then
			(adb install --streaming "$APKfilePath" && exit) || {
				printf "\n--streaming option failed\n\nAttempting default install type..\n"
				(adb install "$APKfilePath" && exit || {
						export scriptEndDate=""; scriptEndDate=$(date)
						diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
						printf "\n%*s\n" $((0)) "Something is wrong here! Saving varlog as $scriptEndDate.txt"

						printf "\nER0 - Install failed; resetting script in..\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						MAINu
					}
				)
			}
		else
			(adb install -r --no-streaming "$APKfilePath" && exit) || {
				printf "\n--no-streaming option failed\n\nAttempting default install type..\n"
				( adb install -r "$APKfilePath" && exit || { 
						export scriptEndDate=""; scriptEndDate=$(date)
						diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
						printf "\n%*s\n" $((0)) "Something is wrong here! Saving varlog as $scriptEndDate.txt"

						printf "\nER0 - Install failed; resetting script in..\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						MAINd
					}
				)
			}
		fi
	}

	CMD_gitGet(){ git clone https://github.com/LysergikProductions/Android-Installer.git && {
			printf "\nGIT CLONED\n\n"; echo "Storing config values into variables.."
		} || { git pull printf "\nGIT PULLED\n\n"; }
	}

	printIP(){
		getBitWidth
		printf "Device IP: $deviceIP\nDevice IP Location: $deviceLOC\n"
		printf "\nComputer IP: $usrIP\n\n$Device Bit Width: bitWidth\n\n"
	}

	refreshUI(){ COLS=$(tput cols); printIP; adb devices; printTitle; }

	headerIP(){
		printf "$scriptFileName | Build $build\n2020 (C) $author\n$UIsep_err0\n\n$adbVersion\n\nBash version $bashVersion\n\n"
		printIP
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head"
		if [ "$sMode" = "true" ]; then scriptTitle="\_SafeDroid_/"; fi
	}

	header(){
		printf "$scriptFileName | Build $build\n2020 (C) $author\n$UIsep_err0\n\n$adbVersion\n\nBash version $bashVersion\n"
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head"
		if [ "$sMode" = "true" ]; then scriptTitle="\_SafeDroid_/"; fi
	}

	CMD_rmALL(){
		printf "\n\nrm -rf /tmp/variables.before /tmp/variables.after ~/upt ; tput cnorm\n"
		rm -rf /tmp/variables.before /tmp/variables.after ~/upt /tmp/usrIPdata.xml /tmp/devIPdata.xml $secureFile $secureFile2
		tput cnorm
	}

	lastCatch(){
		scriptEndDate=$(date)
		printf "\nFINAL: caught error in MAINd's error handling\nI make a logfile with ALL system variables called ~/logs/FULL_$scriptEndDate.txt\n\n"
		( set ) > ~/logs/"FULL_$scriptEndDate".txt 2>&1
	}
else #!# set default variant of core commands #!#
	CMD_communicate(){ adb -d shell exit 2>/dev/null; }
	CMD_uninstall(){ 
		if [ "$updateAPK" = "true" ]; then
			if [ "$qMode" = "false" ]; then
				echo "Keeping user data for $OBBname.."
				adb shell cmd "$OBBname" uninstall -k; sleep 0.5
			else
				adb shell cmd "$OBBname" uninstall -k; sleep 0.5
			fi
		else
			if [ "$qMode" = "false" ]; then
				echo "Uninstalling $OBBname.."
				adb uninstall "$OBBname"; sleep 0.5
			else
				adb uninstall "$OBBname"; sleep 0.5
			fi
		fi
	}

	CMD_launch(){ adb -d shell "$launchCMD" >/dev/null 2>&1; }
	CMD_pushOBB(){ adb push "$OBBfilePath" /sdcard/Android/OBB 2>/dev/null; }

	CMD_installAPK(){
		if [ "$updateAPK" = "true" ]; then
			(adb install --streaming "$APKfilePath" 2>/dev/null && exit) || {
				printf "\n--streaming option failed\n\nAttempting default install type..\n"
				(adb install "$APKfilePath" 2>/dev/null && exit || {
						export scriptEndDate=""; scriptEndDate=$(date)
						diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
						printf "\n%*s\n" $((0)) "Something is wrong here! Saving varlog as $scriptEndDate.txt"

						printf "\nER0 - Install failed; resetting script in..\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						MAINu
					}
				)
			}
		else
			(adb install -r --no-streaming "$APKfilePath" 2>/dev/null && exit) || {
				printf "\n--no-streaming option failed\n\nAttempting default install type..\n"
				( adb install -r "$APKfilePath" 2>/dev/null && exit || { 
						export scriptEndDate=""; scriptEndDate=$(date)
						diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
						printf "\n%*s\n" $((0)) "Something is wrong here! Saving varlog as $scriptEndDate.txt"
						
						printf "\nER0 - Install failed; resetting script in..\n"
						printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						MAINd
					}
				)
			}
		fi
	}

	CMD_gitGet(){ git clone https://github.com/LysergikProductions/Android-Installer.git >/dev/null 2>&1 || {
			git pull >/dev/null 2>&1
		}
	}
	printIP(){
		getBitWidth
		printf "Device Bit Width: $bitWidth\nDevice IP Location: $deviceLOC"
	}

	if [ "$qMode" = "false" ]; then
		refreshUI(){ COLS=$(tput cols); printHead; adb devices; printTitle; }
	else
		refreshUI(){ COLS=$(tput cols); printHead; }
	fi

	headerIP(){
		printf "$scriptFileName | Build $build\n2020 (C) $author"
		if [ "$sMode" = "false" ] && [ "$qMode" = "false" ]; then printf "\n$UIsep_err0\n"; printIP; fi
		printf "\n$UIsep_head\n\nDistributed with the $license license\n\n$UIsep_head\n\n"
		if [ "$sMode" = "true" ]; then scriptTitle="\_SafeDroid_/"; fi
	}

	header(){
		printf "$scriptFileName | Build $build\n2020 (C) $author"
		printf "\n$UIsep_err0\n\nDistributed with the $license license\n\n$UIsep_head\n"
		if [ "$sMode" = "true" ]; then scriptTitle="\_SafeDroid_/"; fi
	}

	CMD_rmALL(){
		rm -rf /tmp/variables.before /tmp/variables.after ~/upt /tmp/usrIPdata.xml /tmp/devIPdata.xml $secureFile $secureFile2
		tput cnorm
	}

	lastCatch(){
		scriptEndDate=$(date)
		( set ) > ~/logs/"FULL_$scriptEndDate".txt 2>&1
	}
fi

updateScript(){
	clear; printf "\n%*s\n\n" $((COLS/2)) "Updating Script:"

	if [ "$verbose" = 1 ]; then printf "\nCopying new version of script into current script directory\n"; sleep 0.6; fi
	cpSource=~/upt/Android-Installer/$scriptPrefix$currentVersion.sh

	trap "" SIGINT
	cp "$cpSource" "$scriptDIR" && upToDate="true"
	trap exitScript SIGINT SIGTERM

	echo "Launching updated version of the script!"; sleep 1
	exec "$scriptDIR/$scriptPrefix$currentVersion.sh" || { errExec="true" && gitConfigs; }
}

gitConfigs(){
	rm -rf $secureFile2
	secureFile2=$(mktemp /tmp/$$.$RANDOM.txt)

	if [ "$verbose" = 1 ]; then printf "\nDownloading configs..\n\n"; fi
	terminalPath=""; terminalPath=$(pwd)
	rm -rf ~/upt; mkdir ~/upt; cd ~/upt || return

	# clone repo or update it with git pull if it exists already
	(CMD_gitGet); wait
	cd "$terminalPath" || return

	rm -rf $secureFile
	secureFile=$(mktemp /tmp/$$.$RANDOM.txt)
	
	cat ~/upt/$gitName/properties.txt > $secureFile
	cat ~/upt/$gitName/properties.txt > $secureFile2
	if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
		echo; cat "$secureFile"; echo
	fi

	# check secureFiles still exists
	file $secureFile >/dev/null 2>&1 || exit 1
	file $secureFile2 >/dev/null 2>&1 || exit 1

	# get config values from the master branch's properties.txt
	currentVersionLine=$(grep -n "_version " $secureFile)
	currentVersion="${currentVersionLine##* }"; currentVersion=${currentVersion%$'\r'}

	newVersionLine=$(grep -n "_newVersion " $secureFile)
	newVersion="${newVersionLine##* }"; newVersion=${newVersion%$'\r'}

	gitMESSAGELine=$(grep -n "_gitMESSAGE " $secureFile)
	gitMESSAGE="${gitMESSAGELine##* }"; gitMESSAGE=${gitMESSAGE%$'\r'}

	dispGitTimeLine=$(grep -n "_dispGitTime " $secureFile)
	dispGitTime="${dispGitTimeLine##* }"; dispGitTime=${dispGitTime%$'\r'}

	# set scriptTitle to match config, else use default
	if scriptTitle=$(grep -n "_scriptTitle " $secureFile); then
		scriptTitle="${scriptTitle##* }"
	else scriptTitle="$scriptTitleDEF"; fi

	# try to catch race attacks
	if [ ! "$(cat $secureFile)" = "$(cat $secureFile2)" ]; then	
		if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
			echo; cat "$secureFile2"; echo
		fi
		exitScript; exit 1
	fi

	# check if script is up-to-date or not; update the script if not
	if [ "$currentVersion" = "$scriptVersion" ]; then
		upToDate="true"
		printf "\n%*s\n" $((COLS/2)) "This script is up-to-date!"; sleep 0.2
	elif [ "$newVersion" = "$scriptVersion" ]; then
		upToDate="true"
		printf "\n%*s\n" $((COLS/2)) "This script is up-to-date!"; sleep 0.2
	else
		if [ "$errExec" = "false" ]; then
			upToDate="false"
			printf "\n\n\n\n\n%*s\n" $((COLS/2)) "This script: v$scriptVersion"
			printf "\n%*s\n" $((COLS/2)) "Latest version: v$currentVersion"
			printf "%*s\n" $((COLS/2)) "Version in progress: v$newVersion"

			printf "\n%*s" $((COLS/2)) "Update required..."; sleep 2
			if [ "sMode" = "false" ]; then updateScript; fi
		elif [ "$errExec" = "true" ]; then
			echo "error when launching new script.. ignoring"; sleep 1
		fi
	fi

	# display gitMESSAGE if there is one
	if [ "$dispGitTime" = "" ]; then dispGitTime=0; fi
	if [ ! "$gitMESSAGE" = "" ]; then
		if [ "$verbose" = 0 ]; then clear; fi
		echo "$gitMESSAGE" & sleep "$dispGitTime"
	fi
}

printHead(){
	trap exitScript SIGINT SIGTERM # reset trap
	if [ "$loopFromError" = "false" ]; then
		tput civis
		if [ "$verbose" = 0 ]; then clear; fi
		if [ "$showIP" = "true" ] && [ "$qMode" = "false" ]; then headerIP; else header; fi
		tput cnorm
	elif [ "$loopFromError" = "true" ]; then
		tput civis
		if [ "$verbose" = 0 ]; then clear; fi
		if [ "$showIP" = "true" ] && [ "$qMode" = "false" ]; then headerIP; else header; fi
		printf "$errorMessage\n\n"
		tput cnorm
  	else # if bug causes loopFromError to be NOT "true" or "false", then fix value and reset script
		export errorMessage="$errorMessage\n\n$UIsep_err0\n\n"
		export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value."
		export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAINd
  	fi
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

# default MAIN function that uninstalls first in case of existing version of the app on the device
MAINd(){
	deviceID=""; deviceID2=""; OBBrepeat="false"

	printf '\e[8;40;130t'; printf '\e[3;370;60t'
	if [ "$verbose" = 1 ]; then printf "\nqMode is $qMode, sMode is $sMode\n\n"; fi	

	if [ "$sMode" = "false" ]; then gitConfigs; fi
	COLS=$(tput cols); updateIP

	# try communicating with device, catch with adbWAIT, finally mount device
	(CMD_communicate 1>/dev/null) || adb start-server
	adb -d shell settings put global development_settings_enabled 1

	refreshUI
	tput cnorm # ensure cursor is visible and that crtl-C is functional

	getOBB; getAPK; INSTALL && echo || {
		printf "\nMAINd: caught fatal error in INSTALL\nSave varLog now\n"

		export scriptEndDate=""; scriptEndDate=$(date)
		export errorMessage="FE0 - Fatal Error. Copying all var data into ~/logs/$scriptEndDate.txt"
		printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"

		diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
	} || (echo "catch fails"; exit 1)
}

# update MAIN function that does not delete app data, and only updates the build (beta feature)
MAINu(){
	deviceID=""; deviceID2=""; OBBrepeat="false"
	scriptTitle="\_SpaceDroid_/"

	printf '\e[8;50;150t'; printf '\e[3;290;50t'
	if [ "$verbose" = 1 ]; then printf "\nqMode is $qMode, sMode is $sMode\n\n"; fi	

	if [ "$sMode" = "false" ]; then gitConfigs; fi
	COLS=$(tput cols); updateIP

	# try communicating with device, catch with adbWAIT, finally mount device
	(CMD_communicate 1>/dev/null) || adb start-server
	adb -d shell settings put global development_settings_enabled 1

	refreshUI
	tput cnorm # ensure cursor is visible and that crtl-C is functional

	echo "User data will not be deleted.."
	getOBB; getAPK; UPSTALL && echo || {
		printf "\nMAINd: caught fatal error in INSTALL\nSave varLog now\n"

		export scriptEndDate=""; scriptEndDate=$(date)
		export errorMessage="FE0 - Fatal Error. Copying all var data into ~/logs/$scriptEndDate.txt"
		printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"

		diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
	} || (echo "catch fails"; exit 1)
}

getOBB(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi
	COLS=$(tput cols)

	if [ "$qMode" = "false" ]; then
		if [ "$OBBrepeat" = "false" ]; then
			printf "\n\t\t%*s\n" $(((COLS/2)+1)) "$toolHint"
		fi

		printf "$OBBinfo"; printf "$OBBtitle"; echo
		printf "%*s\n" $(((COLS/2)+24)) "$OBBquest1"
		printf "\t%*s\n\n" $((COLS/2)) "$OBBquest2"
	else
		printf "\n%*s\n" $(((COLS/2)+1)) "OBB"
	fi
	
	read -p '' OBBfilePath #i.e. Server:\folder\ folder/folder/com.studio.platform.appName
	OBBfilePath="${OBBfilePath%* }"; local cleanPath="${OBBfilePath#*:*}"
	OBBname=$(basename "$cleanPath")

	if [ "$OBBfilePath" = "" ]; then
		refreshUI; OBBrepeat="true"
		printf "%*s\n" $((COLS/2)) "$oops"
		printf "%*s\n\n" $((COLS/2)) "You need to drag-in the OBB!"
		getOBB
	elif [ "${OBBfilePath,,}" = "q" ] || [ "${OBBfilePath,,}" = "quit" ] || [ "${OBBfilePath,,}" = "wq" ] || [ "${OBBfilePath,,}" = "qw" ] || [ "${OBBfilePath,,}" = "w" ]; then
		exitScript
	elif [ "${OBBfilePath,,}" = "tool" ] || [ "${OBBfilePath,,}" = "tools" ]; then
		toolMenu
	elif [ "${OBBfilePath,,}" = "fire" ]; then
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
				UNINSTALL="true"; LAUNCH="true"; OBBname="com.$studio.amazon.$opt"
				launchCMD="monkey -p $OBBname -c android.intent.category.LAUNCHER 1"

				printf "OBB Name: $OBBname\n\n"
				break
					;;
			esac
	      done
	elif [ "$OBBfilePath" = "na" ] || [ "$OBBfilePath" = "0" ] || [ "$OBBfilePath" = "." ]; then
		OBBvalid="true"; OBBdone="true"; LAUNCH="false"; UNINSTALL="false"
		printf "OBB Name: N/A"
	elif [[ "$OBBname" == "com."* ]]; then
		OBBvalid="true"; LAUNCH="true"
		printf "OBB Name: $OBBname\n\n"

		if [ "$pkgs" == *"$OBBname"* ]; then
			refreshUI
			printf "\n%*s\n" $((COLS/2)) "This app already exists on this device!"
			printf "\n%*s\n" $((0)) "Are you sure you want to continue? y/n?"

			read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
			while [[ "$REPLY" == *"/"* ]] || [ "$REPLY" = "" ]; do
				if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
					printf "\n%*s\n" $((0)) "Input ignored: the user dragged in a file or directory"
				fi

				read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
			done

			if [ "$REPLY" = "y" ]; then return
			elif [ "$REPLY" = "n" ]; then refreshUI; OBBrepeat="true"; getOBB
			else refreshUI; OBBrepeat="true"; getOBB; fi
		fi
		launchCMD="monkey -p $OBBname -c android.intent.category.LAUNCHER 1"
	else
		OBBvalid="false"
	fi

	until [ "$OBBvalid" = "true" ]; do
		refreshUI; OBBrepeat="true"
		printf "%*s\n" $((COLS/2)) "$oops"
		printf "$OBBname\n"
		printf "%*s\n\n" $((COLS/2)) "That is not an OBB!"

		getOBB
	done
}

getAPK(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	APKvalid="true"

	printf "\n%*s\n\n" $((COLS/2)) "$APKquest"
	read -p '' APKfilePath
	APKfilePath="${APKfilePath%* }"
	local cleanPath="${APKfilePath#*:*}"; APKname=$(basename "$cleanPath")

	if [ "$APKfilePath" = "" ]; then
		refreshUI
		APKvalid="false"
		printf "%*s\n" $((COLS/2)) "$oops"
		printf "%*s\n\n" $((COLS/2)) "You forgot to drag the APK!"
		getAPK
	elif [ "${APKfilePath,,}" = "q" ] || [ "${APKfilePath,,}" = "quit" ] || [ "${APKfilePath,,}" = "wq" ] || [ "${APKfilePath,,}" = "qw" ]; then
		exitScript
	elif [ "${APKfilePath,,}" = "tool" ] || [ "${APKfilePath,,}" = "tools" ]; then
		toolMenu
	elif [[ "${APKname,,}" == *".apk" ]]; then
		APKvalid="true"
		printf "APK Name: $APKname\n\n"
	else
		APKvalid="false"
	fi

	until [ "$APKvalid" = "true" ]; do
		refreshUI
		printf "%*s\n" $((COLS/2)) "$oops"
		printf "%*s\n\n" $((COLS/2)) "That is not an APK!"
		printf "I'm sorry, I don't know what to do with this file..\n\n$APKname\n"
		getAPK
	done
	echo
}

INSTALL(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	scriptTitle="Installing...  "
	showIP="true"; updateAPK="false"

	tput civis; printHead; adbWAIT

	if [  "$qMode" = "false" ]; then
		printf "Mounting device...\n"
		adb devices
	else
		echo
	fi

	# uninstall app, unless APK step wants to continue from where it left off
	if [ "$UNINSTALL" = "true" ]; then
		wait | CMD_uninstall
		UNINSTALL="true"
	fi

	printTitle

	# upload OBB, only if it isn't already uploaded on deviceID
	if [ "$OBBdone" = "false" ] && [[ "$OBBname" == "com."* ]]; then
		printf "\nUploading OBB..\n"
		if (CMD_pushOBB && exit) || (
				(CMD_communicate && deviceConnect="true") || deviceConnect="false"
				if [ "$deviceConnect" = "true" ]; then
					errorMessage="FE1a - OBB could not be installed."
					printf "\n\nFE1a - OBB could not be installed.\n"

					( set -o posix ; set ) >/tmp/variables.after
					printf "Please report this error code (FE1a) to Nick.\n\n"; exit 1
				else OBBdone="false"; INSTALL; fi
			); then
				OBBdone="true"
				adbWAIT; deviceConnect="true"; deviceID=$(adb devices)
		else (exit 1); fi
	fi

	adbWAIT

	# install APK, only if APKdone=false
	if [ "$APKdone" = "false" ] && [[ "$APKname" == *".apk"* ]]; then
		if [[ "$OBBfilePath" == *"fire"* ]]; then
			printf "\n%*s\n\n" $((COLS/2)) "It may take a long time to install builds on this device.."
		fi

		printf "\nInstalling APK..\n"
		if CMD_installAPK || (
			(CMD_communicate && deviceConnect="true") || deviceConnect="false"
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
				tput cnorm; installAgainPrompt
			else
				tput cnorm; installAgainPrompt
			fi
		else (exit 1); fi
	fi
	tput cnorm; noInstall="false"
}

UPSTALL(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	scriptTitle="Installing...  "
	showIP="true"; updateAPK="true"

	tput civis; printHead; adbWAIT

	if [  "$qMode" = "false" ]; then
		printf "Mounting device...\n"
		adb devices
	else
		echo
	fi

	# uninstall app, unless APK step wants to continue from where it left off
	if [ "$UNINSTALL" = "true" ]; then
		wait | CMD_uninstall
		UNINSTALL="true"
	fi

	printTitle

	# install APK, only if APKdone=false
	if [ "$APKdone" = "false" ] && [[ "$APKname" == *".apk"* ]]; then
		if [[ "$OBBfilePath" == *"fire"* ]]; then
			printf "\n%*s\n\n" $((COLS/2)) "It may take a long time to install builds on this device.."
		fi

		printf "\nInstalling APK..\n"
		if CMD_installAPK || (
			(CMD_communicate && deviceConnect="true") || deviceConnect="false"
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
				tput cnorm; installAgainPrompt
			else
				tput cnorm; installAgainPrompt
			fi
		else (exit 1); fi
	fi
	tput cnorm; noInstall="false"
}

# check if user wants to install again on another device, or the same device if they choose to
installAgainPrompt(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	scriptTitle="\_Menu_/"; showIP="true"
	updateIP

	refreshUI

	printf "\n\t\t%*s" $((0)) "Choose your destiny!"
	printf "\t\t%*s\n" $((COLS/2)) "EXIT SCRIPT with 'q'"
	printf "\n\t%*s\n" $((COLS/2)) "Open the toolkit menu: t"
	printf "\n\t%*s\n" $((COLS/2)) "Install a different build: b"

	if [ "$APKname" = "" ]; then
		noInstall="true"
		APKname="You have not installed a build yet.."
		printf "\n%*s\n" $((0)) "$APKname"
		printf "\t%*s\n" $((COLS/2)) "Press any other key to continue!"
	else
		printf "\n%*s\n" $((0)) "$APKname"
		printf "\n\n%*s\n" $((0)) "!Press any other key to install ^that^ build again!"
	fi

	# ask for user input but do not allow user to drag in a file or directory
	read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
	while [[ "$REPLY" == *"/"* ]] || [ "$REPLY" = "" ]; do
		if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
			printf "\n%*s\n" $((0)) "Input ignored: the user dragged in a file or directory"
		fi

		read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
	done

	if [ "$REPLY" = "q" ] || [ "$REPLY" = "w" ]; then
		printf "\n%*s\n\n" $((0)) "Goodbye!"; exitScript
	elif [ "$REPLY" = "b" ]; then
		OBBdone="false"; APKdone="false"
		UNINSTALL="true"; scriptTitle="\_HappyDroid_/"

		refreshUI; tput cnorm

		getOBB; getAPK; INSTALL && echo || {
			printf "\nMAINd: caught fatal error in INSTALL\nSave varLog now\n"

			export scriptEndDate=""; scriptEndDate=$(date)
			export errorMessage="FE0 - Fatal Error. Copying all var data into ~/logs/$scriptEndDate.txt"
			printf "\nFE0 - Fatal Error.\nCopying all var data into ~/logs/$scriptEndDate.txt\n\n"

			diff $secureFile3 /tmp/variables.after > ~/logs/"$scriptEndDate".txt 2>&1
		} || (echo "catch fails"; exit 1)
	elif [ "$REPLY" = "t" ]; then
		toolMenu
	else
		OBBdone="false"; APKdone="false"

		if [ "$noInstall" = "true" ]; then
			if [[ "$*" == "--update" ]] || [[ "$*" == *"-u"* ]]; then
				# try update, catch
				MAINu && echo || lastCatch
			else
				# try install, catch
				MAINd && echo || lastCatch
			fi
		else
			installAgain
		fi
	fi
}

installAgain(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	adbWAIT
	deviceID2=$(adb devices); wait

	if [ "$deviceID" = "$deviceID2" ]; then
		refreshUI
		printf "\n\n%*s\n" $((COLS/2)) "This is the same device! Are you sure you want to install the build on this device again?"
		printf "\n%*s\n" $((COLS/2)) "Press 'y' to install on the same device, or any other key when you have plugged in another device."
		printf "\n%*s\n" $((COLS/2)) "Press 'q' to QUIT."

		# ask for user input but do not allow user to drag in a file or directory
		read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
		while [[ "$REPLY" == *"/"* ]] || [ "$REPLY" = "" ]; do
			if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
				printf "\n%*s\n" $((0)) "Input ignored: the user dragged in a file or directory"
			fi

			read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
		done

		if [ "$REPLY" = "y" ]; then
			UNINSTALL="true"; INSTALL
		elif [ "$REPLY" = "q" ] || [ "$REPLY" = "w" ]; then
			exitScript
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
		{ sleep 3; printf "        Ensure only one device is connected!"; } & { 
			until (CMD_communicate); do
				if [ "$sMode" = "false" ] && [ "$qMode" = "false" ]; then waiting; fi; deviceConnect="true"
			done

			# clear keyboard buffer to prevent user from sending input to future prompts
			perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
		}
		tput cnorm
		printf "\r%*s\n\n" $((COLS/2)) "!Device Connected!   "
	fi
}

# show the waiting animation
waiting(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	for i in "${anim3[@]}"; do
		printf "\r%*s" $((COLS/2)) "$i"
		sleep 0.045
	done
}

toolMenu(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	trap exitScript SIGINT SIGTERM # reset trap

	scriptTitle="Toolkit"; COLS=$(tput cols)
	topRun="false"

	if [ "$verbose" = 0 ]; then clear; fi
	refreshUI

	if [ "$toolOops" = "true" ]; then
		printf "%*s\n" $((COLS/2)) "$oops"
		printf "%*s\n\n" $((COLS/2)) "Wrong Key!"
		toolOops="false"
	fi

	printf "\n\t\t%*s" $((0)) "Choose your destiny!"
	printf "\t\t%*s\n" $((COLS/2)) "GO BACK to Main Menu with 'q'"
	printf "\n\t%*s\n" $((COLS/2)) "Screen capture mode:    p"
	printf "\n\t%*s\n" $((COLS/2)) "Device CPU and RAM stats (beta):    t"
	printf "\n\t\t%*s\n" $(((COLS/2)-1)) "Continuous Screen Recording (beta):    spacebar"

	# ask for user input but do not allow user to drag in a file or directory
	read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
	while [[ "$REPLY" == *"/"* ]] || [ "$REPLY" = "" ]; do
		if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
			printf "\n%*s\n" $((0)) "Input ignored: the user dragged in a file or directory"
		fi

		read -n 1 -s -r -p '' && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
	done

	if [ "$REPLY" = "q" ]; then
		installAgainPrompt
	elif [ "$REPLY" = " " ]; then
		if [ "$sMode" = "true" ]; then
			echo "Oops! Beta features don't work in safe mode!"; sleep 2
			toolMenu
		fi

		scriptTitle="\_dvrDroid_/"; refreshUI
		{ screenDVR && trap exitScript SIGINT SIGTERM; } || toolMenu
	elif [ "$REPLY" = "t" ]; then
		if [ "$sMode" = "true" ]; then
			echo "Oops! Beta features don't work in safe mode!"; sleep 2
			toolMenu
		fi

		topRun="true"; clear
		if adb -d shell exit; then
			updateIP
			{
				sleep 0.5
				while (trap exitScript SIGINT SIGTERM); do
					printf "\n%*s\n" $((COLS/2)) "Device IP Location: $deviceLOC"
					sleep 1.99
				done
			} & (adb -d shell top -d 2 -m 5 -o %MEM -o %CPU -o CMDLINE -s 1) || installAgainPrompt
		else installAgainPrompt; fi
	elif [ "$REPLY" = "p" ]; then
		snapDroid
	else
		toolOops="true"
		toolMenu
	fi
}

screenDVR(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	# make sure SIGINT always works even in presence of infinite loops
	exitScriptDVR() {
		trap - SIGINT SIGTERM SIGTERM # clear the trap
		tput cnorm
		adb -d shell echo \04; wait

		extract

		# remove all files in dir /sdcard/ beginning with 'rec.'
		adb -d shell rm -f *"/sdcard/rec."*; wait
		toolMenu; trap - SIGINT SIGTERM SIGTERM; exit # clear the trap
	}; trap exitScriptDVR SIGINT SIGTERM # set trap

	read -r -p 'Enter the file path (or just drag the folder itself) of where you want to save the video sequences.. ' savePath
	if [ "$savePath" = "" ]; then 
		printf "\nDefaulting to ~/screenRecordings_Android/\n"
		cd ~/screenRecordings_Android
	else
		cd $savePath
	fi

	adbWAIT

	# remove all files on device containing 'rec.'
	adb -d shell rm -f *"/sdcard/rec."*

	extract(){
		# kill script if script would have root privileges
		if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

		printf "\n%*s\n" $((0)) "Extracting.. $fileName .. to your computer!"
		wait && adb pull sdcard/$fileName || { adbWAIT && adb pull sdcard/$fileName 1>/ dev/null; }
	}

	record(){
		# kill script if script would have root privileges
		if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

		printf "$stopInfo_f"
		while true; do
			tStamp="$(date +'%Hh%Mm%Ss')"
			fileName="rec.$tStamp.$$.mp4"

			printf "\n%*s\n\n" $((0)) "Starting new recording: $fileName"
			adb -d shell screenrecord /sdcard/$fileName || { adbWAIT; wait; extract; }

			# running extract in a sub-process means only 0.5 seconds or so of delay between videos
			extract &
		done
	}
	record && wait && exitScriptDVR
}

snapDroid(){
	if [ "$EUID" = 0 ]; then echo "You cannot run script this with root privileges!"; kill $( jobs -p ) 2>/dev/null || exit 1; fi

	# remove all files on device containing 'rec.'
	adbWAIT
	adb -d shell rm -f *"/sdcard/snap."*

	scriptTitle="SnapDroid"; refreshUI

	until false; do
		tStamp="$(date +'%Hh%Mm%Ss')"
		snapName="snap.$tStamp.$RANDOM.PNG"

		printf "\n%*s\n" $((COLS/2)) "Return to HappyDroid? Press q!"
		printf "\n%*s\n\n" $((COLS/2)) "Press any other key to snap!"

		# ask for user input but do not allow user to drag in a file or directory
		read -n 1 -s -r -p '' snapControl && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
		while [[ "$snapControl" == *"/"* ]] || [ "$snapControl" = "" ]; do
			if [ "$verbose" = 1 ] || [ "$verbose" = 2 ]; then
				printf "\n%*s\n" $((0)) "Input ignored: the user dragged in a file or directory"
			fi
	
			read -n 1 -s -r -p '' snapControl && perl -e 'use POSIX; tcflush(0, TCIFLUSH);'
		done

		if [ "$snapControl" = "q" ]; then
			toolMenu
		elif [ "$snapControl" = "e" ]; then
			echo
			adb -d shell screencap -p "/sdcard/$snapName"

			wait && {
				cd ~/Desktop
				adb -d pull /sdcard/$snapName
				printf "%*s\n\n" $((COLS/2)) "Saved to your Desktop!"
				sleep 1; toolMenu
			}
		else
			echo
			adb -d shell screencap -p "/sdcard/$snapName"

			wait && {
				cd ~/Desktop
				adb -d pull /sdcard/$snapName
				printf "%*s\n\n" $((COLS/2)) "Saved to your Desktop!"
			}
		fi
	done
}

if [[ "$*" == "--update" ]] || [[ "$*" == *"-u"* ]]; then
	# try update, catch
	MAINu && echo || lastCatch
else
	# try install, catch
	MAINd && echo || lastCatch
fi

# finally remove temporary data created by the script and exit
CMD_rmALL; printf '\e[8;$usr_tHeight;{$usr_tWidth}t'; printf '\e[3;370;60t'
printf "\nGoodbye!\n"; exit
