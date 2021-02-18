![Rock on!](https://github.com/FHomps/MCBC/blob/master/logo.png?raw=true)

## MCBC - Minecraft Bash Controller

A simple custom script for minecraft server administration. Easy commands for turning the server on and off, automatically updating the jar file, and backing up the server.

MCBC is made to work nicely with cron; the backup command is smart and will not backup the server if no players were online since the last backup.

Note that if you stop then start the server, MCBC won't know if players were present before the restart and will skip backupping until a player logs in. Directly restarting with MCBC automatically asks for an offline backup and as such does not have this problem.

My personal crontab configuration:

```
50 1 * * * ~/paper/mcbc.sh announce_restart
0 0-1,3-23 * * * ~/paper/mcbc.sh backup --live
30 * * * * ~/paper/mcbc.sh backup --live
```
