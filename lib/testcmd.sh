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
 command -v $1 >/dev/null 2>&1 || { cecho "I require $1 but it's not installed.  Aborting." $red; exit 1; }
}

