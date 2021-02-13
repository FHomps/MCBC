#!/bin/bash

if ! screen -list | grep -q "minecraft" ; then
  echo "Server not started!"
else
  cd ~/paper
  ./stop.sh
  ./backup.sh
  echo "Restarting server..."
  ./start.sh
fi
