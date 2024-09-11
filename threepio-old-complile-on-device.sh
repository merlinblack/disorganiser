#!/usr/bin/env bash

ssh -t threepio "mkdir -p ~/prog/disorganiser/build"
rsync -avzhP --copy-dirlinks --delete --exclude=scripts/definitions .git CMakeLists.txt cmake lua manualbind run.sh src scripts media threepio:~/prog/disorganiser

# init 3 to shutdown X for more memory for compiling - init 5 to start again
ssh -t threepio "sudo init 3; cd ~/prog/disorganiser/build; cp ../run.sh . && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -Wno-dev .. && make -j2 ; sudo init 5"


