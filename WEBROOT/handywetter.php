<?php
    @require_once($_SERVER["DOCUMENT_ROOT"]."/inc/parse_request.inc.php");
	@require_once($_SERVER["DOCUMENT_ROOT"]."/inc/php_mysql.php");
    parse_request($_GET);
?>

<?php
//echo $_SERVER["HTTP_REFERER"];




//if(!(eregi('gsvbaden.de',$_SERVER["HTTP_REFERER"]))) {
if($_COOKIE["gei"] != "ichbineingeier") {
		$wrefer = $_SERVER["HTTP_REFERER"];
    	$void = mysql_select_db($db);
    	if(!(empty($_REQUEST["jalUserName"]))) { $wname = $_REQUEST["jalUserName"]; } else { $wname = ""; }
		$wbrowser = $_SERVER["HTTP_USER_AGENT"];
    	$wquery = "INSERT INTO redir_stats (uname,ubrause,urefer) values ('$wname','$wbrowser','$wrefer')";
   		if ($void != 1) {
   			$error .= "could not select database $db !!!!";
   		}
   		$wresult = mysql_query($wquery);
   		if ($wresult != 1) {
    			$error .= "could not issue sql-statement ($wquery) !!!!";

   		}
?>



<?php
}

?>

<center>
<link rel="stylesheet" href="http://www.gsvbaden.de/_extphp/wetterstation/typo_cal.css" type="text/css"/>

<?php
	$dat120 = rawdata_avg(120);
	$vereist = "";
	$checkeis = false;
	if (Date("m") == "10") { $checkeis = true; }
	if (Date("m") == "11") { $checkeis = true; }
	if (Date("m") == "12") { $checkeis = true; }
	if (Date("m") == "01") { $checkeis = true; }
	if (Date("m") == "02") { $checkeis = true; }
	if (Date("m") == "03") { $checkeis = true; }


	if ($checkeis) {
		$wdccheckdiff = abs($dat120["wdmin"] - $dat120["wdmax"]);
		if ($wdccheckdiff < 3) {
			$vereist = "&eis=da";
		}

		$wsccheckdiff = abs($dat120["wsmin"] - $dat120["wsmax"]);
		if ($wsccheckdiff < 2) {
			$vereist = "&eis=da";
		}
	}

//echo "[".$wdccheckdiff."|".$wsccheckdiff."]";

?>



<?php

	if(!(empty($_GET["rec_count"]))) { $rec_count = $_GET["rec_count"]; } else { $rec_count = 10; }
	if(!(empty($_GET["avg_hours"]))) { $avg_hours = $_GET["avg_hours"]; } else { $avg_hours = 2; }
	if(!(empty($_GET["sdate"]))) { $sdate = $_GET["sdate"]; } else { $sdate = date("Y-m-d"); }


	define("WRED","#660000");
	define("WGREEN","#006600");
	define("SYELLOW","#666600");
	define("SRED","#FF9999");
	define("SGREEN","#CCFFCC");
	define("WYELLOW","#ffff99");


?>


<br>

 <?php
 if ($sdate != date("Y-m-d")) {
 ?>
 <h3>
 Historische Daten für den <?php echo substr($sdate,8,2).".".substr($sdate,5,2).".".substr($sdate,0,4);?>

 </h3>
 <?php
 }
 ?>


<table style="width: 100%;">
<tr><td width="100%" valign="top" align="center">
<center>


