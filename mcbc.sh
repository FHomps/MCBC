#!/bin/bash

# Default configuration

# General
screen_name='minecraft'
min_memory=512M
max_memory=2048M
jar_name='paperclip.jar'
autoupdate_jar=true
jar_url='https://papermc.io/api/v1/paper/1.16.5/latest/download'

# Backups
num_backups=20
world_files=( "world" "world_nether" "world_the_end" )
backup_start_msg='Starting live backup, the server may lag for a bit.'
backup_done_msg='Live backup done!'

# Logging
num_logs=50

mc__is_running() {
  screen -list | grep -q "$screen_name"
  return $?
}

mc__start() {
  if mc__is_running ; then
    echo "Server already running!"
  else
    if [ "$autoupdate_jar" = true ] ; then
      echo "Updating server jar..."
      wget -O "$jar_name" "$jar_url"
    fi
    echo "Starting server..."
    screen -d -m -S "$screen_name" java -Xms"$min_memory" -Xmx"$max_memory" -jar "$jar_name"
  fi
}

mc__stop() {
  if ! mc__is_running ; then
    echo "Server not started!"
  else
    screen -S "$screen_name" -X stuff "stop^M"
    while mc__is_running ; do
      sleep .1
    done
    echo "Successfully shut down server."
    if [ `ls logs | wc -l` -gt "$num_logs" ] ; then
      echo "Too many log files, purging..."
      while [ `ls logs | wc -l` -gt "$num_logs" ] ; do
        rm logs/"$(ls -t logs | tail -1)"
      done
    fi
  fi
}

mc__backup() {
  for arg in "$@" ; do
    case "$arg" in
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
      return 1
      ;;
    esac
  done

  loghead='^\[..:..:..] \[Server thread\/INFO\]: '

  if [ "$live" = true ] ; then
    echo "Attempting live backup..."
    if ! mc__is_running ; then
      echo "Server not started!"
      return 1
    fi
  else
    echo "Attempting offline backup..."
    if mc__is_running ; then
      echo "Server still running!"
      return 1
    fi
  fi

  if ! [ "$noskip" = true ] \
     && ! tac logs/latest.log | sed "/${loghead}\[Server\] ${backup_start_msg}/q" | tac | \
            grep -q "${loghead}There are [1-9][0-9]* of a max of [0-9]\+ players online" \
     && ! tac logs/latest.log | sed "/${loghead}\[Server\] ${backup_done_msg}/q" | tac | \
            grep -q "${loghead}\w* joined the game" ; then
    echo "No players online since last backup or restart, skipping backup"
    return 0
  fi

  if [ "$live" = true ] ; then
    echo "Announcing backup..."
    screen -S "$screen_name" -X stuff "say ${backup_start_msg}^M"
    screen -S "$screen_name" -X stuff "save-off^M"
    screen -S "$screen_name" -X stuff "save-all flush^M"
    # List current players to let next backups know if there was any player activity between backups
    screen -S "$screen_name" -X stuff "list^M"

    echo "Waiting for world flush..."
    # Wait for the save-all command to start processing before testing to see if it finished
    # (the write to latest.log is not instant)
    sleep 1
    # Wait for the save-all command to stop processing
    while ! tac logs/latest.log | sed "/${loghead}Saving the game/q" | tac | \
              grep -q "${loghead}Saved the game" ; do
      sleep 0.1
    done
  fi

  echo "Backing up world..."
  backuptime=`date +%d-%m-%y_%H:%M:%S`
  copydir=backup/"${backuptime}"_temp
  mkdir -p "$copydir"
  cp -r "${world_files[@]}" "$copydir"
  echo "Copied world files to ${copydir}; compressing..."

  if [ "$live" = true ] ; then
    screen -S "$screen_name" -X stuff "save-on^M"
  fi

  tar -cpzf backup/"${backuptime}".tar.gz "${copydir}"/*
  rm -rf "$copydir"

  if [ "$live" = true ] ; then
    screen -S "$screen_name" -X stuff "say ${backup_done_msg}^M"
  fi

  echo "Backup done."

  if [ `ls backup | wc -l` -gt "$num_backups" ] ; then
    echo "Too many backups, purging..."
    while [ `ls backup | wc -l` -gt "$num_backups" ] ; do
      rm backup/"$(ls -t backup | tail -1)"
    done
  fi
}

mc__restart() {
  if ! mc__is_running ; then
    echo "Server not started!"
  else
    mc__stop
    mc__backup
    echo "Restarting server..."
    mc__start
  fi

}

mc__announce_restart() {
  if ! mc__is_running ; then
    echo "Server not started!"
  else
    screen -S "$screen_name" -X stuff "say Server restarting in 10 minutes!^M"
    sleep 300
    screen -S "$screen_name" -X stuff "say Server restarting in 5 minutes!^M"
    sleep 240
    screen -S "$screen_name" -X stuff "say Server restarting in 1 minute!^M"
    sleep 50
    screen -S "$screen_name" -X stuff "say Server restarting in 10 seconds!^M"
    sleep 10
    mc__restart
  fi
}

print_help() {
  cat << EOF
Available switches:
  -d                  specify the server directory

Available commands:
  start               start the server
  stop                stop the server
  backup              start a server backup
    --live              backup running server
    --noskip            don't check for player activity
  restart             restart the server
  announce_restart    plan a restart in 10 minutes and announce it
EOF
}

folder=`dirname "$0"`

while getopts "d:" opt; do
  case "$opt" in
    d) folder="$OPTARG" ;;
    \?) print_help ; exit 1 ;;
  esac
done

shift $(( OPTIND - 1 ))

cd "$folder" || { echo "Directory $folder not found, aborting." ; exit 1 ; }
. mcbc.conf || { echo "MCBC configuration file not found in `pwd`, aborting." ; exit 1 ; }

if [ $# -eq 0 ] ; then
  echo "No command specified."
  print_help
  exit 1
fi

cmd="mc__$1"
if declare -f "$cmd" > /dev/null ; then
  shift
  "$cmd" "$@"
  exit 0
else
  echo "${1}: command not found."
  print_help
  exit 1
fi
