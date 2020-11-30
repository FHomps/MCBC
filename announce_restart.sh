#!/bin/bash

if ! screen -list | grep -q "minecraft" ; then
  echo "Server not started!"
else
  cd ~/paper
  screen -S minecraft -X stuff "say Server restarting in 10 minutes!^M"
  sleep 300
  screen -S minecraft -X stuff "say Server restarting in 5 minutes!^M"
  sleep 240
  screen -S minecraft -X stuff "say Server restarting in 1 minute!^M"
  sleep 50
  screen -S minecraft -X stuff "say Server restarting in 10 seconds!^M"
  sleep 10
  sh restart.sh
fi
