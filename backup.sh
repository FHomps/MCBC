#!/bin/bash

NUMBACKUPS=20
WORLDFILES=( "world" "world_nether" "world_the_end" )

STARTMSG='Starting live backup, the server may lag for a bit.'
DONEMSG='Live backup done!'

for arg in "$@" ; do
  case $arg in
    --live)
    live=true
    shift
    ;;
    --noskip)
    noskip=true
    shift
    ;;
    *)
    echo "Unrecognized argument $arg"
    exit 1
    ;;
  esac
done

LOGHEAD='^\[..:..:..] \[Server thread\/INFO\]: '

if [ "$live" = true ] ; then
  echo "Attempting live backup..."
  if ! screen -list | grep -q "minecraft" ; then
    echo "Server not started!"
    exit 1
  fi
else
  echo "Attempting offline backup..."
  if screen -list | grep -q "minecraft" ; then
    echo "Server still running!"
    exit 1
  fi
fi

cd ~/paper

if ! [ "$noskip" = true ] \
   && ! tac logs/latest.log | sed "/${LOGHEAD}\[Server\] ${STARTMSG}/q" | tac | \
          grep -q "${LOGHEAD}There are [1-9][0-9]* of a max of [0-9]\+ players online" \
   && ! tac logs/latest.log | sed "/${LOGHEAD}\[Server\] ${DONEMSG}/q" | tac | \
          grep -q "${LOGHEAD}\w* joined the game" ; then
  echo "No players online since last backup or restart, skipping backup"
  exit 0
fi

if [ "$live" = true ] ; then
  echo "Announcing backup..."
  screen -S minecraft -X stuff "say ${STARTMSG}^M"
  screen -S minecraft -X stuff "save-off^M"
  screen -S minecraft -X stuff "save-all flush^M"
  # List current players to let next backups know if there was any player activity between backups
  screen -S minecraft -X stuff "list^M"
  
  echo "Waiting for world flush..."
  # Wait for the save-all command to start processing before testing to see if it finished
  # (the write to latest.log is not instant)
  sleep 1
  # Wait for the save-all command to stop processing
  while ! tac logs/latest.log | sed "/${LOGHEAD}Saving the game/q" | tac | \
            grep -q "${LOGHEAD}Saved the game" ; do
    sleep 0.1
  done
fi

echo "Backing up world..."
BACKUPTIME=`date +%d-%m-%y_%H:%M:%S`
COPYDIR=backup/${BACKUPTIME}_temp
mkdir $COPYDIR
cp -r ${WORLDFILES[@]} $COPYDIR
echo "Copied world files to ${COPYDIR}; compressing..."

if [ "$live" = true ] ; then
  screen -S minecraft -X stuff "save-on^M"
fi

tar -cpzf backup/${BACKUPTIME}.tar.gz ${COPYDIR}/*
rm -rf $COPYDIR

if [ "$live" = true ] ; then
  screen -S minecraft -X stuff "say ${DONEMSG}^M"
fi

echo "Backup done."

cd backup
if [ `ls | wc -l` -gt $NUMBACKUPS ] ; then
  echo "Too many backups, purging..."
  while [ `ls | wc -l` -gt $NUMBACKUPS ] ; do
    rm "$(ls -t | tail -1)"
  done
fi
cd ..
