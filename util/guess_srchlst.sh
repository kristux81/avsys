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

TMP_FILE=$SRCHDIRFILE.tmp

# clean old context 
:> $SRCHDIRFILE

mount | awk '{ print $3 }' | grep -v proc | grep -v boot | grep -v swap | grep -v dev | grep -v sys | grep -v var | grep -v run > $TMP_FILE

for line in `cat $TMP_FILE`
do
# remove "/" ( root ) from output file
# Alternative :  [[ "$line" = "/" ]] || echo $line >> $TMP_FILE

if [ "$line" = "/" ] ; then
    :
else 
    echo $line >> $SRCHDIRFILE
fi

done

# add /home if not already available.
# on log volume based file systems this script may not yield any partition from HDD.
# thus a default /home is added.

HASHOME=`cat $TMP_FILE | grep /home | wc -l | sed 's/^[ \t]*//;s/[ \t]*$//'`

# Alternative : [[ "$HASHOME" = "0" ]] && echo /home/`whoami` >> $SRCHDIRFILE

if [ "$HASHOME" = "0" ]
then
    echo /home/`whoami` >> $SRCHDIRFILE

 #uncomment the line below if insist in not respecting others privacy
 # echo /home >> $SRCHDIRFILE

fi

cp $SRCHDIRFILE $TMP_FILE

for line1 in `cat $AVSYS_CFG/$BLOCKED_DIR_LIST`
do
  for line2 in `cat $TMP_FILE`
  do
    if [ "$line1" = "$line2" ]
    then 
        :
    else 
        echo $line2 >> loop.tmp
    fi
  done
mv loop.tmp $TMP_FILE
done

log DEBUG "Automatically Generating Search Directory List. For Details See File: $SRCHDIRFILE" 
mv $TMP_FILE $SRCHDIRFILE

# Reset. In case you forget to put the this in next script
THIS= ; export THIS

