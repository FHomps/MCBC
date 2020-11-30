#!/bin/bash

NUMBACKUPS=5

if ! screen -list | grep -q "minecraft" ; then
  echo "Server not started!"
else
  cd ~/paper
  sh stop.sh
  sh backup.sh
  echo "Restarting server..."
  sh start.sh
fi
