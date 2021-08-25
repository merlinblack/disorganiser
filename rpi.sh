#!/usr/bin/env sh
if [ -z "${DISPLAY}" ]; then
  export DISPLAY=:0
fi

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

./disorganiser rpi
