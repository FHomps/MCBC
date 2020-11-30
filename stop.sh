#!/bin/bash

NUMBACKUPS=5

if ! screen -list | grep -q "minecraft" ; then
  echo "Server not started!"
else
  cd ~/paper
  screen -S minecraft -X stuff "stop^M"
  while screen -list | grep -q "minecraft" ; do
    sleep .1
  done
  echo "Successfully shut down server."
fi
