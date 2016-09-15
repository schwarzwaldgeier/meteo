<?php
$anzkomplett = 0;
@require_once($_SERVER["DOCUMENT_ROOT"]."/inc/php_mysql.php");



function data_avg($mins) {

    	$query = "SELECT uid, tstamp, temperature, wind_speed, wind_maxspeed, wind_direction, pressure, humidity FROM weather_merkur2 WHERE tstamp > $mytime";
    	
}





echo 'Date \t Time \t AirTemp \t MaxTemp \t Windspeed \t Gusts \t WindDir \t Barometer \t Humidity\r\n';




?>




