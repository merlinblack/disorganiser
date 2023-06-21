#!/usr/bin/env bash

mkdir -p pibuild
cd pibuild
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi.cmake -Wno-dev .. 
#cmake -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi.cmake -Wno-dev .. 
make CXX_FLAGS=-DNOBUYUK -j24

ssh rpi "mkdir -p ~/prog/disorganiser"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions ../rpi.sh disorganiser scripts media rpi:~/prog/disorganiser

