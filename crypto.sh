#!/bin/bash

usage="$(basename "$0") <options> -- Encrypt or decrypt files in the .confidential/ directory

where <options>:
    -E, --encrypt \t encrypt all files in .confidential/ and output confidential.tar.gz.gpg
    -D, --decrypt \t decrypt confidential.tar.gz.gpg and place files in .confidential/
    -C, --clean   \t delete files in ./confidential
    -h, --help    \t show this message"

if [[ ! -d ".confidential" ]]; then
    mkdir .confidential
fi

if [[ ( "$1" = "-E" ) || ( "$1" = "--encrypt" ) ]]; then
    tar czvpf - -C .confidential . | gpg --symmetric --cipher-algo aes256 -o confidential.tar.gz.gpg
elif [[ ( "$1" = "-D" ) || ( "$1" = "--decrypt" ) ]]; then
    cd .confidential
    gpg -d ../confidential.tar.gz.gpg | tar xzvf -
elif [[ ( "$1" = "-C" ) || ( "$1" = "--clean" ) ]]; then
    rm .confidential/*
else
    echo -e "${usage}"
fi

exit
