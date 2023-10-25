#!/usr/bin/env bash

mkdir -p pibuild
cd pibuild
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi.cmake -Wno-dev ..
make -j16

ssh vimes.local "mkdir -p ~/prog/disorganiser"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions ../run.sh disorganiser scripts media vimes.local:~/prog/disorganiser

