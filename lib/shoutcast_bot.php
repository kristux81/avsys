<?php

include 'channel_updater_bot.php';

//default station
$BASE_STATION = "http://www.shoutcast.com/radiolist.cfm";
$DEFAULT_STATION = 'hindi';

$URL_FILTER = '?id=' ;
$URI_RESOUREC_LOCATOR = '?action=sub&cat=' ;

echo 'Parsing Stations File : '.$STATION_FILE."\n";
$station_list=file_get_contents($STATION_FILE);

if("false" === $station_list ) {
   echo "Station List Empty. Picking Default Station : ".$DEFAULT_STATION." ..\n";
   $station_list=file_get_contents($BASE_STATION . $URI_RESOUREC_LOCATOR . $DEFAULT_STATION);
}

$stations=explode("\n",$station_list);
if("false" !== $stations ) {

// remove existing channels
   file_put_contents($CHANNEL_FILE, '', LOCK_EX );

   foreach ($stations as $station) {

     if(''==$station)
       continue ;

     update_channels ( $BASE_STATION . $URI_RESOUREC_LOCATOR . $station, $CHANNEL_FILE, $URL_FILTER );
   }
}
