<?php

$fehler = "<span style=\"color: #ff0000; font-weight: bold; font-size: 12px;\">KRITISCH</span>";
$ok = "<span style=\"color: #006600; font-weight: bold; font-size: 12px;\">OKI</span>";
$meld = "<span style=\"color: #666600; font-weight: bold; font-size: 12px;\">AUSFALL?</span>";

$ws_green_fg = "#006600";
$ws_green_bg = "#ccffcc";
$ws_red_fg = "#ff0000";
$ws_red_bg = "#ffcccc";
$ws_yellow_fg = "#666600";
$ws_yellow_bg = "#ffffcc";

//$sema = "/var/www/BERGSTATION/wetterstation/WSTIME.sema";
$sema = "/var/www/BERGSTATION/wetterstation_neu/logs/" . date("Ymd") . "_merkur.log";
$lastaction = filemtime($sema);
$nowtime = time();
$actime = $nowtime - $lastaction;

$db_c = "#006600";
$db_bc = "#ccffcc";
$lwc = "#006600";
$dbconn = $ok;

if ($actime > 2 * 60) { 
	$lwc = "#ff9900"; 
	$db_c = "#ff9900";
	$db_bc = "#ffffcc";
	$dbconn = $meld;
}
if ($actime > 10 * 60) { 
	$lwc = "#ff0000"; 
	$db_c = "#ff0000";
	$db_bc = "#ffcccc";
	$dbconn = $fehler;
}


?>


<div style="position: absolute; top: 240px; left: 60px; width: 420px; height: 70px; background-color: <?php echo $db_bc;?>; padding: 5px; border: 1px <?php echo $db_c;?> solid; z-index: 99;">
<h3>Daten-Leitung SENSOREN&lt;-&gt;SERVER SWR-Raum</h3>
<div style="clear: left; float: left; width: 190px; border-bottom: 1px #cccccc dotted;">Leitungs-Status:</div>
<div style="float: left; width: 230px; border-bottom: 1px #cccccc dotted;"><?php echo $dbconn;?></div>

<div style="clear: left; float: left; width: 190px; border-bottom: 1px #cccccc dotted;">Letzter Datenfluss auf Leitung:</div>
<div style="float: left; width: 230px; border-bottom: 1px #cccccc dotted;">vor <?php echo $actime;?> Sekunden</div>
&nbsp;
</div>