#!/usr/bin/env bash

mkdir -p minibuild
cd minibuild
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -Wno-dev .. 
make -j24

ssh macmini.local "mkdir -p ~/prog/disorganiser"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions ../run.sh disorganiser scripts media macmini.local:~/prog/disorganiser

