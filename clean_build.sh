#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 2
fi

#docker run -it --rm -v ~/Android:/home/ubuntu/Android android-build-trusty

sudo docker run --rm -v ~/Android:/home/nathantennies/Android android-build-trusty '/home/nathantennies/Android/build_scripts/clean_build_docker.sh' $1