<?php function last_records($rcount) {
?>
    <table style="width: 100%; border: 1px #0000ff solid; margin-top: 2px; margin-bottom: 2px;">
		<tr>
		<th style="color: #ffffff; background-color: #0000ff;" width="100%" valign="top" colspan="7">
			Wetterstation Merkur: Die letzten <?php echo $rcount;?> Messungen
		</th>
		</tr>
    		<tr>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="18%" valign="top">Startpl. West</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="16%" valign="top">Geschw.</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="16%" valign="top">Böe</td>
    		<td style="color: #ffffff; background-color: #0000ff; align="right" width="75" valign="top">Temp.</td>
    		<td style="color: #ffffff; background-color: #0000ff; align="right" width="150" valign="top">Luftdruck</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="32%" valign="top">Mess-Zeit</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="18%" valign="top">Startpl. Nordost:</td>
            </tr>


    <?php
    	$query = "SELECT * from weather_merkur2 order by uid desc LIMIT $rcount";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$fa = 0;
    	for ($i=0; $i < $anzkomplett; $i++) {
    	    if ($fa == 0) {
    	    	$bgs = "#cccccc"; $fa = 1;
    	    } else {
    	    	$bgs = "#dddddd"; $fa = 0;
    	    }
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);

			$fcol = WRED;
			$scol = SRED;
    		if(($array["wind_direction"] >= 181) && ($array["wind_direction"] <= 219)) {
    			$scol = WYELLOW; $fcol = SYELLOW;
    		}
    		if(($array["wind_direction"] >= 220) && ($array["wind_direction"] <= 300)) {
    			$scol = WGREEN; $fcol = SGREEN;
    		}
    		if(($array["wind_direction"] >= 301) && ($array["wind_direction"] <= 330)) {
    			$scol = WYELLOW; $fcol = SYELLOW;
    		}

			$nfcol = WRED;
			$nscol = SRED;
    		if(($array["wind_direction"] >= 10) && ($array["wind_direction"] <= 19)) {
    			$nscol = WYELLOW; $nfcol = SYELLOW;
    		}
    		if(($array["wind_direction"] >= 20) && ($array["wind_direction"] <= 50)) {
    			$nscol = WGREEN; $nfcol = SGREEN;
    		}
    		if(($array["wind_direction"] >= 51) && ($array["wind_direction"] <= 60)) {
    			$nscol = WYELLOW; $nfcol = SYELLOW;
    		}


    ?>
    		<tr style="background-color: <?php echo $bgs;?>;">
    		<td style="color: <?php echo $fcol;?>; background-color: <?php echo $scol;?>; text-align:right;" align="right" valign="top"><?php echo $array["wind_direction"];?>°</td>
    		<td style="text-align:right;" valign="top"><?php echo round($array["wind_speed"],0);?> km/h</td>
    		<td style="text-align:right;" valign="top"><?php echo round($array["wind_maxspeed"],0);?> km/h</td>
    		<td align="right" width="75" valign="top"><?php echo $array["temperature"];?>° C</td>
    		<td align="right" width="150" valign="top"><?php echo $array["pressure"];?> hpa</td>

<?php if (date("I") == 0) { ?>
<!-- Sommerzeit -->
    		<td style="text-align:right;" valign="top"><?php echo date("d.m.Y H:i",$array["tstamp"]+3600);?></td>
<?php } else { ?>
<!-- Winterzeit -->
    		<td style="text-align:right;" valign="top"><?php echo date("d.m.Y H:i",$array["tstamp"]);?></td>
<?php } ?>

    		<td style="color: <?php echo $nfcol;?>; background-color: <?php echo $nscol;?>; text-align:right;" valign="top"><?php echo $array["wind_direction"];?>°</td>
            </tr>
    <?php
    	}
    ?>


    </table>
<?php } ?>


