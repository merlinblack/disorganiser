#!/usr/bin/env bash

mkdir -p pibuild
cd pibuild
cmake -DCMAKE_TOOLCHAIN_FILE=$HOME/prog/rpi/toolchain-raspberrypi.cmake -Wno-dev .. 
make -j24

ssh rpi "mkdir -p ~/prog/disorganiser"
rsync -avz --copy-dirlinks --delete ../rpi.sh disorganiser scripts media rpi:~/prog/disorganiser

