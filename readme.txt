FRONTEND
--------

Audio Player Loop Mode      : play.sh
Audio Player Select Mode    : play_selector.sh
Internet Radio Loop Mode    : radio.sh
Internet Radio Select Mode  : radio_selector.sh


CONFIGURATION
-------------
User Configuration settings : etc/configuration.cfg
Directories not to be
scanned while repository
build process               : blocked_dir.lst
Generic Formats for the 
player                      : etc/fmt/formats.fmt
Radio Stations list         : etc/radio/stations.lst


INTERMEDIATE FILES & FOLDERS 
----------------------------
current playlist and history: playlists/*
logs                        : logs/*
repository roots guessed
during repository build     : etc/srchdir.lst
radio channel list built
while scanning stations     : etc/radio/channels.lst


BACKEND
-------

Utitilies :
-----------
Auto Stop Timer             : util/auto_stopper.sh
Random Playlist Generator   : util/gen_random_playlist.sh
Display Mplayer Control Keys: util/disp_mplayer_keybindings.sh
Guess Root directories 
while rep. build            : util/guess_srchlst.sh

Library :
---------

System Profile              : profile.sh
colored echo                : lib/cecho
internal diagnostic         : lib/testcmd.sh 
System logger               : lib/logger.sh
time related calculations   : lib/time_stamp.sh

temporary env scripts       : lib/env_gen.sh  
user configuration parser   : lib/cfg_parser.awk

Generic internet radio
channel search bot          : lib/channel_updater_bot.php
Shoutcast radio station bot : lib/shoutcast_bot.php

Audio Repository Builder    : sys_build.sh