<?php
if ($sdate == date("Y-m-d")) {
?>

<?php if (!$vereist) { ?>
    <?php last_records($rec_count); ?>
<?php } ?>


    <br>
    <table style="width: 100%; border: 1px #0000ff solid; margin-top: 2px; margin-bottom: 2px;">
    		<tr>
    		<th width="100%" style="color: #ffffff; background-color: #0000ff; font-style: bold;" width="100%" valign="top" colspan="7">
    			Wetterstation Merkur: Durchschnittswerte
    		</th>
    		</tr>

    		<tr>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="18%" valign="top">SP West</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="16%" valign="top">Geschw.</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="16%" valign="top">Böe</td>
    		<td style="color: #ffffff; background-color: #0000ff;" align="right" width="50" valign="top">Temp.</td>
    		<td style="color: #ffffff; background-color: #0000ff;" align="right" width="100" valign="top">Luftdruck</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="32%" valign="top">Mess-Zeit</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="18%" valign="top">SP Nordost:</td>
            </tr>


<?php if ($vereist) { ?>


            <tr style="background-color: rgb(204, 204, 204);">
            <td style="color: rgb(102, 0, 0); background-color: rgb(255, 153, 153); text-align: right;" valign="top">Huuiiii, </td>
            <td style="text-align: right;" valign="top">das ist</td>
            <td style="text-align: right;" valign="top">ja saukalt wieder heute</td>

            <td style="text-align: right;" valign="top">letzte 20 Minuten</td>
            <td style="color: rgb(204, 255, 204); background-color: rgb(0, 102, 0); text-align: right;" align="right" valign="top">Mist!</td>
            </tr>


            <tr style="background-color: rgb(204, 204, 204);">
            <td style="color: rgb(102, 0, 0); background-color: rgb(255, 153, 153); text-align: right;" valign="top">Mir</td>
            <td style="text-align: right;" valign="top">scheint, ich habe mir</td>
            <td style="text-align: right;" valign="top">doch wirklich alles abgefroren</td>
            <td align="right" valign="top">0° C</td>
            <td align="right" valign="top">0 hpa</td>
            <td style="text-align: right;" valign="top">letzte 60 Minuten</td>
            <td style="color: rgb(204, 255, 204); background-color: rgb(0, 102, 0); text-align: right;" align="right" valign="top">kaalt!!</td>
            </tr>


            <tr style="background-color: rgb(204, 204, 204);">
            <td style="color: rgb(102, 0, 0); background-color: rgb(255, 153, 153); text-align: right;" valign="top">bbrrr...</td>
            <td style="text-align: right;" valign="top">eisig</td>
            <td style="text-align: right;" valign="top">brrr</td>

            <td style="text-align: right;" valign="top">letzte 120 Minuten</td>
            <td style="color: rgb(204, 255, 204); background-color: rgb(0, 102, 0); text-align: right;" align="right" valign="top">hilfe</td>
            </tr>


<?php } else { ?>


		    <?php data_avg(20); ?>
		    <?php data_avg(60); ?>
		    <?php data_avg(120); ?>

<?php }  ?>


	</table>


<br>

<?php
}
?>


<img width="540" alt="Windgeschwindigkeits-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-speed.php?sdate=<?php echo $sdate;?><?php echo $vereist;?>">
<br>
<br>
<img width="540" alt="Windrichtungs-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-direction.php?sdate=<?php echo $sdate;?><?php echo $vereist;?>">
<br>
<br>
<!--
<img width="540" height="344" alt="Temperatur-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-temp.php?sdate=<?php echo $sdate;?>">
<br>
<br>
<img width="540" height="344" alt="Luftdruck-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-press.php?sdate=<?php echo $sdate;?>">
<br>
<br>
-->
</center>
</td>
</tr></table>

	<br>
	<br>

<?php

