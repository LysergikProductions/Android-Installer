#!/bin/bash
getOBB(){
	printf "\ngetOBB completes successfully\n"
	export OBBfilePath="com.obb"; sleep 0.5
}

getAPK(){
	printf "\ngetAPK completes successfully\n"
	sleep 0.5
}

INSTALL(){
	printf "\ncheck for proper connect\n"
	(printf "\n\nadb uninstall\n"; exit)
	sleep 0.8
	
	printf "\nUploading OBB..\n"
	echo "varLogSaveAfter.txt"
	if (echo "pushOBB"; sleep 0.5; exit) || (echo "exit 1; FE1a"; exit 1); then
		printf "\ncheck for proper connect, and define deviceID(1)\nMove on to installing APK\n"
	fi
	
	sleep 1

	printf "\ncheck for proper connect\n"
	printf "\nInstalling APK..\n"
	echo "varLogSaveAfter.txt"

	if (echo "install APK"; sleep 0.5; exit) || (echo "exit 1; FE1b"; exit 1); then
		if [ "$OBBfilePath" = "fire" ] || [ "$OBBfilePath" = "." ] || [ "$OBBfilePath" = "0" ] || [ "$OBBfilePath" = "na" ]; then
			printf "\ncheck for proper connect, and define deviceID(1)\nAsk user if they want to install again\n"
		else
			printf "\ncheck for proper connect\n"
			printf "\n\nLaunching app."; sleep 0.4; printf " ."; sleep 0.4; printf " ."; sleep 0.4; printf " .\n"
			printf "\ndefine deviceID(1)\nAsk user if they want to install again\n"
		fi
	else (exit 1); fi
}

MAIN(){
	clear; printf "\ncheck for proper connect\n"
	printf "\nvarLogSaveBefore.txt\n\n"; sleep 0.5
	getOBB; getAPK
	INSTALL && echo || printf "\nMAIN: caught error in MAIN\nSave varLog now\n" || (echo "catch fails"; exit 1)
}

MAIN && echo || printf "\nFINAL: caught error in MAIN's error handling\n"
printf "Goodbye!\n"; exit
