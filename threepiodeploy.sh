#!/usr/bin/env bash

ssh -t threepio "mkdir -p ~/prog/disorganiser/build"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions CMakeLists.txt cmake lua manualbind run.sh src scripts media threepio:~/prog/disorganiser

ssh -t threepio "cd ~/prog/disorganiser/build; cp ../run.sh . && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -Wno-dev .. && make -j2 "


