<?php
$anzkomplett = 0;
@require_once($_SERVER["DOCUMENT_ROOT"]."/inc/php_mysql.php");


function data_now() {
		$ws = 0;
		$wd = 0;
    	$query = "SELECT wind_speed,wind_direction,tstamp from weather_merkur order by uid desc limit 1";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$x = $anzkomplett - 1;
    	for ($i=0; $i < $anzkomplett; $i++) {
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);
			$wd = $array["wind_direction"];
    		$ws = $array["wind_speed"];
    		$xs = $array["tstamp"];
    	}
		return "$ws,$wd,$xs";
}
function data_avg($mins) {
		$ws = 0;
		$wd_u = 0;
		$wd_v = 0;
		$wd_w = 0;
    	$mytime = time() - $mins * 60;
    	#$query = "SELECT avg(wind_speed) as wind_speed,avg(wind_direction) as wind_direction from weather_merkur where tstamp > $mytime limit 1";
    	$query = "SELECT wind_speed, wind_direction from weather_merkur where tstamp > $mytime";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$x = $anzkomplett - 1;
    	for ($i=0; $i < $anzkomplett; $i++) {
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);
			$wd_u += sin(round($array["wind_direction"],0) * M_PI / 180);
			$wd_v += cos(round($array["wind_direction"],0) * M_PI / 180);
    		$ws += round($array["wind_speed"],0);
    	}

	    $wd_u = $wd_u / $anzkomplett;
	    $wd_v = $wd_v / $anzkomplett;
	    $wd_w = atan2(abs($wd_u),abs($wd_v)) * 180 / M_PI;

	    if ( ($wd_u >= 0) && ($wd_v >= 0) ) {
	    	$wd_w = $wd_w;
	    }
	    if ( ($wd_u >= 0) && ($wd_v < 0)  ) {
	    	$wd_w = 180 - $wd_w;
	    }
	    if ( ($wd_u < 0) && ($wd_v >= 0)  ) {
	    	$wd_w = 360 - $wd_w;
	    }
	    if ( ($wd_u < 0) && ($wd_v < 0)   ) {
	    	$wd_w = 180 + $wd_w;
	    }
	    $wd_w = round($wd_w,0);

	    $ws = round($ws / $anzkomplett);

    	return "$ws,$wd_w";
}

function data_1hourmax() {
		$ws = 0;
		$wd = 0;
    	$mytime = time() - 60 * 20;
    	$query = "SELECT max(max_speed) as wind_speed,wind_direction from weather_merkur where tstamp > $mytime group by wind_direction order by wind_speed desc limit 1";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$x = $anzkomplett - 1;
    	for ($i=0; $i < $anzkomplett; $i++) {
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);
			$wd = round($array["wind_direction"],0);
    		$ws = round($array["wind_speed"],0);
    	}
    	return "$ws,$wd";
}



echo data_now();
echo "x";
echo data_avg(20);
echo "x";
echo data_avg(60);
echo "x";
echo data_1hourmax();





?>




