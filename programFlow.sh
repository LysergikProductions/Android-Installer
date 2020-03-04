#!/bin/bash
getOBB(){
  echo "getOBB completes successfully"; echo
  sleep 1
}

getAPK(){
  echo "getAPK completes successfully"; echo
  sleep 1; INSTALL
}

INSTALL(){
  (echo "adb uninstall"); sleep 1
  
  (
    printf "\nUploading OBB..\n"
    (echo "pushOBB succeeds") && exit || echo "catch error in INSTALL"; echo; exit 1
  )

  sleep 1

  (
    printf "\nInstalling APK..\n"
    (echo "install APK fails"; exit) && exit 1 || echo "catch error in INSTALL"; echo; exit 1
  )
}

MAIN(){
  getOBB
  (getAPK) && exit || sleep 1; printf "\nMAIN: catch error in MAIN\n"; exit 1
}

(MAIN) || echo "FINAL: catch error in error handling\n"
printf "\nGoodbye!\n"; exit