function data_avg($mins) {
		$ws = 0;
		$te = 0;
		$pr = 0;
		$ms = 0;
		$wd_u = 0;
		$wd_v = 0;
		$wd_w = 0;
    	$mytime = time() - $mins * 60;
    	#$query = "SELECT avg(wind_speed) as wind_speed,avg(wind_direction) as wind_direction from weather_merkur2 where tstamp > $mytime limit 1";
    	$query = "SELECT wind_speed, wind_direction, temperature, pressure, wind_maxspeed from weather_merkur2 where tstamp > $mytime";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$x = $anzkomplett - 1;
    	$recs = $anzkomplett;
    	if ($recs > 0) {
        	for ($i=0; $i < $anzkomplett; $i++) {
        		$void = mysql_data_seek($result, $i);
        		$array = mysql_fetch_array($result, MYSQL_ASSOC);
    			$wd_u += sin(round($array["wind_direction"],0) * M_PI / 180);
    			$wd_v += cos(round($array["wind_direction"],0) * M_PI / 180);
        		$ws += round($array["wind_speed"],0);
        		$te += round($array["temperature"],0);
        		$pr += round($array["pressure"],0);
        		$recs = $array["recs"];
        		$ms = round(max($array["wind_maxspeed"],0),0);
        		

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
    	    $te = round($te / $anzkomplett);
    	    $pr = round($pr / $anzkomplett);
		}

	    $arr["wd"] = $wd_w;
	    $arr["ws"] = $ws;
	    $arr["te"] = $te;
	    $arr["pr"] = $pr;
	    $arr["ms"] = $ms;

    	//return $arr;

		$fcol = WRED;
		$scol = SRED;
    	if(($arr["wd"] >= 181) && ($arr["wd"] <= 219)) {
    		$scol = WYELLOW; $fcol = SYELLOW;
    	}
    	if(($arr["wd"] >= 220) && ($arr["wd"] <= 300)) {
    		$scol = WGREEN; $fcol = SGREEN;
    	}
    	if(($arr["wd"] >= 301) && ($arr["wd"] <= 330)) {
    		$scol = WYELLOW; $fcol = SYELLOW;
    	}



		$nfcol = WRED;
		$nscol = SRED;
    	if(($arr["wd"] >= 10) && ($arr["wd"] <= 19)) {
    		$nscol = WYELLOW; $nfcol = SYELLOW;
    	}
    	if(($arr["wd"] >= 20) && ($arr["wd"] <= 50)) {
    		$nscol = WGREEN; $nfcol = SGREEN;
    	}
    	if(($arr["wd"] >= 51) && ($arr["wd"] <= 60)) {
    		$nscol = WYELLOW; $nfcol = SYELLOW;
    	}


?>

    		<tr style="background-color: #cccccc;">
    		<td style="color: <?php echo $fcol;?>; background-color: <?php echo $scol;?>; text-align:right;" valign="top"><?php echo $arr["wd"];?>°</td>
    		<td style="text-align:right;" valign="top"><?php echo $arr["ws"];?> km/h</td>
    		<td style="text-align:right;" valign="top"><?php echo $arr["ms"];?> km/h</td>
    		<td align="right" valign="top"><?php echo $arr["te"];?>° C</td>
    		<td align="right" valign="top"><?php echo $arr["pr"];?> hpa</td>
    		<td style="text-align:right;" valign="top">letzte <?php echo $mins;?> Minuten</td>
    		<td style="color: <?php echo $nfcol;?>; background-color: <?php echo $nscol;?>; text-align:right;" align="right" valign="top"><?php echo $arr["wd"];?>°</td>
            </tr>

<?php

}


?>

</center>
<br>
<pre>
<?php
//print_r($_COOKIE);
//phpinfo();
?>
</pre>


<?php

function rawdata_avg($mins) {
		$ws = 0;
		$te = 0;
		$pr = 0;
		$ms = 0;
		$wd_u = 0;
		$wd_v = 0;
		$wd_w = 0;
    	$mytime = time() - $mins * 60;
		$query = "SELECT min(wind_speed) mis, max(wind_speed)mas, min(wind_direction) mid, max(wind_direction) mad from weather_merkur2 where tstamp > $mytime";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
   		$void = mysql_data_seek($result, 0);
   		$array = mysql_fetch_array($result, MYSQL_ASSOC);
	    $arr["wdmin"] = $array["mid"];
	    $arr["wdmax"] = $array["mad"];
	    $arr["wsmin"] = $array["mis"];
	    $arr["wsmax"] = $array["mas"];
    	return $arr;
}

?>
