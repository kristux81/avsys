#!/bin/bash

# ******************************************************************
#
# Author : Krishna Singh Chauhan
# Email  : krishnasingh07@gmail.com
#
# Last Fixed on : 
# Version : 
# Public Release : 
#
# ******************************************************************

 . $AVSYS_ROOT/profile.sh

# Tell logger your current location
THIS=$0 ; export THIS

if [ $AUTO_STOP_TIME -ge 1 ]
then
echo "Started with Following Parameter list: $@ " >> auto_stopper.log
log DEBUG "Started with Following Parameter list: $@ "

#CRON_STAT=`ps -ef|grep cron | grep -v grep | sed -n '$='` ; export CRON_STAT
#if [ 1 -eq "$CRON_STAT" ]
 #   	then
    	 # schedule cron job for auto stop of player and parent
    	# echo "kill -SIGTERM `ps -eaf | grep $PLAYER | grep \`whoami\` | grep -v grep | awk '{ printf $2 }'`" | at now + $AUTO_STOP_TIME minutes
    	# echo "kill -SIGTERM $$" | at now + $AUTO_STOP_TIME minutes 1 seconds
    	# echo [cron job detail] > $TIMER_PIDFILE
        # exit process
#    	else
# continue

counter=$((AUTO_STOP_TIME))
for (( i=0 ; i< $counter ; i++ ))
do

# check if player is alive , otherwise kill self
PLAYER_STAT=`ps -eaf | grep $1 | wc -l`

if [ $PLAYER_STAT -lt 2 ]
then 
    log WARN " $PLAYER is already stopped. Exiting Application..."
    exit 0
fi

# sleep for 1 minute
  sleep 60
 log DEBUG "Player is Alive.."
done
  log INFO "Timer Expired."

#Stop Player if it is running

PLAYER_STAT=`ps -eaf | grep $1 | wc -l`

if [ $PLAYER_STAT -gt 1 ]
then    
    cecho "`basename $0` : Stopping Player on Timer Expiry..." $red
    PLAYER_PPID=`ps -eaf | grep $PLAYER | grep \`whoami\`| grep -v grep | awk '{ printf $3 }'`
    
    if [ $PLAYER_PPID -eq $1 ]
    then
       log INFO "Stopping Player on Timer Expiry..."
       kill -SIGTERM `ps -eaf | grep $PLAYER | grep \`whoami\` | grep -v grep | awk '{ printf $2 }'`
    fi
    log INFO "Stopping Application .."
    kill -SIGTERM $1
fi

fi

# Reset. In case you forget to put the this in next script
THIS= ; export THIS
