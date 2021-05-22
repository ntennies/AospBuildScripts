#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 2
fi

sudo docker run --entrypoint="/home/ubuntu/Android/build_scripts/clean_build_docker.sh" --rm -v ~/Android:/home/ubuntu/Android android-build-trusty $1



