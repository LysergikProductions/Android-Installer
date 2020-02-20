#!/bin/bash
#MonkeyStress_v1.1.5b-release.sh
#Nikolas A. Wagner © 2020

# This script creates a simplified process for creating, running, and repeating various ADB-based stress tests on Android apps

#declaring some global variables
scriptName="Monkey Stress v1.1.5b-release"; scriptTitle="***MONKEY STRESS***"; author="Nikolas A. Wagner"
scriptVersion="1.1.5b"; scriptVersionType="release"; adbVersion="ADB Error!"; license="GNU GPLv3"

COLS=$(tput cols) #this variable is used when printing center-justified strings

#some variables that need default values
preCMD="monkey -p "; defDELAY="0"; backDELAY="0.1"; adbType=""; OBB=""; amazonBuild="false"
loopFromError="false"; errorMessage="..no error is saved here.."

# The only real code outside of any functions are the last two lines. They go as follows:
# checkADB #checking if adb is installed; installs adb if necessary
# MAIN #calling the main function..

function MAIN(){ #this runs the core of the program through each function in the intended order
	if [ $loopFromError = "false" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
	elif [ $loopFromError = "true" ]; then
    	clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "$errorMessage\n\n"

    	if [ $deviceConnect = "false" ]; then
			echo "When your *just one* device is connected and ready:"
			read -n 1 -s -r -p "Press any key.."; echo
		elif [ $deviceConnect = "true" ]; then
			echo
		else
			export errorMessage="$errorMessage\n\n--------------------------------\n\n"
    		export errorMessage+="ER1 - Script restarted; 'deviceConnect' had an unexpected value: $deviceConnect"
    		export loopFromError="true"; export deviceConnect="true"

			printf "\nER1 - Unexpected value in 'deviceConnect'; resetting script in..\n"
			printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
			MAIN
		fi
  	else
    	export errorMessage="$errorMessage\n\n--------------------------------\n\n"
    	export errorMessage+="ER1 - Script restarted; 'loopFromError' had an unexpected value: $loopFromError"
    	export loopFromError="true"

		printf "\nER1 - Unexpected value in 'loopFromError'; resetting script in..\n"
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
  	fi

	#Check for device connection; reset script in case of error
	printf "\nMounting device...\n\n"
	if adb shell settings put global development_settings_enabled 1 && adb devices; then
		deviceConnect="true"
	else
		loopFromError="true"; deviceConnect="false"
		export errorMessage="RE0 - Script restarted; could not connect to just one device.\n\n"
    	export errorMessage+="             -- Troubleshooting --\n"
    	export errorMessage+="2- Ensure only one device is connected and that is has USB Debugging permissions..\n"
    	export errorMessage+="For more help on this, search 'ADB fixAll' in google drive."

		sleep 1; printf "\nRE0 - Could not connect to just one device; resetting script in..\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
	fi

	UI_sep1="-------------------"
	printf "\n%*s\n" $[$COLS/2] "$scriptTitle"
	printf "%*s\n\n" $[$COLS/2] "$UI_sep1"

	#checking for fatal error while calling the main functions of the script
	if {
		getOBB && getCMD "$OBB" && RUN
	}; then printf "\nGoodbye!\n"; echo; exit
	else
		printf "\nFE0 - Fatal Error; problem calling main functions.\nPlease report this error code to Nick.\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		echo; exit 1
	fi
}

#check if the user has ADB installed, and if not then it install it on Mac OSX using HomeBrew
function checkADB(){
	local instruct="Would you like to install ADB now?"
	local options=("OK" "Cancel and Exit")

	#check if a network is available and update netReady boolean
	ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && export netReady="true" || export netReady="false"

	if adb version; then
		wait; clear; printf "\nLaunching MONKEY STRESS now..\n\n"; sleep 1
		ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && export netReady="true" || export netReady="false"; wait
		export adbVersion=$(adb version); sleep 1;
	else #ADB is not installed; attempt to install it with HomeBrew..
		if [ $netReady == "false" ]; then
			until [ $netReady == "true" ]
			do
				clear; ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && export netReady="true" || export netReady="false"
				printf "\nWaiting for an available network ."; sleep 1; printf " ."; sleep 1; printf " ."; sleep 1; wait
			done
			echo
			checkADB
		elif [ $netReady == "true" ]; then
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
					printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
				else #HomeBrew is not installed; installing HomeBrew..
					printf "\nHomeBrew needs to be installed for this. Installing HomeBrew..\n"
					if {ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"}; then
						wait; sleep 3; printf "\nHomebrew has been successfully installed. Installing ADB next..\n"
					else
						printf "\nFE2a - Fatal Error; ADB not installed and there was a problem while trying to install HomeBrew.\nPlease report this error code (FE2a) to Nick.\n"; sleep 1
						printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
						echo; exit 1
					fi
					#now that HomeBrew is installed, install ADB using HomeBrew
					if {brew cask install android-platform-tools}; then
						wait; echo; adbVersion=$(adb version)
						wait; sleep 3; printf "\nAndroid Debug Bridge (ADB) has been successfully installed. Launching MONKEY STRESS in..\n"
						printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
					else
						printf "\nFE2b - Fatal Error; ADB not installed and there was a problem while trying to install platform-tools.\nPlease report this error code (FE2b) to Nick.\n"; sleep 1
						printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
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

function RUN(){ #this function triggers adb monkey on the device
	local instruct="Would you like to repeat the stress test?"
	local options=("Repeat Test" "Change Test" "Quit")

	read -n 1 -s -r -p 'Press any key to begin the test..' ; echo
	
	until adb shell exit
	do
		clear; printf "\n\n- waiting for device -\n\n"
		sleep 1
	done

	#enable pointer location debug and lock screen rotation
	adb shell settings put system pointer_location 1
	adb shell settings put system user_rotation 0

	#run the finished command in the terminal
	if adb shell "$CMD"; then
		wait; printf "\nSuccess!!! The monkey dances in celebration!\n\n"

		echo "$instruct" #here the user is asked if they want to exit the scipt or perform it again
		select opt in "${options[@]}"
		do
			case $opt in
	        "Repeat Test")
				if [ $adbType = "monkey" ] ; then
					RUN
				elif [ $adbType = "keyEvent" ]; then
					backMadness
				else 
					export errorMessage="$errorMessage\n\n--------------------------------\n\n"
    				export errorMessage+="ER2 - Script restarted; adbType had an unexpected value."
    				export errorMessage+="             -- Troubleshooting --\n\n"
    				export errorMessage+="1- Looks like that test was broken. Try another test type!\n\n"
    				
    				export loopFromError="true"; export adbType="monkey"

					printf "\nER2 - Unexpected value in 'adbType'; resetting script in..\n"
					printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
					MAIN
				fi
				break
					;;
			"Change Test")
				getCMD "$OBB"; echo
				#when user selects change test after a test (in which case OBB step is already completed), RUN needs to call itself again
				if [[ $OBB == *"com."* ]]; then
					RUN
				else
					echo
				fi
				break
					;;
			"Quit")
				break
					;;
			*) printf "\nSorry, $REPLY is not an option!\n";;
			esac
	      done

	else
		export loopFromError="true"
    	export errorMessage="RE0 - Script restarted; the command could not be executed.\n\n"
    	export errorMessage+="             -- Troubleshooting --\n\n"
    	export errorMessage+="1- Make sure you dragged in the correct folder.\n\nPreviously, you dragged in:\n$OBB\n\n"
    	export errorMessage+="2- Ensure only one device is connected and that is has USB Debugging permissions..\n"
    	export errorMessage+="For more help on this, search 'ADB fixAll' in google drive."

		sleep 1; printf "\nRE0 - The command could not be executed; resetting script in..\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		MAIN
	fi
	
	#disable pointer location debug and unlock screen rotation
	adb shell settings put system pointer_location 0
	adb shell settings put system user_rotation 1
}

