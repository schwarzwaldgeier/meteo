<?php
ini_set('display_errors', 1);
@require_once($_SERVER["DOCUMENT_ROOT"]."/inc/php_mysql.php");
$sql = "SELECT uid, tstamp, temperature, wind_speed, wind_maxspeed, wind_direction, pressure FROM weather_merkur2 ORDER BY tstamp DESC LIMIT 1440"; //1440 = 24h
$result = mysql_query($sql);
echo "Date\tTime\tAirTemp\tWindspeed\tGusts\tWindDir\tBarometer\r\n";

while ($row = mysql_fetch_assoc($result)) {
	
	$windspeed_knots = floatval($row["wind_speed"])*0.539957;
	$gust_knots = floatval($row["wind_maxspeed"])*0.539957;
	
    echo date("d.m.Y",$row["tstamp"])."\t"; 
	echo date("H:i",$row["tstamp"])."\t";
	echo $row["temperature"]."\t";
    echo $windspeed_knots."\t";
	echo $gust_knots."\t";
	echo $row["wind_direction"]."\t";
	echo $row["pressure"]."\r\n";
	
}



?>