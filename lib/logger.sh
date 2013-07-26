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

# Syntax : log $TYPE "message to be logged"
# or       log $TYPE "message to be logged" songs_played.lst

log ()
{
 # Store logger status
TMP_LOGGER_STATUS=$DEF_LOGGER_STATUS
 
 if [ "$#" -lt 2 ]
 then
     DEF_LOGGER_STATUS=
 fi

 TYPE=$1
 MSG=$2

# Turn off logger if DEBUG FLAG not set
 if [ "DEBUG" = "$1" -a "$F_DEBUG" != "true" ]
 then
     DEF_LOGGER_STATUS=
 fi

 if [ -z "$3" ]
 then
    OUTFILE=$AVSYS_LOG
 else
    OUTFILE=$3
 fi

  if [ "$DEF_LOGGER_STATUS" = "on" ]
  then
     echo `date` : $THIS : $TYPE : $MSG >> $OUTFILE
  fi
  
# Restore logger status
DEF_LOGGER_STATUS=$TMP_LOGGER_STATUS
}