function getOBB(){ #this function gets the OBB name needed to isolate the monkey events to the app being tested
	read -p 'Drag OBB here: ' FilePath #i.e. Server:\ folder/folder/folder/com.studio.platform.appName
	if [ "$FilePath" == "" ]; then
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "Most Recent Error:\n$errorMessage\n\n--------------------------------\n"
		printf "You forgot to drag the OBB!\n\n"; getOBB
	elif [ "$FilePath" == *".amazon."* ]; then
		export amazonBuild="true"
		OBB="${FilePath#*:*}"
		export OBB=$(basename "$OBB"); printf "OBB Name: $OBB\n"
	else
		export amazonBuild="false"
		OBB="${FilePath#*:*}"
		export OBB=$(basename "$OBB"); printf "OBB Name: $OBB\n"
	fi

	until [[ $OBB == *"com."* ]] #ensures that the OBB name at least *appears* correct
	do #..example of accidiental wrong input by user: Server:\ folder/folder/folder/app.apk
		clear; printf "$scriptName\nby $author\n\n$adbVersion\nBash version ${BASH_VERSION}\n-----------------------------------------\n\n"
    	printf "Most Recent Error:\n$errorMessage\n\n--------------------------------\n"
		printf "That's not an OBB! I may be a monkey but I am no fool!\n\n"; getOBB
	done
}

