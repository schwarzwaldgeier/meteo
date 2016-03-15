<?php
$fehler = "<span style=\"color: #ff0000; font-weight: bold; font-size: 12px;\">FEHLER</span>";
$ok = "<span style=\"color: #006600; font-weight: bold; font-size: 12px;\">OKI</span>";
$meld = "<span style=\"color: #666600; font-weight: bold; font-size: 12px;\">AUSFALL?</span>";

$ws_green_fg = "#006600";
$ws_green_bg = "#ccffcc";
$ws_red_fg = "#ff0000";
$ws_red_bg = "#ffcccc";
$ws_yellow_fg = "#666600";
$ws_yellow_bg = "#ffffcc";

$db_c = "#006600";
$db_bc = "#ccffcc";
$lwc = "#006600";
$dbconn = $ok;

ob_start();
passthru("/usr/bin/tail -n 40 /var/log/mgetty/vg_ttyS0.log",$retval);
$out = ob_get_contents();
ob_end_clean();

$sema = "/var/log/mgetty/vg_ttyS0.log";
$lastaction = filemtime($sema);
$nowtime = time();
$actime = $nowtime - $lastaction;



if (eregi("bad cable",$out)) {
	$dbconn = $fehler;
	$lwc = "#ff0000"; 
	$db_c = "#ff0000";
	$db_bc = "#ffcccc";
}

?>

<div style="position: absolute; top: 515px; left: 20px; width: 260px; height: 100px; background-color: <?php echo $db_bc;?>; padding: 5px; border: 1px <?php echo $db_c;?> solid; z-index: 199;">
<h3>Telefonleitung an Server #1 Bergstation</h3>
<div style="clear: left; float: left; width: 150px; border-bottom: 1px #cccccc dotted;">Leitungs-Status:</div>
<div style="float: left; width: 110px; border-bottom: 1px #cccccc dotted;"><?php echo $dbconn;?></div>

<div style="clear: left; float: left; width: 150px; border-bottom: 1px #cccccc dotted;">Letzter Logfile-Eintrag:<br>= letzer Anruf oder<br>&nbsp;&nbsp;&nbsp;letzer INIT-Versuch</div>
<div style="float: left; width: 110px; border-bottom: 1px #cccccc dotted;"><br>vor <?php echo $actime;?> Sekunden</div>
&nbsp;
</div>
