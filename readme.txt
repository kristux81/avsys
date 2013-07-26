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
unprocessed potential
channels and stations       : etc/radio/channels.lst.not_processed


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
colored echo                : lib/cecho
temporary env scripts       : lib/env_gen.sh
internal diagnostic         : lib/testcmd.sh   
internet radio channel
search                      : lib/update_channels.php
user configuration parser   : lib/cfg_parser.awk
System logger               : lib/logger.sh
time related calculations   : lib/time_stamp.sh


Audio Repository Builder    : sys_build.sh
System Profile              : profile.sh 



