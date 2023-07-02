#!/usr/bin/env bash

mkdir -p pibuild
cd pibuild
CXX_FLAGS=-DNOBUYUK cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi.cmake -Wno-dev .. 
#cmake -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi.cmake -Wno-dev .. 
make -j

ssh vimes.local "mkdir -p ~/prog/disorganiser"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions ../rpi.sh disorganiser scripts media vimes.local:~/prog/disorganiser

