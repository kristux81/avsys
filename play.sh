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
# Arg Values  : $1 =   => player Loop Mode
#               $1 = 0 => Radio Loop Mode
#               $1 > 0 => Player Interactive Mode       
#
# ******************************************************************

. `pwd`/profile.sh
TIMER_PIDFILE=$AVSYS_ROOT/.timer.pid ; export TIMER_PIDFILE

# Tell logger your current location
THIS=$0 ; export THIS

sighandle ()
{
cecho "Stop Signal Recieved. Stopping Player..." $red
rm $TIMER_PIDFILE 2> /dev/null
exit 0
}

trap sighandle SIGTERM

# Matching substring "mplayer" from $PLAYER
# ( in case absolute path of mplayer is mentioned )
    MPLAYER=${PLAYER: -7}

# Set default number of songs in playlist
N_SONGS=15

# ----------- RADIO LOOP MODE ( N_SONGS = 0 ) ---------
if [ "0" = "$1" ]
then
     N_SONGS=0
     RADIO=on ; export RADIO
     log DEBUG "RADIO TURNED ON"
fi
# -----------------------------------------------------
 
# generate a new default playlist      
$AVSYS_UTIL/gen_random_playlist.sh $PLAYFILE $N_SONGS

if [ -f "$AVSYS_LISTS/$PLAYFILE" ]
then
     #cecho "PLAYLIST FILE : " $yellow -n
     #cecho " $AVSYS_LISTS/$PLAYFILE" $green
     #echo " "
     :
else cecho "NO PLAYLIST : $AVSYS_LISTS/$PLAYFILE FOUND" $red 
     cecho "Perhaps you should rebuild the audio repository." $red
     sleep 4
     exit 1
fi

Quit()
{
 echo " "
 cecho "SEE YA SOON " $green
 echo " "
 exit $1
}

displist()
{
cecho "[PLAYLIST] : " $green
cat -n $AVSYS_LISTS/$PLAYFILE
echo " "
}

# Reaching here will make you listen to your playlists.

if [ -z "$INTERACT" ]
then

# test availability of $PLAYER on shell, Bail out if not available.
    testcmd $PLAYER

    if [ "on" = "$RADIO" ]
    then
	 echo " "
	 cecho "In order to Switch Channel : " $yellow   -n
	 cecho "Press ^C       " $green
	 echo " "
    fi

# display list before playing songs
    displist

MSG_LEVEL=
# display mplayer specific key operations
    if [ "$MPLAYER" = "mplayer" ]
    then
      disp_mplayer_keys
       
       if [ "$PLAYER_VERBOSE" = "FULL" ]
       then
           MSG_LEVEL=$(echo "-msglevel all=5")

       elif [ "$PLAYER_VERBOSE" = "ON" ] 
       then
           MSG_LEVEL=$(echo "-msglevel all=4")

       elif [ "$PLAYER_VERBOSE" = "OFF" ]
       then
           MSG_LEVEL=$(echo "-msglevel all=3")
       fi

       if [ "on" = "$RADIO" ]
       then
            MSG_LEVEL=$(echo "-msglevel all=4")
       fi

    fi

# start auto stopper as a background process only once ( if not already started )
# in accordance to < exec $0 > command below. exec $0 intends to start replace 
# the current running process by itself. in short it intends to restart this script
# from begining. In the process it starts a new child instance of player. As per the
# sequential calls as soon as the foregrounf child process exits the script restarts
# itself to again create a new child. In order to avoid multiple simultaneous stop_timer
# childs from running, timer processes pid is dumped in a file and a check is made 
# prior to starting a stop_timer.

if [ -s "$TIMER_PIDFILE" ]
then
       # get time of creation of .timer.pid and subtract that value from current time
       # now subtract the result from $AUTO_STOP_TIME ,
       # this is the time player will be running

       AUTO_STOP_TIME_SEC=$((AUTO_STOP_TIME*60))
       FILE_SEC=`ls -l $TIMER_PIDFILE --time-style=+%s | awk '{ print $6 }' | grep .`
       SEC=`date +%s`

       TIME_REMAIN=$((SEC-FILE_SEC))
       cecho "AutoStopper is running for past $TIME_REMAIN seconds" $yellow
       log DEBUG "AutoStopper is running for past $TIME_REMAIN seconds"

       TIME_REMAIN=$((AUTO_STOP_TIME_SEC-TIME_REMAIN))
       cecho "Player will run for next $TIME_REMAIN seconds" $yellow
       log INFO "Player will run for next $TIME_REMAIN seconds"

else
    if [ $AUTO_STOP_TIME -ge 1 ]
    then
    	cecho "Starting Auto Stop Timer with STOP TIME = $AUTO_STOP_TIME minutes" $yellow
    	log INFO "Starting Auto Stop Timer with STOP TIME = $AUTO_STOP_TIME minutes"
      	$AVSYS_UTIL/auto_stopper.sh $$ &
       	echo $! > $TIMER_PIDFILE
    fi
fi

