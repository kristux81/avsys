#!/bin/bash

# ******************************************************************
#
# This script lists all media files categorized by their mime types
# ( eg x/audio , x/video , .... etc )
#
# Author : Krishna Singh Chauhan
# Email  : krishnasingh07@gmail.com
#
# Last Fixed on : 22/01/2010
# Version : 1.0
# Public Release : 1.0
#
# ******************************************************************

# load avsys specific environment
. `pwd`/profile.sh

# Tell logger your current location
THIS=$0 ; export THIS

# makedir $AVSYS_DATA if it does not exists.
# Alternative :  [ -d "$AVSYS_DATA" ] ||  mkdir -p $AVSYS_DATA

if [ -d "$AVSYS_DATA" ]
then
   :
else
    mkdir $AVSYS_DATA
fi

log INFO "Directories to be searched for media files are mentioned in File: $SRCHDIRFILE"
log INFO "Directories not to be searched for media files are mentioned in File: $BLOCKED_DIR_LIST"

if [ "$SRCHMODE" = "auto" ]
then

# This script requires a better logic to get search folders
  #$AVSYS_UTIL/guess_srchlst.sh

# this is a temporary fix till then
     echo /home > $SRCHDIRFILE
     echo /media >> $SRCHDIRFILE
     echo /mnt >> $SRCHDIRFILE
else 
 log INFO "Manully Generating Search Directory list.."

# true if file $SRCHDIRFILE exists and has a non zero size
if [ -s "$SRCHDIRFILE" ]
then
    cecho "File : $SRCHDIRFILE already exists " $magenta
    echo Contents of the File=
    echo .
    cat $SRCHDIRFILE
    echo .
    cecho "Sanitizing File : $SRCHDIRFILE" $magenta
    :> $SRCHDIRFILE.tmp
    cat $SRCHDIRFILE | while read line
    do
       find $line > tmp.out 2> tmp.err

       [ -s tmp.err ]
       ERRSTAT=$?

       [ -s tmp.out ]

       if [ "1" = "$?" -a "0" = "$ERRSTAT" ]
       then
            :
       else
           echo $line >> $SRCHDIRFILE.tmp
       fi
    done
    mv $SRCHDIRFILE.tmp $SRCHDIRFILE
else 
    :> $SRCHDIRFILE
fi

# Add / Append diectories entered by user to $SRCHDIRFILE

while :
do
cecho "Please enter absolute path of directory you want to be searched." $yellow
cecho "To quit the loop press q/Q." $yellow
read Dirname

if [ "$Dirname" = "q" -o "$Dirname" = "Q" ]
then
    break
else
    find "$Dirname" > tmp.out 2> tmp.err
    
    [ -s tmp.err ]
    ERRSTAT=$?

    [ -s tmp.out ]

    if [ "1" = "$?" -a "0" = "$ERRSTAT" ]
    then
         cecho "$Dirname Does Not Exist or Permission Denied" $red
         cecho "Ignoring ... $Dirname" $red
    else 
         echo $Dirname >> $SRCHDIRFILE
         cecho "$Dirname added to $SRCHDIRFILE" $green
    fi
fi
done
rm tmp.* 2> /dev/null

cecho "Validating File : $SRCHDIRFILE : " $magenta -n
if [ -s $SRCHDIRFILE ]
then
    cecho "[OK]" $green
else
    cecho "[NOT OK]" $red
    cecho "Switching to Auto Search mode.." $yellow
    $AVSYS_UTIL/guess_srchlst.sh 
fi

fi

# sed -n '$=' emulates 'wc -l' i.e count number of lines
N_SRCH_DIR=`sed -n '$=' $SRCHDIRFILE` ; export N_SRCH_DIR

# ---------------------------------------------------------------
# Build Cache on the basis of search directory and file mime type
# ---------------------------------------------------------------

