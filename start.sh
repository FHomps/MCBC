#!/bin/bash

if screen -list | grep -q "minecraft" ; then
  echo "Server already running!"
else
  cd ~/paper
  echo "Updating Paper..."
  wget -O paperclip.jar https://papermc.io/ci/job/Paper-1.16/lastSuccessfulBuild/artifact/paperclip.jar
  echo "Starting server..."
  screen -d -m -S minecraft java -Xms512M -Xmx3584M -jar paperclip.jar
fi
