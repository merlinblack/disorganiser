#! /usr/bin/env bash

source $HOME/.local/bin/ANSI

if [ ! -d ~/Dropbox/Zips ]; then
  echo -e "${RED}Can not find Dropbox Zips directory${NC}"
  exit 1
fi

echo -e "${PURPLE}Tarring media directory and moving to Dropbox${NC}"

tar cvzf media.tgz media | lolcat

echo -e "${PURPLE}Testing${NC}"

tar tf media.tgz

if [ $? -eq 0 ]; then
  echo -e "${PURPLE}Moving to dropbox${NC}"
  mv media.tgz ~/Dropbox/Zips/media.tgz
fi

echo -e "${PURPLE}Done${NC}"
