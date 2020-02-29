# Android-Installer
Android Installer

This script simplifies the process of installing builds on Android devices via Mac OSX using Android Debug Bridge.

In order to use this script, you must have Android Debug Bridge platform-tools installed on your machine.

If the app you are installing is already present on the device, it will be uninstalled first. Future versions will detect the presence of an existing build of the app on the device and will ask if you want to update or replace the app.

Instructions:

Input one of the following when asked to drag in the OBB file, to skip installing OBB:

- "na"
- "no"
- "none"
- "0"
- "."

Or, enter "fire" to tell the script you are installing a build on an Amazon device.
