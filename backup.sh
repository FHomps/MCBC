#!/bin/bash

NUMBACKUPS=10

if screen -list | grep -q "minecraft" ; then
  echo "Server still running!"
else
  cd ~/paper
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
fi
