<?php

@require_once($_SERVER["DOCUMENT_ROOT"]."/inc/php_mysql.php");




$sql = "SELECT uid, tstamp, temperature, wind_speed, wind_maxspeed, wind_direction, pressure, humidity FROM weather_merkur2 ORDER BY tstamp DESC LIMIT 100";
$result = mysql_query($sql);







echo "Date\tTime\tAirTemp\tWindspeed\tGusts\tWindDir\tBarometer\tHumidity\r\n";

while ($row = mysql_fetch_assoc($result)) {
    echo $row["tstamp"]."\t";
    echo $row["temperature"]."\t";
    echo $row["wind_speed"]."\t";
	echo $row["wind_maxspeed"]."\t";
	echo $row["wind_direction"]."\t";
	echo $row["pressure"]."\t";
	echo $row["humidity"]."\r\n";
	
	
}



?>




