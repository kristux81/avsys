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

# returns a random number
getRandom()
{
 #initialize
 num=0
 FLOOR=0
 RANGE=$1
 
 while [ "$num" -le $FLOOR ]
 do

 # $RANDOM returns a unique random number generated by systems random number generator.
 # but since we are not modifying the seed for random no. generator so all the new
 # subshells created will have the same starting value of $RANDOM.
 num=$RANDOM

 # inorder to provide different starting values of "num" we add pid of the subshell to
 # "num" to generate unique values within the same session of play.
 num=$((num+$$))

 # Scales $num down within $RANGE.
 let num=num%$RANGE
 
 done
 
 log DEBUG "$num"
 return $num
}

# returns a number next in sequence
getNext()
{
 RANGE=$1
 
 if [ -z "$AVSYS_DATA/lastplayed"]
 then 
      num=1 # initialize
 else 
      num=`cat $AVSYS_DATA/lastplayed`
	  if [ "$num" = $RANGE ]
	  then
	       num=0 # re-initialize
	  fi
	  
      let num=num+1
fi

# save last number	  
echo $num > $AVSYS_DATA/lastplayed

return $num
}



if [ -z "$1" ]
then
	echo "USAGE :"
	cecho "$0" $green -n
	cecho "  <name of playlist file>  <no of files in the playlist>" $yellow
	echo " "
else 
	PLAYFILE=$1
fi

if (( "0" < "$2" || "0" == "$2" ))
then
     N_FILES=$2
else N_FILES=20
fi

# NON RADIO MODE
if (( "0" < "$N_FILES" ))
then
     F_BUILD=0
     echo " "

 if [ -d "$AVSYS_DATA" ]
 then
     if [ -s "$AVSYS_DATA/$MP3_FILE" ]
     then
        get_wrapped_ydays $AVSYS_DATA/$MP3_FILE

        DIFF=$((FILE_YDAYS-YDAYS))
        if [ $FILE_YDAYS -lt $YDAYS ]
        then
           DIFF=$((DIFF*(-1)))
        fi

        if [ $FILE_YDAYS -ne $YDAYS ]
        then     
	      if [ $DIFF -ge $auto_sys_build_after_days ]
              then 
	          F_BUILD=1
	          cecho "Existing Repository is Too old as per parameter 'auto_sys_build_after_days'" $red
                  log WARN "Existing Repository is Too old as per parameter 'auto_sys_build_after_days'"
	      else
		  log WARN "Number of Days Remaining to Auto Regenerate new Repository = $DIFF"
	      fi
	 else
	      cecho "Existing Repository Found OK" $green
              log DEBUG "Existing Repository Found OK"
	 fi
     else  
         F_BUILD=1
         cecho "No repository found." $red
         log WARN "No repository found."
	 cecho "Building Audio Repository First..." $green
         log INFO "Building Audio Repository First..."
     fi
else  
     F_BUILD=1
     cecho "No repository found." $red
     log WARN "No repository found."
     cecho "Building Audio Repository First..." $green
     log INFO "Building Audio Repository First..."
fi

if [ $auto_sys_build_after_days -eq 0 ]
then
       F_BUILD=1
fi

if [ $F_BUILD -eq 1 ]
then
	$AVSYS_ROOT/sys_build.sh
	echo " "
fi

fi

mkdir $AVSYS_LISTS 2> /dev/null

if [ "on" = "$RADIO" ]
then
     RESOURCE=$AVSYS_CHANNELS
     N_FILES=1
     cecho "Randomly selecting a radio Channel from Channel List : $AVSYS_CHANNELS .." $cyan
     log INFO "Randomly selecting a radio Channel from Channel List : $AVSYS_CHANNELS .."
else
     RESOURCE=$AVSYS_DATA/$MP3_FILE
     cecho "Preparing a random audio playlist from audio repository .." $cyan
     log INFO "Preparing a random audio playlist from audio repository .."
     cecho "$AVSYS_LISTS/$PLAYFILE" $blue
fi

RANGE=`wc -l $RESOURCE | awk '{print $1}'`
log DEBUG "MAX SONGS or STATIONS = $RANGE"

if [ "1" = "$RANGE" ]
then
    cp $RESOURCE $AVSYS_LISTS/$PLAYFILE
	
else

# discard old playlist
:> $AVSYS_LISTS/$PLAYFILE &> /dev/null

log DEBUG "Invoking Randomizer, List Follows"

COUNTER=0
while [  $COUNTER -lt $N_FILES ]
do
    if [ "0" = "$RANDOMIZER" ]
	then
	    num=`getNext $RANGE`
	else
	    num=`getRandom $RANGE`
	fi 
	
	cat -n $RESOURCE | sed 's/^[ \t]*//;s/[ \t]*$//' | grep ^$num | head -1 | sed 's/^[0-9 \t]*//' >> $AVSYS_LISTS/$PLAYFILE
	let COUNTER=COUNTER+1 
done
fi

cp $AVSYS_LISTS/$PLAYFILE $AVSYS_LISTS/playlist-`date "+%Y-%m-%d_%H-%M"`.lst

MODE=PLAYER
if [ "on" = "$RADIO" ]
then
    MODE=RADIO
fi

cecho "############################### AVSYS $MODE ###############################" $green

# Reset. In case you forget to put the this in next script
THIS= ; export THIS
