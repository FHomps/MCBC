#!/bin/bash

NUMLOGS=50

if ! screen -list | grep -q "minecraft" ; then
  echo "Server not started!"
else
  cd ~/paper
  screen -S minecraft -X stuff "stop^M"
  while screen -list | grep -q "minecraft" ; do
    sleep .1
  done
  echo "Successfully shut down server."
  cd logs
  if [ `ls | wc -l` -gt $NUMLOGS ] ; then
    echo "Too many log files, purging..."
    while [ `ls | wc -l` -gt $NUMBACKUPS ] ; do
      rm "$(ls -t | tail -1)"
    done
  fi
  cd ..
fi
