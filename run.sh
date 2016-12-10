#!/bin/bash

usage="What do you want to do?
    E, -encrypt \t encrypt all files in .confidential/ and output confidential.tar.gz.gpg
    D, -decrypt \t decrypt confidential.tar.gz.gpg and place files in .confidential/
    C, -clean \t delete files in ./confidential

    P, -pull (-f) \t sync local ST3 settings from master; append -f to disregard if ST3 is running
    U, -update \t commit updated settings to master

    B, -bang \t Start the smallbang initializer script"

echo -en "${usage}\n\nCommand: "
read input
cd ~/wrkspc/microcosm

case $input in
    E|-encrypt|C|-clean|D|-decrypt) source crypto.sh "-${input}"; ;;
    P|-pull|"P -f"|"-pull -f"|U|-update) source sublsync.sh "-${input}"; ;;
    B|-bang) source smallbang.sh "-${input}"; ;;
    *) echo -e "Invalid command\n"; ;;
esac;
