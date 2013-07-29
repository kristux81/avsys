<?php

//input file
$STATION_FILE=getenv('AVSYS_STATIONS');

//output file
$CHANNEL_FILE=getenv('AVSYS_CHANNELS');

//log file
$LOG_FILE=getenv('AVSYS_LOG_ROOT');

//default station
$DEFAULT_STATION="http://www.shoutcast.com";


function get_all_urls ( $string )
{
  $PATTERN='/<a[^>]+href\s*=\s*["\'](?!(?:#|javascript\s*:))([^"\']+)[^>]*>(.*?)<\/a>/si';

  if ( preg_match_all( $PATTERN, $string, $links ) )  {   
    return array_unique( $links[1] );
   }
   else {
         return false;
        }
}

function update_channels ( $station, $CHANNEL_FILE )
{
 static $loop_count=0;
 global $LOG_FILE;

 echo 'Obtaining Channels From Station : '.$station."\n";

	set_error_handler(
	    create_function(
		'$severity, $message, $file, $line',
		'throw new ErrorException($message, $severity, $severity, $file, $line);'
	    )
	);
 
   try {
        $channel_list=file_get_contents($station);
   }
   catch (Exception $e)
   {
     echo "Failed to obtain Channels from Station : $station \n";
     echo "Check your Internet Connection \n";

     $errMsg = 'Failed to obtain Channels from Station : ' . $station . "\n"
              . $e->getFile() . ' : ' . $e->getLine() . ' : ' . $e->getMessage() . "\n";

     file_put_contents( $LOG_FILE . '/radio_statup_fail.log', $errMsg);  

     exit(1);
   }
 
 if("false" !== $channel_list ) {
    $channels = get_all_urls($channel_list);

    // var_dump($channels);
    
    if(is_array($channels)){
       foreach ($channels as $channel) {

          $url = parse_url($channel);
          if(is_array($url) && in_array("http", $url)) {

           // var_dump($url);
           $pos = strrpos($channel, "?id=");

           if ($pos === false){
 
            // recursive logic not working : 14/10/2012
            // update_channels ( $channel, $CHANNEL_FILE.'.'.$loop_count );

            // can be a possible channel or station ; dump to a file for manual inspection
             file_put_contents($CHANNEL_FILE.'.not_processed', $channel."\n", FILE_APPEND | LOCK_EX );                
             continue ;
           }

           file_put_contents($CHANNEL_FILE, $channel."\n", FILE_APPEND | LOCK_EX );
          }          
       }
    }
 }
 elseif (!isset($station)) {
       echo "No channels found on station : ".$station." Skipping ..\n";
 }
}




// --- Program starts here ---
echo 'Parsing Stations File : '.$STATION_FILE."\n";
$station_list=file_get_contents($STATION_FILE);

if("false" === $station_list ) {
   echo "Station List Empty. Picking Default Station :".$DEFAULT_STATION." ..\n";
   $station_list=file_get_contents($DEFAULT_STATION);
}

$stations=explode("\n",$station_list);
if("false" !== $stations ) {

// remove existing channels
   file_put_contents($CHANNEL_FILE, '', LOCK_EX );

   foreach ($stations as $station) {

     if(''==$station)
       continue ;

     update_channels ( $station, $CHANNEL_FILE );
   }
}
