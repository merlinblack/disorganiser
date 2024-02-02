#!/usr/bin/env sh

cd $(dirname $0)

touch startedAt

if [ "$1" = "delay" ]; then
  sleep 10
fi

if [ -z "${DISPLAY}" ]; then
  export DISPLAY=:0
fi

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

restart=1
while [ $restart -eq 1 ]; do
  restart=0
  ./disorganiser --fullscreen
  if [ $? -eq 2 ]; then
    restart=1
  fi
done
