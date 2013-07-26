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

PHP_STATUS=`testcmd php`
if [ "1" = "$PLAYER_STATUS" ]
then
    BAILOUT_ON_FAIL -exitcode 90
fi

php $AVSYS_LIB/update_channels.php

N_CHANNELS=`wc -l $AVSYS_CHANNELS | awk '{print $1}'`
cecho "Number of channels found : $N_CHANNELS" $yellow -n

# Passing a 0 as arg means you want to listen to internet radio.
# make sure you have added stations to ./etc/radio/stations.lst

`pwd`/play.sh 0
