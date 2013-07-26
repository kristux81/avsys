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

fix_first_0 ()
{
 VALUE=$1
  if [ `echo $VALUE | cut -b 1` = 0 ]
  then
       export $2=${VALUE:1}
  else
      export $2=${1}
  fi
}

get_no_of_leap_years()
{
 CURR_YEAR=$YEAR
 TOTAL_YEARS=$1
 N_LEAP=0

 for (( i=0; i< $TOTAL_YEARS ; i++ ))
 do
    REM=$(((CURR_YEAR++)%4))
    if [ $REM -eq 0 ]
    then
        $((N_LEAP++))
    fi
 done
 
 export N_LEAP
}

# exports wrapped number of YEARDAYS for a file and current YEARDAY.
# It actually adds N*365 or 366 (leap fix) to file's YEARDAYS , where N= current YEAR - file's YEAR
get_wrapped_ydays()
{
if [ -z "$1" ]
then
   echo "No input file provided"
   return 0
fi

 FILE_YEAR=`ls -l $1 --time-style=+%y | awk '{ print $6 }' | grep .`
 fix_first_0 $FILE_YEAR FILE_YEAR

 FILE_YDAYS=`ls -l $1 --time-style=+%j | awk '{ print $6 }' | grep .`
 fix_first_0 $FILE_YDAYS FILE_YDAYS
	
 YEAR=`date +%y`
 fix_first_0 $YEAR YEAR

 YDAYS=`date +%j`
 fix_first_0 $YDAYS YDAYS
	
 if [ $YEAR -gt $FILE_YEAR ]
 then
    # check on year boundary i.e at the time of year change.
    # get diffrenece YDIFF between YEAR and FILE_YEAR
    YDIFF=$((YEAR-FILE_YEAR))
    	    
    get_no_of_leap_years $YDIFF

    # multiply YDIFF with no. of ydays with leap year fix 
    YDIFF=$(((N_LEAP*366)+((YDIFF-N_LEAP)*365)))

    # add this value to FILE_YDYAS
    export FILE_YDAYS=$((FILE_YDAYS+YDIFF))    
fi
}

