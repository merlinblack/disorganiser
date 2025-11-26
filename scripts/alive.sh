#! /usr/bin/env bash

if ! ping -c1 -W1 $1 &> /dev/null; then
    echo dead
else
    echo alive
fi
