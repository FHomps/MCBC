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
  echo "Backing up world..."
  BACKUPTIME=`date +%d-%m-%y_%H:%M:%S`
  DESTINATION=backup/$BACKUPTIME.tar.gz
  tar -cpzf $DESTINATION world world_nether world_the_end
  echo "Backup done."
  cd backup
  if [ `ls | wc -l` -gt $NUMBACKUPS ] ; then
    echo "Too many backups, purging..."
    while [ `ls | wc -l` -gt $NUMBACKUPS ] ; do
      rm "$(ls -t | tail -1)"
    done
  fi
  cd ..
  echo "Restarting server..."
  sh start.sh
fi
