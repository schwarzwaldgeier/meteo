<?php
    @require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/parse_request.inc.php");
	@require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/php_mysql.php");
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

<script language="JavaScript">
window.location.href='http://www.gsvbaden.de';
</script>

<?php
}

?>

<center>
<link rel="stylesheet" href="http://www.gsvbaden.de/_extphp/wetterstation/typo_cal.css" type="text/css"/>

<?php
	$dat60 = rawdata_avg(60);
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
		if ( (($dat60["wd"] / $dat120["wd"]) > 0.99) && (($dat60["wd"] / $dat120["wd"]) < 1.01) ) {
			$vereist = "&eis=da";
		}
		if ( ($dat60["ws"] < 2) && ($dat120["ws"] < 2) ) {
			$vereist = "&eis=da";
		}
	}
	
	$vereist = "";
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

<table width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-left: 5px;">
<tr><td width="75%" valign="top">
 <?php
 if ($sdate != date("Y-m-d")) {
 ?>
 <br>
 Historische Daten der Wetterstation am Merkur der Schwarzwaldgeier
 <br>
 <br>
 Zum Anzeigen einfach den entsprechenden Tag rechts im Kalender anklicken.<br>
 <br>
 <center><a href="/index.php?option=com_content&task=view&id=22&Itemid=30">Zur�ck zu den aktuellen Daten</a></center>
<?php } else { ?>

<b>Telefon: 07221 - 277 577<p>

Funkkanal: LPD 08-08  ***  433,250 (Tsq 88,5) <p>
</b>
<?php }  ?>

