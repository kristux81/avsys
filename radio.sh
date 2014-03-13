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

# check PHP on commandline exit if not available.
. `pwd`/profile.sh

testcmd php

php $AVSYS_LIB/shoutcast_bot.php

if [ $? = 1 ]; then
   cecho "Shutting Down .... Retry Later." $red
   exit 1
fi

N_CHANNELS=`wc -l $AVSYS_CHANNELS | awk '{print $1}'`
cecho "Number of channels found : $N_CHANNELS" $yellow -n

# Passing a 0 as arg means you want to listen to internet radio.
# make sure you have added stations to ./etc/radio/stations.lst

`pwd`/play.sh 0