function getCMD() { #formulate and remember the next adb monkey command to be run and save it to the global variable CMD
	local instruct="Select the test to perform:"
	local options=("Motion" "Touch" "Mixed Input" "Back Button")
	DELAY="$defDELAY"

	printf "\n$instruct"; echo #ask user for test type
	select opt in "${options[@]}" #create the prompt for the user to respond in and set multiple variables according to the user's input
	do
		case $opt in
		"Motion")
			adbType="monkey"; continueFunction="true"
			local TYPE=" --pct-motion 100 -v "
			echo; break
		 		;;
		"Touch")
			adbType="monkey"; continueFunction="true"
			local TYPE=" --pct-touch 100 -v "
	 		echo; break
		 		;;
		"Mixed Input")
			adbType="monkey"; continueFunction="true"
			local TYPE=" --pct-motion 90 --pct-touch 10 -v "
		 	echo; break
		 		;;
		"Back Button")
			adbType="keyEvent"; continueFunction="false"; echo

			read -p 'How many times do you want to spam the back button: ' backCount; echo
			until [[ $backCount =~ ^[+]?[0-9]+$ ]]
			do
				printf "Oops! Only whole numbers greater than or equal to 0 are allowed..\n\n"
				read -p 'How many times do you want to spam the back button: ' backCount; echo
			done

			read -p 'Delay in seconds between back button events: ' backDELAY; echo
			until [[ $backDELAY =~ ^[+]?[0-9]+$ ]]
			do
				printf "Oops! Only whole numbers greater than or equal to 0 are allowed..\n\n"
				read -p 'Delay in seconds between back button events: ' backDELAY; echo
			done

			printf "\nStarting test..\n"
		 	backMadness $backCount $backDELAY $adbType; break
				;;
		*) printf "\nSorry, $REPLY is not an option!\n";;
		esac
	done

	if [ $continueFunction = "true" ]; then
		#ask user for throttle (ms delay) time between events
		read -p 'Milliseconds between events (0 is most stressful): ' DELAY
		until [[ $DELAY =~ ^[+]?[0-9]+$ ]]
		do
			printf "Oops! Only whole numbers greater than or equal to 0 are allowed..\n\n"
			read -p 'Milliseconds between events (0 is most stressful): ' DELAY
		done
		echo

		#ask user for number of events to trigger consecutively
		read -p 'Events to trigger consecutively: ' COUNT
		until [[ $COUNT =~ ^[+]?[0-9]+$ ]]
		do
			printf "Oops! Only whole numbers greater than or equal to 0 are allowed..\n\n"
			read -p 'Events to trigger consecutively: ' COUNT
		done
		echo

		export DELAY=" --throttle $DELAY" #add that to the end of " --throttle "
		export CMD="$preCMD$1$DELAY$TYPE$COUNT" #formulate the command to be run on the device ($OBB is fed into this function, so $1 = $OBB)
	elif [ $continueFunction = "false" ]; then
		echo
	else
		printf "\nFE1 - Fatal Error; continueFunction had an unexpected value.\nPlease report this error code (FE1) to Nick.\n"; sleep 1
		printf "5.. "; sleep 1; printf "4.. "; sleep 1; printf "3.. "; sleep 1; printf "2.. "; sleep 1; printf "1.. "; sleep 1
		echo; exit 1
	fi
}

function backMadness(){
	local instruct="Would you like to repeat the stress test?"
	local options=("Repeat Test" "Change Test Properties" "Quit")

	for var_name in $(seq 1 $backCount); do
  		adb shell input keyevent 4
  		echo "Back button was pressed! (adb shell input keyevent 4)"
  		sleep "$backDELAY"
	done
	wait; printf "\nSuccess!!! The monkey dances in celebration!\n\n"

	echo "$instruct" #here the user is asked if they want to exit the scipt or perform it again
	select opt in "${options[@]}"
	do
		case $opt in
		"Repeat Test")
			if [ $adbType = "monkey" ] ; then
				RUN
			elif [ $adbType = "keyEvent" ] ; then
				backMadness $backCount $adbType
			else 
				echo "Unexpected value for 'adbType'."
				sleep 3; exit 1
			fi
			break
				;;
		"Change Test Properties")
			echo

			read -p 'How many times do you want to spam the back button: ' backCount; echo
			until [[ $backCount =~ ^[+]?[0-9]+$ ]]
			do
				printf "Oops! Only whole numbers greater than or equal to 0 are allowed..\n\n"
				read -p 'How many times do you want to spam the back button: ' backCount; echo
			done

			read -p 'Delay in seconds between back button events: ' backDELAY; echo
			until [[ $backDELAY =~ ^[+]?[0.1-9]+$ ]]
			do
				printf "Oops! Only whole numbers greater than or equal to 0 are allowed..\n\n"
				read -p 'Delay in seconds between back button events: ' backDELAY; echo
			done
			
			backMadness
			break
				;;
		"Quit")
			break
				;;
		*) printf "\nSorry, $REPLY is not an option!\n";;
		esac
	done

	printf "\nGoodbye!\n"; echo; exit
}

checkADB #checking if adb is installed; installs adb if necessary
MAIN #calling the main function..

#REFERENCES --
# https://stackoverflow.com/questions/21755674/bash-script-to-check-the-network-status-linux
# https://github.com/LysergikProductions/ADB-Based-Scripts.git
