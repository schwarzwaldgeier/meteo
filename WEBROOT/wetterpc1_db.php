<?php

// Wetterstations-DB / PC 1
// --------------------------------------------------------------------------------------------------------//
	include("credentials.php");
	$fehler = "<span style=\"color: #ff0000; font-weight: bold; font-size: 12px;\">FEHLER</span>";
	$ok = "<span style=\"color: #006600; font-weight: bold; font-size: 12px;\">OKI</span>";
	$meld = "<span style=\"color: #666600; font-weight: bold; font-size: 12px;\">HINWEIS</span>";

	$ws_green_fg = "#006600";
	$ws_green_bg = "#ccffcc";
	$ws_red_fg = "#ff0000";
	$ws_red_bg = "#ffcccc";
	$ws_yellow_fg = "#666600";
	$ws_yellow_bg = "#ffffcc";
	$db_c = "#006600";
	$db_bc = "#ccffcc";
	$dbconn = $ok;
	$dbsel = $ok;
	$lastw = $ok;

    	$ahost		= $wetterdb_host;
    	$auser		= $wetterdb_user;
    	$apassword	= $wetterdb_password;
    	$adb		= $wetterdb_db;
    	$zumachen = @mysql_connect($ahost,$auser,$apassword) or $zumachen = "Fehler";
		if ($zumachen == "Fehler") {
			$dbconn = $fehler;
			$db_c = "#ff0000";
			$db_bc = "#ffcccc";
		} else {
			$dbconn = $ok;
			$void = mysql_select_db($adb);
			if ($void != 1) {
				$dbsel = $fehler;
				$db_c = "#ff0000";
				$db_bc = "#ffcccc";
			} else {
				$dbsel = $ok;
				$aquery = "select max(tstamp) maxt from weather_merkur2";
				$aresult = mysql_query($aquery);
				$anzkomplett = @mysql_num_rows($aresult);
				$void = mysql_data_seek($aresult, 0);
				$array = mysql_fetch_array($aresult, MYSQL_ASSOC);
				$lastw = eregi_replace("OKI",date("d.m.Y",$array["maxt"]) . "<br>" . date("H:i:s",$array["maxt"]),$ok);
				$mt = time();
				$wt = $array["maxt"];
				$wd = $mt - $wt;
				$lwc = "#006600";
				if ($wd > 3600) { 
					$lwc = "#ff9900"; 
					$db_c = "#ff9900";
					$db_bc = "#ffffcc";
				}
				if ($wd > 3 * 3600) { 
					$lwc = "#ff0000"; 
					$db_c = "#ff0000";
					$db_bc = "#ffcccc";
				}
				$lastw = eregi_replace("#006600",$lwc,$lastw);
				
			}
		}
// --------------------------------------------------------------------------------------------------------//
?>
<div style="position: absolute; top: 420px; left: 15px; width: 260px; height: 100px; background-color: <?php echo $db_bc;?>; padding: 5px; border: 1px <?php echo $db_c;?> solid; z-index: 99;">
<h3>Datenbank Server #1 Bergstation</h3>
<div style="clear: left; float: left; width: 160px; border-bottom: 1px #cccccc dotted;">Datenbank-Verbindung:</div>
<div style="float: left; width: 100px; border-bottom: 1px #cccccc dotted;"><?php echo $dbconn;?></div>

<div style="clear: left; float: left; width: 160px; border-bottom: 1px #cccccc dotted;">Datenbank-DB-Selection:</div>
<div style="float: left; width: 100px; border-bottom: 1px #cccccc dotted;"><?php echo $dbsel;?></div>

<div style="clear: left; float: left; width: 160px; border-bottom: 1px #cccccc dotted;">Letzter Wetterwert:</div>
<div style="float: left; width: 100px; border-bottom: 1px #cccccc dotted;"><?php echo $lastw;?></div>
&nbsp;
</div>