# call your custom player to do the job ( this is a forground process and will hold the console.)
if [ "on" = "$RADIO" ]
then
    CHANNEL=`head -1 $AVSYS_LISTS/$PLAYFILE | tr '\n' ' '`
    $PLAYER $MSG_LEVEL -$PLAYER_OPTS $CHANNEL 2> $PLAYER_ERR_LOGS \
    | grep -wi --color 'Name\|Genre\|Website'

else
    $PLAYER $MSG_LEVEL -$PLAYER_OPTS $AVSYS_LISTS/$PLAYFILE 2> $PLAYER_ERR_LOGS
fi
 
# this is intentionally put to give 1 second wait before starting a new player instance
# i.e. new child prcess since monitoring process may be interested in stopping child
# i.e current instance of player, first. The parent has the tendency of starting a new 
# child ( player instance ). This wait allows monitoring process to stop parent before
# it starts new child. This helps in avoiding any orphan processes being left for the init.

cecho "Refreshing Playlist..." $yellow
sleep 1

# restarts this script again from start. ( never ending mode )
# exec replaces current process image with target process image in the 
# memory keeping pid constant.

# ------- LOOP MODE : RADIO & PLAYER ( based on value of $N_SONGS ) -----

if [ "on" = "$RADIO" ]
then
     exec $0 "0"
else 
     exec $0
fi

# ---------------- RADIO INTERACTIVE MODE --------------
elif [ "on" = "$RADIO" ]
then

# maximum "no of channels" in channel.lst
MAX=`wc -l $AVSYS_CHANNELS | awk '{print $1}'`

# loop forever ( while : ) or use ( while test 1 ) or ( while [ 1 ] )
while :
do

cat -n $AVSYS_CHANNELS

# display mplayer specific key operations
    if [ "$MPLAYER" = "mplayer" ]
    then
      disp_mplayer_keys
      
       if [ "on" = "$RADIO" ]
       then
            MSG_LEVEL=$(echo "-msglevel all=4")
       fi
    fi

cecho "enter the selection number to play " $cyan
cecho "or 'q' to quit application : " $cyan
read num

case "$num" in
q) 
 Quit 0 ;
;;
Q) 
 Quit 0 ;
;;
*)

# if both expressions are true ( -a = and ) 
# alternative: 	 if [[ "$num" -le "$MAX" && "$num" -ge "0" ]]

if [ $num -le $MAX -a $num -ge 0 ]
then
     SELECTION="`cat -n $AVSYS_CHANNELS | sed 's/^[ \t]*//;s/[ \t]*$//' | grep ^$num \
          | head -1 | sed 's/^[0-9 \t]*//'  2> $PLAYER_ERR_LOGS`"

     echo $SELECTION
     $PLAYER $MSG_LEVEL -$PLAYER_OPTS $SELECTION 2> $PLAYER_ERR_LOGS \
        | grep -wi --color 'Name\|Genre\|Website'
else 
    echo "Selected Number is INVALID !!"
fi;
;;
esac
done 

# ---------------- PLAYER INTERACTIVE MODE --------------
else
    
# maximum "no of songs" in playlist file
MAX=`wc -l $AVSYS_LISTS/$PLAYFILE | awk '{print $1}'`

# loop forever ( while : ) or use ( while test 1 ) or ( while [ 1 ] )
while :
do
     displist

# display mplayer specific key operations
    if [ "$MPLAYER" = "mplayer" ]
    then
      disp_mplayer_keys
       
       if [ "$PLAYER_VERBOSE" = "FULL" ]
       then
           MSG_LEVEL=$(echo "-msglevel all=5")

       elif [ "$PLAYER_VERBOSE" = "ON" ] 
       then
           MSG_LEVEL=$(echo "-msglevel all=4")

       elif [ "$PLAYER_VERBOSE" = "OFF" ]
       then
           MSG_LEVEL=$(echo "-msglevel all=3")
       fi

    fi

cecho "enter the selection number to play " $cyan
cecho "or 'r' to reload random list " $cyan 
cecho "or 'q' to quit application : " $cyan
read num

case "$num" in
q) 
 Quit 0 ;
;;
Q) 
 Quit 0 ;
;;
r)
  $AVSYS_UTIL/gen_random_playlist.sh $PLAYFILE $N_SONGS
;;
R)
  $AVSYS_UTIL/gen_random_playlist.sh $PLAYFILE $N_SONGS
;;
*)

# if both expressions are true ( -a = and ) 
# alternative: 	 if [[ "$num" -le "$MAX" && "$num" -ge "0" ]]

if [ $num -le $MAX -a $num -ge 0 ]
then
     SELECTION="`cat -n $AVSYS_LISTS/$PLAYFILE | sed 's/^[ \t]*//;s/[ \t]*$//' | grep ^$num \
          | head -1 | sed 's/^[0-9 \t]*//'  2> $PLAYER_ERR_LOGS`"
 
     echo $SELECTION
     $PLAYER $MSG_LEVEL "$SELECTION"  2> $PLAYER_ERR_LOGS
else 
    echo "Selected Number is INVALID !!"
fi;
;;
esac
done
fi
