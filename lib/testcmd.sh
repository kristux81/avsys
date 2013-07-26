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

# tests if a command exists on shell
testcmd ()
{
 command -v $1 >/dev/null 2>&1 || { cecho "I require $1 but it's not installed.  Aborting." $red; return 1; }
 return 0;
}

# exits application after calling cleanup code and printing message
BAILOUT_ON_FAIL()
 {
  RET=1
  
  while [ "$1" ]
  do

  if [ "$1" = "-cmd" ] 
  then
     CLEANUP=$2
  elif [ "$1" = "-exitcode" ]
  then
     RET=$2
  fi

  shift
  done
 
  if [ "$RET" -ne 0 ]
  then
      $CLEANUP
      cecho "BAILING out :-0 ..." $red
      sleep 1
      exit $RET
  fi
 }
