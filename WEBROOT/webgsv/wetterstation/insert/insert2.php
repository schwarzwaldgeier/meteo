<?php
    @require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/parse_request.inc.php");
    parse_request($_GET);

	$error = "";
	if(strlen($_GET["ws"])<1) { $error .= "no windspeed. "; $error = 1; }
	if(strlen($_GET["wd"])<1) { $error .= "no winddirection. "; $error = 1; }
	if(strlen($_GET["te"])<1) { $error .= "no temperature. "; $error = 1; }
	if(strlen($_GET["pr"])<1) { $error .= "no pressure. "; $error = 1; }
	if(strlen($_GET["ms"])<1) { $error .= "no max windspeed. "; $error = 1; }
	if(strlen($_GET["wc"])<1) { $error .= "no windchill. "; $error = 1; }
	if(strlen($_GET["hu"])<1) { $error .= "no humidity. "; $error = 1; }

	if(empty($error)) {
		@require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/php_mysql.php");
		$query = "INSERT INTO weather_merkur2 (record_datetime,tstamp,wind_direction,wind_speed,temperature,pressure,wind_maxspeed,humidity,wind_chill) values ('".date("Y-m-d H:i:s")."',".time().",".$_GET["wd"].",".$_GET["ws"].",".$_GET["te"].",".$_GET["pr"].",".$_GET["ms"]."," . $_GET["hu"] . "," . $_GET["wc"] . ")";
		$void = mysql_select_db($db);
		if ($void != 1) {
			$error = 1;
			$error .= "could not select database $db !!!!";
		}
		$result = mysql_query($query);
		if ($result != 1) {
			$error = 1;
			$error .= "could not issue sql-statement ($query) !!!!";
		}
	} else {
		print "ERROR: $error";
	}
	if(empty($error)) {
		echo "ThatWasGood";
	} else {
		echo "ERROR: $error";
	}


?>


