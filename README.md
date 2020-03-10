# Android-Installer v1.2

Minimum requirements:
- Bash shell
- Android Debug Bridge

Additional requirements for complete functionality:
- Internet connection
- Figlet (http://www.figlet.org/)

Description:

This script simplifies the process of installing builds on Android devices via Mac OSX using Android Debug Bridge.

Options:
- -q or --quiet	:____run the script in quiet mode
- -d or --debug:____run the script in debug mode. Add a -v for increased verbosity!
- -h or --help	:____show the help page in the terminal
- -t or --top	:____show device's live CPU and RAM usage


Instructions:
	If you do not want to install an OBB file, or if there is not one to install in the first place,
	then input one of the following when asked to drag in the OBB file:

- "na"
- "0"
- "."

	Enter "fire" to tell the script you are installing a build on an Amazon device.

Otherwise, drag in the OBB to the terminal window and press enter to continue the installation process.

DEV:

If you want users to be able to have full script functionality, then before running this script, populate the fireAPPS array in the beginning of the source code as well as the 'studio' variable.