BUILD_CACHE ()
{
  cecho "STARTING SEARCH PROCESSES ON THE BASIS OF NUMBER OF SEARCH DIRECTORIES IN :" $yellow
  cecho "$SRCHDIRFILE" $green
  echo " "

 for (( thread=1 ; thread <= N_SRCH_DIR ; thread ++ ))
 do
 
CURRENT_DIR=`cat -n $SRCHDIRFILE | sed 's/^[ \t]*//;s/[ \t]*$//' | grep ^$thread | head -1 | sed 's/^[0-9]*//' | sed 's/^[ \t]*//'`

# Start a background job only if input string SRCH_DIR# is non-empty

if [ -n "$CURRENT_DIR" ]
then
 
 cecho "Now Searching in : " $magenta -n
 cecho "$CURRENT_DIR" $green

 nohup find  "$CURRENT_DIR"                        \
             -type f                             \
             -size +$1                            \
             -exec file -i -F " $Delim " {} \;   \
             >> $AVSYS_DATA/temp_$thread        \
             2> /dev/null &

# $! returns PID of Last Job Started in background.
# save these pids per background job into an array.
else 
    cecho "WARNING : Empty line found in $SRCHDIRFILE" $red
    log WARN "Empty line found in $SRCHDIRFILE"
fi

_PID[$thread]=$!

if [ "$F_DEBUG" = "true" ]
then
    echo THREAD_PID[$thread] = ${_PID[$thread]}
    log DEBUG "THREAD_PID[$thread] = ${_PID[$thread]}"
fi
echo " "

done

#rm $SRCHDIRFILE.sh

 cecho "THIS MAY TAKE SOME MINUTES DEPENDING UPON FILESYSTEM SIZE AND NUMBER OF SEARCH" $yellow
 cecho "DIRECTORIES. IT IS A ONE TIME TASK UNLESS $AVSYS_DATA" $yellow
 cecho "IS EMPTY OR TOO OLD AS PER AUTO_SYS_BUILD RULE CONFIGURED IN CONFIGURATION FILE" $yellow
 cecho "Please Wait" $red
 echo " "

# sense status of these background jobs and when all of
# these are complete , exit loop.

#initialize a status array assuming that all the background
#jobs are initially alive.

# hold status of jobs in an array.
# initilaize it first.

for (( i = 1 ; i <= N_SRCH_DIR ; i++ ))
do
    thread_status[$i]=1
done


# loop untill all background jobs are finished.
# : ==> Nop ( No operation )

while :
do

for (( thread = 1 ; thread <= N_SRCH_DIR ; thread ++ ))
 do

# show user that you are still alive
printf "|"

# hold on for some time
sleep 1

#if [[ "${thread_status[${thread}]}" == "1" ]]
if [ "${thread_status[${thread}]}" -eq 1 ]
then

# display all processes by their PID  
# filter only PID column
# select and search exact PID of last background job in PID column
# Regular Expressions ( ^ , $ ) ==> ( ^ = begining at ), ( $=ending at )
# sed 'exp' is to filter out any no. of occurences of leading/trailing spaces/tabs
# 'sed -n '$='' emulates 'wc -l' i.e count number of lines

 STAT=\
`ps -e | awk '{print $1}' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep "^${_PID[${thread}]}$" | sed -n '$='`

if [ "$STAT" = "1" ]
then
     thread_status[$thread]=1

     if [ "$F_DEBUG" = "true" ]
     then
        echo -n PID : ${_PID[$thread]}  STATUS : 
        cecho " Running" $green
        log DEBUG "PID : ${_PID[$thread]}  STATUS : Running"
     fi

else thread_status[$thread]=0

     if [ "$F_DEBUG" = "true" ]
     then
        echo -n PID : ${_PID[$thread]}  STATUS : 
        cecho " Stopped" $red
        log DEBUG "PID : ${_PID[$thread]}  STATUS : Stopped"
     fi

fi

fi

done

declare -i runstat=${thread_status[1]}

 for (( thread = 2 ; thread <= N_SRCH_DIR ; thread ++ ))
 do
 runstat=`expr $runstat + ${thread_status[$thread]}`
 done

#[[ $runstat == 0 ]] && break
if [ "$runstat" -eq 0 ]
then
    break
fi
done
}


# -------------------------------------
# Merge all temporary files to one file
# -------------------------------------

MERGE_ALL()
{
if [ "$N_SRCH_DIR" -gt 1 ]
then
	 # touch a file if it already exists , truncate it 
	:> $AVSYS_DATA/temp

	for line in `ls $AVSYS_DATA/temp_*` ;
	do
	  cat $line >> $AVSYS_DATA/temp
	done
else
	mv $AVSYS_DATA/temp_1 $AVSYS_DATA/temp
fi
}


# ---------------------------------------------------------
# Generate list on the basis of formats ( file mime types )
# ---------------------------------------------------------

LIST ()
{
# This filter must be tested -- may give hickups on some machines -- 14/05/11
 cat $AVSYS_DATA/temp | grep "$2 $Delim  $1/" > $AVSYS_DATA/temp_$1

 echo " "
 cecho "Searching for media files ... " $yellow -n
 log DEBUG "Searching for media files ... [$1]"
 cecho "[$1]" $green
 echo " "

if [ -s "$AVSYS_DATA/temp_$1" ]
then 

   cecho "Now writing file : " $yellow -n

# Quick fix for left out songs
if [ -z "$3" ]
then 
   log DEBUG "Now writing file : $1.lst"
   cecho "$1.lst" $blue
   cut -d $Delim -f 1 $AVSYS_DATA/temp_$1 > $AVSYS_DATA/$1.lst
else 
   log DEBUG "Now writing file : $3.lst"
   cecho "$3.lst" $blue
    cut -d $Delim -f 1 $AVSYS_DATA/temp_$1 >> $AVSYS_DATA/$3.lst
fi

else 
    cecho "No media found with format = $1 on this machine" $red
    log ERROR "No media found with format = $1 on this machine"
    rm $AVSYS_DATA/temp_$1
fi
}

# ------------------------------------------------------------------
#                            Begin Program
# ------------------------------------------------------------------

# 1. Clean cache 

cecho "Cleaning Cache .." $magenta
rm -rf $AVSYS_DATA/*

# 2. Cache all files with their mime definition in temporary files.

BUILD_CACHE $MIN_FILE_SIZE

# 3. Merge all temporary files 

MERGE_ALL

# 4. Build lists classified by file mime types

for line1 in `ls $AVSYS_CFG/fmt` ;
do
	echo " "
	cecho "Reading Format file : $line1" $magenta
        log DEBUG "Reading Format file : $line1"
	for line in `cat $AVSYS_CFG/fmt/$line1`;
	do
	echo " "
	cecho "Building $line Repository .." $magenta
        log DEBUG "Building $line Repository .."
	echo " "
	LIST $line ;
	done
done

# For files that are mp3 but seens as "application/octet-stream"
LIST application .mp3 audio

cecho "[DONE]" $green

# Reset. In case you forget to put the this in next script
THIS= ; export THIS

