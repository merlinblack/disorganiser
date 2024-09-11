#!/usr/bin/env bash

mkdir -p pibuild64
cd pibuild64
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi64.cmake -Wno-dev ..
make -j16

ssh threepio.local "mkdir -p ~/prog/disorganiser"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions ../run.sh disorganiser scripts media threepio.local:~/prog/disorganiser

