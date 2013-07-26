#!/bin/sh

# ###########################################################################################
#
#  Script to Generate Parameter Export Script( UNIX ) & Batch files ( WINDOWS ) at Runtime.
#
# Declaring Parameters :        
#                       (1)  PARAM=VALUE
#                       (2)  PARAM = VALUE        
#                       (3)  PARAM= VALUE
#                       (4)  PARAM =VALUE
#
# All the above declaration types are supported for the fix_exp.awk parser
#
# Author : Krishna Singh Chauhan
# Email  : krishnasingh07@gmail.com
#
# Last Fixed on : 
# Version : 
# Public Release : 
#
# ##########################################################################################

DOS2UNIX=dos2unix

gen_config()
{    
    echo "#!/bin/bash" > $1.sh
    echo " "        >> $1.sh
    echo " # This is an Auto Generated Script , Please do not make any modifications !! " >> $1.sh
    echo " "        >> $1.sh

    cat $1 | grep -v '#' | awk NF | awk -f $CFG_PARSER | sed 's/^/export /' > $1.temp
    cat $1.temp     >> $1.sh
  
    echo " "        >> $1.sh
    chmod 755 $1.sh

    rm -f $1.temp &> /dev/null
}

if [ -z "$1" ] ; then
   echo "Usage : gen_exp <inputfiles>"
   exit 1
fi

while [ "$1" ]
do

FILETYPE=`file $1 | grep "CRLF" | wc -l`
if [ "$FILETYPE" -ge "1" ] 
then
    $DOS2UNIX $1
fi

gen_config $1
shift
done

