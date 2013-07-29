# Tell logger your current location
THIS=$0 ; export THIS

# parses mplayer config for key bindings and displays them
parse_config()
{
# requires a definition
log ERROR "parse_config not defined yet. Displaying Defaults"

disp_mplayer_keys_default
}

# mplayer specific default bindings.
disp_mplayer_keys_default()
{
# Shut down default logger for these lines
export DEF_LOGGER_STATUS=off

if [ "$RADIO" = "on" ]
then
       : 
else 
        cecho "############################################################################" $red
	cecho "Seek Forward (10 sec) : " $yellow -n
	cecho "RIGHT       " $green -n
        cecho "Seek Backward (10 sec): " $yellow -n
	cecho "LEFT        " $green
	cecho "Seek Forward (1 min)  : " $yellow -n
	cecho "UP          " $green -n   
	cecho "Seek Backward (1 min) : " $yellow   -n
	cecho "DOWN        " $green	 
	cecho "Seek Forward (10 min) : " $yellow   -n
	cecho "PG-UP       " $green -n   
	cecho "Seek Backward (10 min): " $yellow   -n
	cecho "PG-DOWN     " $green
	cecho "Next Song             : " $yellow   -n
	cecho ">           " $green -n   
	cecho "Previous Song         : " $yellow   -n
	cecho "<           " $green	     
	cecho "Volume UP             : " $yellow   -n
	cecho "*, 0        " $green -n   
	cecho "Volume DOWN           : " $yellow   -n
	cecho "/, 9        " $green	     
	cecho "New PlayList          : " $yellow   -n
	cecho "ESC, q      " $green -n   
	cecho "Play/Pause            : " $yellow   -n
	cecho "SPACEBAR, p " $green
        cecho "############################################################################" $red	
fi

# Start default logger again.
export DEF_LOGGER_STATUS=on
}

disp_mplayer_keys()
{
if [ -f "$PLAYER_LOCAL_CFG" ]
then
    parse_config $PLAYER_LOCAL_CFG
elif [ -f "$PLAYER_GLOBAL_CFG" ]
then
    parse_config $PLAYER_GLOBAL_CFG
else 
    log WARN "Mplayer config Not Found. Using Defaults"
    disp_mplayer_keys_default
fi
}

# Reset. In case you forget to put the this in next script
THIS= ; export THIS
