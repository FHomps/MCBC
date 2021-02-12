# papermc_scripts
Simple custom scripts for PaperMC minecraft server administration.

These scripts assume that your Paper server is installed in a folder named "paper" in the home directory of the user who runs them.

The scripts are made to work nicely with cron to make backups of your server; ```backup.sh``` is smart and will not backup the server if no players were online since the last backup.

You can still trigger all the scripts manually. ```backup.sh``` accepts the arguments --live (for backups while the server is online) and --noskip (for forcing a backup even with no detected player activity).

Note that if you execute ```stop.sh``` then ```start.sh```, ```backup.sh``` won't know if players were present before the restart and will skip backupping until a player logs in. ```restart.sh``` automatically asks for an offline backup and as such does not have this problem.

My personal crontab configuration:

```
50 1 * * * ~/paper/announce_restart.sh
0,30 0-1,3-23 * * * ~/paper/backup.sh --live
```
