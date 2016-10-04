#!/bin/bash

usage="$(basename "$0") <options> -- Sync ST3 user settings to || from microcosm.git/HEAD

where <options>:
    -P, --pull   \t sync local settings from master; append -f to disregard if ST3 is running
    -C, --commit \t commit updated settings to master
    -h, --help   \t show this message"

if [[ ( "$1" = "-P" ) || ( "$1" = "--pull" ) ]]; then
    if [[ ( -z $(pgrep -x sublime_text) ) || ( "$2" = "-f" ) ]]; then
        echo "Copying ST3 package and IDE settings"
        git pull origin master
        cp Preferences.sublime-settings ~/.config/sublime-text-3/Packages/User/
        cp Package\ Control.sublime-settings ~/.config/sublime-text-3/Packages/User/
    else
        echo "Close all running instances of sublime text"
    fi
elif [[ ( "$1" = "-C" ) || ( "$1" = "--commit" ) ]]; then
    echo "Syncing local settings back to Github"
    idePreferences=Preferences.sublime-settings
    packageControl=Package\ Control.sublime-settings

    cp ~/.config/sublime-text-3/Packages/User/${idePreferences} .
    cp ~/.config/sublime-text-3/Packages/User/${packageControl} .

    git add "${packageControl}" "${idePreferences}"
    git commit -m "Updating ST3 user settings"
    git push origin master
else
    echo -e "${usage}"
fi

exit
