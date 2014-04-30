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

# please do not modify untill you know what you are doing
AVSYS_ROOT=`pwd` ; export AVSYS_ROOT
AVSYS_LISTS=$AVSYS_ROOT/playlists ; export AVSYS_LISTS
AVSYS_LIB=$AVSYS_ROOT/lib ; export AVSYS_LIB
AVSYS_CFG=$AVSYS_ROOT/etc ; export AVSYS_CFG
AVSYS_UTIL=$AVSYS_ROOT/util ; export AVSYS_UTIL
AVSYS_LOG_ROOT=$AVSYS_ROOT/logs ; export AVSYS_LOG_ROOT
AVSYS_TMP=$AVSYS_ROOT/tmp ; export AVSYS_TMP
AVSYS_STATIONS=$AVSYS_CFG/radio/stations.lst ; export AVSYS_STATIONS
AVSYS_CHANNELS=$AVSYS_CFG/radio/channels.lst ; export AVSYS_CHANNELS

mkdir $AVSYS_LOG_ROOT 2> /dev/null
mkdir $AVSYS_TMP 2> /dev/null

# use coloured echo stmts for console and log them to a default log file
. $AVSYS_LIB/cecho

# registering testcmd into avsys.
. $AVSYS_LIB/testcmd.sh 

# AVSYS TIMESTAMP RELATED OPERATIONS
. $AVSYS_LIB/time_stamp.sh

# AVSYS ACTIVITY LOGGER
AVSYS_LOG=$AVSYS_LOG_ROOT/avsys.log ; export AVSYS_LOG 
DEF_LOGGER_STATUS=on ; export DEF_LOGGER_STATUS
. $AVSYS_LIB/logger.sh

# set AVSYS_DATA as per requirement here
AVSYS_DATA=/home/`whoami`/.avsys ; export AVSYS_DATA

# list of searchable directories goes in this file
SRCHDIRFILE=$AVSYS_CFG/srchdir.lst ; export SRCHDIRFILE

# Audio Repository File
MP3_FILE=audio.lst ; export MP3_FILE

# Filename and FileFormat Seperator
Delim=% ; export Delim

# AVSYS MODULES	CONFIGURATION

# LINE FILTER module
LINE_FILTER=$AVSYS_LIB/trim_line.awk ; export LINE_FILTER

# CFG PARSER module
CFG_PARSER=$AVSYS_LIB/cfg_parser.awk ; export CFG_PARSER

# AVSYS ENVIRONMENT GENERATOR
ENV_GEN=$AVSYS_LIB/env_gen.sh ; export ENV_GEN

# AVSYS USER CONFIGURATION FILE
USR_CONFIG_FILE=$AVSYS_CFG/configuration.cfg ; export USR_CONFIG_FILE

 # Set User Specific Settings
$ENV_GEN $USR_CONFIG_FILE
. $USR_CONFIG_FILE.sh
rm $USR_CONFIG_FILE.sh

# Assume defaults if environment variables are not set
 
if [ -z "$PLAYFILE" ]
then
    PLAYFILE=default.lst ; export PLAYFILE
fi

if [ -z "$MIN_FILE_SIZE" ]
then
    MIN_FILE_SIZE=512k ; export MIN_FILE_SIZE
fi

if [ -z "$BLOCKED_DIR_LIST" ]
then
    BLOCKED_DIR_LIST=blocked_dir.lst ; export BLOCKED_DIR_LIST
fi

if [ -z "$PLAYER" ]
then
    PLAYER=mplayer ; export PLAYER
fi

if [ -z "$PLAYER_OPTS" ]
then
    PLAYER_OPTS=playlist ; export PLAYER_OPTS
fi

if [ -z "$PLAYER_VERBOSE" ]
then
    PLAYER_VERBOSE=OFF ; export PLAYER_VERBOSE
fi

if [ -z "$F_DEBUG" ]
then
     F_DEBUG=false ; export F_DEBUG
fi

if [ -z "$RANDOMIZER" ]
then
     RANDOMIZER=1 ; export RANDOMIZER
fi

# Analyze value of "auto_sys_build_after_days" and if found out-of-range ( 0-365 ),
# take default value ( 30 )

if [ $auto_sys_build_after_days -lt 0 -o $auto_sys_build_after_days -gt 365 ]
then
     auto_sys_build_after_days=30 ; export auto_sys_build_after_days
fi

if [ "$PLAYER" = "mplayer" ]
then
    PLAYER_LOCAL_CFG=~/.mplayer/config ; export PLAYER_LOCAL_CFG
    PLAYER_GLOBAL_CFG=/etc/mplayer/mplayer.conf ; export PLAYER_GLOBAL_CFG
   . $AVSYS_UTIL/disp_mplayer_keybindings.sh
fi

PLAYER_ERR_LOGS=$AVSYS_LOG_ROOT/$PLAYER.err ; export PLAYER_ERR_LOGS