</td>
<td width="25%" valign="middle" align="right">
 <?php
 if ($sdate != date("Y-m-d")) {
 	@include($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/typo_calendar.php");
 } else {
 ?>
	<a href="/index.php?option=com_content&task=view&id=22&Itemid=30&sdate=<?php echo date("Y-m-d",time()-86400);?>">Wie war das Wetter gestern? (historische Daten)...</a>

<?php } ?>

</td>
</tr>
</table>
<br>

 <?php
 if ($sdate != date("Y-m-d")) {
 ?>
 <h3>
 Historische Daten f�r den <?php echo substr($sdate,8,2).".".substr($sdate,5,2).".".substr($sdate,0,4);?>

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
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="16%" valign="top">B�e</td>
<!--    		<td style="color: #ffffff; background-color: #0000ff;" align="right" width="50" valign="top">Temp.</td>
    		<td style="color: #ffffff; background-color: #0000ff;" align="right" width="100" valign="top">Luftdruck</td>
-->
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="32%" valign="top">Mess-Zeit</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="18%" valign="top">Startpl. Nordost:</td>
            </tr>


    <?php
    	$query = "SELECT * from weather_merkur order by uid desc LIMIT $rcount";
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
    		<td style="color: <?php echo $fcol;?>; background-color: <?php echo $scol;?>; text-align:right;" align="right" valign="top"><?php echo $array["wind_direction"];?>�</td>
    		<td style="text-align:right;" valign="top"><?php echo $array["wind_speed"];?> km/h</td>
    		<td style="text-align:right;" valign="top"><?php echo $array["max_speed"];?> km/h</td>
<!--
    		<td align="right" width="50" valign="top"><?php echo $array["temperature"];?>� C</td>
    		<td align="right" width="100" valign="top"><?php echo $array["pressure"];?> hpa</td>
-->
<!-- F�r Sommerzeit -->
    		<td style="text-align:right;" valign="top"><?php echo date("d.m.Y H:i",$array["tstamp"]+3600);?></td>
<!-- F�r Winterzeit -->
<!--
    		<td style="text-align:right;" valign="top"><?php echo date("d.m.Y H:i",$array["tstamp"]);?></td>
-->
<!-- -->

    		<td style="color: <?php echo $nfcol;?>; background-color: <?php echo $nscol;?>; text-align:right;" valign="top"><?php echo $array["wind_direction"];?>�</td>
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
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="16%" valign="top">B�e</td>
<!--    		<td style="color: #ffffff; background-color: #0000ff;" align="right" width="50" valign="top">Temp.</td>
    		<td style="color: #ffffff; background-color: #0000ff;" align="right" width="100" valign="top">Luftdruck</td>
-->
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="32%" valign="top">Mess-Zeit</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="18%" valign="top">SP Nordost:</td>
            </tr>


<?php if ($vereist) { echo "x" . $vereist . "x"; ?>



            <tr style="background-color: rgb(204, 204, 204);">
            <td style="color: rgb(102, 0, 0); background-color: rgb(255, 153, 153); text-align: right;" valign="top">Huuiiii, </td>
            <td style="text-align: right;" valign="top">xxdas ist</td>
            <td style="text-align: right;" valign="top">ja saukalt wieder heute</td>

            <td style="text-align: right;" valign="top">letzte 20 Minuten</td>
            <td style="color: rgb(204, 255, 204); background-color: rgb(0, 102, 0); text-align: right;" align="right" valign="top">Mist!</td>
            </tr>

          
            <tr style="background-color: rgb(204, 204, 204);">
            <td style="color: rgb(102, 0, 0); background-color: rgb(255, 153, 153); text-align: right;" valign="top">Mir</td>
            <td style="text-align: right;" valign="top">scheint, ich habe mir</td>
            <td style="text-align: right;" valign="top">doch wirklich alles abgefroren</td>
<!--
            <td align="right" valign="top">0� C</td>
            <td align="right" valign="top">0 hpa</td>
-->
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


<?php
include("Mobile_Detect.php");
$detect = new Mobile_Detect();
?>

<?php if (!($detect->isMobile())) { ?>
<img width="540" alt="Windgeschwindigkeits-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/jp.php?img=http://www.gsvbaden.de/_extphp/wetterstation/typo_w-speed.php&sdate=<?php echo $sdate;?><?php echo $vereist;?>">
<?php } else { ?>
<img width="540" alt="Windgeschwindigkeits-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-speed.php?sdate=<?php echo $sdate;?><?php echo $vereist;?>">
<?php } ?>
<br>
<br>

<?php if (!($detect->isMobile())) { ?>
<img width="540" alt="Windrichtungs-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-direction.php?sdate=<?php echo $sdate;?><?php echo $vereist;?>">
<?php } else { ?>
<img width="540" alt="Windrichtungs-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-speed.php?img=http://www.gsvbaden.de/_extphp/wetterstation/typo_w-direction.php&sdate=<?php echo $sdate;?><?php echo $vereist;?>">
<?php } ?>
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
<table width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-left: 5px;">
<tr><td colspan="2" width="100%" style="color: #dddddd;">
Mit freundlicher Unterst�tzung der <a href="http://www.stadtwerke-baden-baden.de/" target="_sw">Stadtwerke Baden-Baden</a><br>
<a href="http://www.stadtwerke-baden-baden.de/" target="_sw"><img border="0" src="http://www.gsvbaden.de/_extphp/wetterstation/pix/sw.jpg" width="540" alt="Mit freundlicher Unterst�tzung der Stadtwerke Baden-Baden"></a></td></tr>
</table>


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
    	#$query = "SELECT avg(wind_speed) as wind_speed,avg(wind_direction) as wind_direction from weather_merkur where tstamp > $mytime limit 1";
    	$query = "SELECT wind_speed, wind_direction, temperature, pressure, max_speed from weather_merkur where tstamp > $mytime";
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
        		if ($array["max_speed"] > $ms) {
        		 $ms = round($array["max_speed"],0);
        		}

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
    		<td style="color: <?php echo $fcol;?>; background-color: <?php echo $scol;?>; text-align:right;" valign="top"><?php echo $arr["wd"];?>�</td>
    		<td style="text-align:right;" valign="top"><?php echo $arr["ws"];?> km/h</td>
    		<td style="text-align:right;" valign="top"><?php echo $arr["ms"];?> km/h</td>
<!--
    		<td align="right" valign="top"><?php echo $arr["te"];?>� C</td>
    		<td align="right" valign="top"><?php echo $arr["pr"];?> hpa</td>
-->
    		<td style="text-align:right;" valign="top">letzte <?php echo $mins;?> Minuten</td>
    		<td style="color: <?php echo $nfcol;?>; background-color: <?php echo $nscol;?>; text-align:right;" align="right" valign="top"><?php echo $arr["wd"];?>�</td>
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
    	$query = "SELECT wind_speed, wind_direction, temperature, pressure, max_speed from weather_merkur where tstamp > $mytime";
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
        		if ($array["max_speed"] > $ms) {
        		 $ms = round($array["max_speed"],0);
        		}

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

    	return $arr;

}

?>
