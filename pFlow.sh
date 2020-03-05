#!/bin/bash
getOBB(){
	printf "\ngetOBB completes successfully\n"
}

getAPK(){
	printf "\ngetAPK completes successfully\n"
}

INSTALL(){
	(printf "\n\nadb uninstall\n"; exit)
	sleep 0.8
	
	printf "\nUploading OBB..\n"
	echo "varLogSaveAfter.txt"
	(echo "pushOBB"; sleep 0.5; exit 1) || (echo "exit 1"; exit 1)
	
	printf "\nInstalling APK..\n"
	echo "varLogSaveAfter.txt"

	if (echo "install APK"; sleep 0.5; exit) || (echo "exit 1"; exit 1); then
		printf "\nlaunch app\n"
	else (exit 1); fi
}

MAIN(){
	clear; printf "\nvarLogSaveBefore.txt\n\n"; sleep 0.5
	getOBB; getAPK
	INSTALL && echo || printf "\nMAIN: caught error in MAIN\nSave varLog now\n" || (echo "catch fails"; exit 1)
}

MAIN && echo || printf "\nFINAL: caught error in error handling\n"
printf "Goodbye!\n"; exit