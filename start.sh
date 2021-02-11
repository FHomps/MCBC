#!/bin/bash

if screen -list | grep -q "minecraft" ; then
  echo "Server already running!"
else
  cd ~/paper
  echo "Updating Paper..."
  wget -O paperclip.jar 'https://papermc.io/api/v1/paper/1.16.5/latest/download'
  echo "Starting server..."
  screen -d -m -S minecraft java -Xms512M -Xmx3584M -jar paperclip.jar
fi
