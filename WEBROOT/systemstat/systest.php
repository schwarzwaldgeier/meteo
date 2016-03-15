<?php

$xml = simplexml_load_file('http://localhost:81/systemstat/index.php?disp=xml');

$VHostname		= trim($xml->Vitals->attributes()->Hostname);
$VKernel		= trim($xml->Vitals->attributes()->Kernel);
$VDistro		= trim($xml->Vitals->attributes()->Distro);
$VUptime		= trim($xml->Vitals->attributes()->Uptime);
$VUsers			= trim($xml->Vitals->attributes()->Users);
$VLoadAvg		= trim($xml->Vitals->attributes()->LoadAvg);

$NetName		= trim($xml->Network->NetDevice->attributes()->Name);
$NetRxBytes		= trim($xml->Network->NetDevice->attributes()->RxBytes);
$NetTxBytes		= trim($xml->Network->NetDevice->attributes()->TxBytes);
$NetErr			= trim($xml->Network->NetDevice->attributes()->Err);
$NetDrops		= trim($xml->Network->NetDevice->attributes()->Drops);

$MemFree		= trim($xml->Memory->attributes()->Free);
$MemUsed		= trim($xml->Memory->attributes()->Used);
$MemTotal		= trim($xml->Memory->attributes()->Total);
$MemPercent		= trim($xml->Memory->attributes()->Percent);

$SwapFree		= trim($xml->Memory->Swap->attributes()->Free);
$SwapUsed		= trim($xml->Memory->Swap->attributes()->Used);
$SwapTotal		= trim($xml->Memory->Swap->attributes()->Total);
$SwapPercent	= trim($xml->Memory->Swap->attributes()->Percent);

$MountName		= trim($xml->FileSystem->Mount->attributes()->Name);
$MountFSType	= trim($xml->FileSystem->Mount->attributes()->FSType);
$MountFree		= trim($xml->FileSystem->Mount->attributes()->Free);
$MountUsed		= trim($xml->FileSystem->Mount->attributes()->Used);
$MountTotal		= trim($xml->FileSystem->Mount->attributes()->Total);
$MountPercent	= trim($xml->FileSystem->Mount->attributes()->Percent);

$gesamt = sizeof($xml->Plugins->Plugin_PSStatus->Process);
for ($i=0; $i < $gesamt; $i++) {
	$process[$i]['Name'] = trim($xml->Plugins->Plugin_PSStatus->Process[$i]->attributes()->Name);
	$process[$i]['Status'] = trim($xml->Plugins->Plugin_PSStatus->Process[$i]->attributes()->Status);
}

$MemPercentLeft = 100 - $MemPercent;
$SwapPercentLeft = 100 - $SwapPercent;
$MountPercentLeft = 100 - $MountPercent;

$uptimedays = $VUptime / 60 / 60 / 24;
$bytesperday = formatbytes((($NetRxBytes + $NetTxBytes) / $uptimedays));

/*echo "<pre>";
print_r($xml);
echo "</pre>";
*/

?>
<html>
<head><title><?php echo $VHostname;?> - STATUS</title>

        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta http-equiv="content-language" content="de"/>

<style type="text/css">
html,body {
	padding: 0px;
	margin: 0px;
	font-family: Courier New, Verdana, Arial, Helvetica;
	font-size: 12px;
	background-color: #ffffff;
	color: #000000;
}
.tdkey {
	width: 160px; 
	text-align: right;
	padding-right: 5px;
	padding-left: 5px;
	padding-top: 2px;
	padding-bottom: 2px;
}
.tdvalue {
	width: 400px; 
	text-align: right;
	padding-right: 5px;
	padding-left: 5px;
	padding-top: 2px;
	padding-bottom: 2px;
}
.tdkey2 {
	width: 460px; 
	text-align: right;
	padding-right: 5px;
	padding-left: 5px;
	padding-top: 2px;
	padding-bottom: 2px;
}
.tdvalue2 {
	width: 100px; 
	text-align: right;
	padding-right: 5px;
	padding-left: 5px;
	padding-top: 2px;
	padding-bottom: 2px;
}
.odd   {	background-color: #ccffcc; }
.even  {	background-color: #99cc99; }
.oddb  { background-color: #ffccff; }
.evenb { background-color: #cc99cc; }
.oddr  { background-color: #ffcccc; }
.evenr { background-color: #cc9999; }
.oddt  { background-color: #ccffff; }
.event { background-color: #99cccc; }
.oddo  { background-color: #ccccff; }
.eveno { background-color: #9999cc; }

</style>
</head>
<body>
<div style="background-color: #2971a7; color: #ffff33; margin-top: 5px; margin-bottom: 5px; height: 30px; width: 560px; font-size: 14px; font-weight: bold;"><a href="JavaScript:window.location.reload();"><img style="float: right; margin-right: 5px; margin-top: 4px;" src="/systemstat/gfx/reload.png" border="0" alt="Aktualisieren" title="Aktualisieren"></a><div style="float:left; margin-left: 4px; margin-top: 7px;">[ECHTZEIT-MONITOR <?php echo $VHostname;?>] [<?php echo date("d.m.y H:i:s");?>]</div></div>
<table style="width: 560px;">
<tr><td colspan="2" style="background-color: #003300; color: #eeeeee; font-weight: bold;">SYSTEM-ÜBERSICHT</td></tr>
<tr>
<td class="tdkey odd" valign="top">Hostname:</td>
<td class="tdvalue odd" valign="top"><?php echo $VHostname;?></td>
</tr>
<tr>
<td class="tdkey even" valign="top">Kernel:</td>
<td class="tdvalue even" valign="top"><?php echo $VKernel;?></td>
</tr>
<tr>
<td class="tdkey odd" valign="top">Distro:</td>
<td class="tdvalue odd" valign="top"><?php echo $VDistro;?></td>
</tr>
<tr>
<td class="tdkey even" valign="top">Uptime:</td>
<td class="tdvalue even" valign="top"><?php echo formatUptime($VUptime);?></td>
</tr>
<tr>
<td class="tdkey odd" valign="top">Users:</td>
<td class="tdvalue odd" valign="top"><?php echo $VUsers;?></td>
</tr>
<tr>
<td class="tdkey even" valign="top">LoadAvg:</td>
<td class="tdvalue even" valign="top"><?php echo $VLoadAvg;?></td>
</tr>
</table>

<table style="width: 560px;">
<tr><td colspan="2" style="background-color: #000033; color: #eeeeee; font-weight: bold;">ÜBERWACHTE PROZESSE</td></tr>
<?php
	foreach ($process as $entry) {
		$en = $entry['Name'];
		$es = $entry['Status'];
		if (eregi("mysqld",$en)) { $en = "mySQL Datenbank-Daemon"; }
		if (eregi("apache2",$en)) { $en = "Apache2 Webserver"; }
		if (eregi("sshd",$en)) { $en = "SSH-Daemon"; }
		if (eregi("vgetty",$en)) { $en = "Anrufbeantworter"; }
		if (eregi("weather_clean",$en)) { $en = "Wetterstations-Software (alt)"; }
		if (eregi("weather_start",$en)) { $en = "Wetterstations-Überwachung (alt)"; }
		if (eregi("WETTER_SOCKET",$en)) { $en = "Wetterstations-Software"; }
		if (eregi("WETTER_start",$en)) { $en = "Wetterstations-Überwachung"; }
		if ($es == "1") { $gfx = "/systemstat/plugins/PSStatus/gfx/online.png"; } else { $gfx = "/systemstat/plugins/PSStatus/gfx/offline.png"; }
?>		
<tr>
<td class="tdkey2 eveno" valign="top"><?php echo $en;?></td>
<td class="tdvalue2 eveno" valign="top"><center><img src="<?php echo $gfx;?>"></center></td>
</tr>

<?php
	}
?>
</table>

<table style="width: 560px;">
<tr><td colspan="2" style="background-color: #330033; color: #eeeeee; font-weight: bold;">NETZWERK-AUSLASTUNG</td></tr>
<tr>
<td class="tdkey oddb" valign="top">Schnittstelle:</td>
<td class="tdvalue oddb" valign="top"><?php echo $NetName;?></td>
</tr>
<tr>
<td class="tdkey evenb" valign="top">Empfangen:</td>
<td class="tdvalue evenb" valign="top"><?php echo formatbytes($NetRxBytes);?></td>
</tr>
<tr>
<td class="tdkey oddb" valign="top">Gesendet:</td>
<td class="tdvalue oddb" valign="top"><?php echo formatbytes($NetTxBytes);?></td>
</tr>
<tr>
<td class="tdkey evenb" valign="top">Fehler:</td>
<td class="tdvalue evenb" valign="top"><?php echo $NetErr;?></td>
</tr>
<tr>
<td class="tdkey oddb" valign="top">Verworfen:</td>
<td class="tdvalue oddb" valign="top"><?php echo $NetDrops;?></td>
</tr>
<tr>
<td class="tdkey oddb" valign="top">Traffic / Tag:</td>
<td class="tdvalue oddb" valign="top"><?php echo $bytesperday;?></td>
</tr>


</table>

<table style="width: 560px;">
<tr><td colspan="2" style="background-color: #330000; color: #eeeeee; font-weight: bold;">SPEICHER-AUSLASTUNG</td></tr>
<tr>
<td class="tdkey oddr" valign="top">Physikalischer Speicher:</td>
<td class="tdvalue oddr" valign="top"><div style="float: left; background-color: #333399; width: <?php echo $MemPercent * 2;?>px;">&nbsp;</div><div style="float: left; background-color: #999933; width: <?php echo $MemPercentLeft * 2;?>px;">&nbsp;</div>&nbsp;<?php echo $MemPercent;?>% Auslastung
<br clear="all">
<br>
<?php echo formatbytes($MemUsed);?> von <?php echo formatbytes($MemTotal);?> benutzt<br>(Total: <?php echo formatbytes($MemTotal);?>)
</td>
</tr>
<tr>
<td class="tdkey oddr" valign="top">Auslagerungs-<br>Datei:</td>
<td class="tdvalue oddr" valign="top"><div style="float: left; background-color: #333399; width: <?php echo $SwapPercent * 2;?>px;">&nbsp;</div><div style="float: left; background-color: #999933; width: <?php echo $SwapPercentLeft * 2;?>px;">&nbsp;</div>&nbsp;<?php echo $SwapPercent;?>% Auslastung
<br clear="all">
<br>
<?php echo formatbytes($SwapUsed);?> von <?php echo formatbytes($SwapTotal);?> benutzt<br>(Total: <?php echo formatbytes($SwapTotal);?>)
</td>
</tr>
</table>

<table style="width: 560px;">
<tr><td colspan="2" style="background-color: #003333; color: #eeeeee; font-weight: bold;">DATEISYSTEM</td></tr>
<tr>
<td class="tdkey oddt" valign="top">Mount-Name:</td>
<td class="tdvalue oddt" valign="top"><?php echo $MountName;?></td>
</tr>
<tr>
<td class="tdkey event" valign="top">Filesystem-Typ:</td>
<td class="tdvalue event" valign="top"><?php echo $MountFSType;?></td>
</tr>
<tr>
<td class="tdkey oddt" valign="top">Speicherplatz:</td>
<td class="tdvalue oddt" valign="top">
<div style="float: left; background-color: #333399; width: <?php echo $MountPercent * 2;?>px;">&nbsp;</div><div style="float: left; background-color: #999933; width: <?php echo $MountPercentLeft * 2;?>px;">&nbsp;</div>&nbsp;<?php echo $MountPercent;?>% Auslastung
<br clear="all">
<br>
<?php echo formatbytes($MountUsed);?> von <?php echo formatbytes($MountFree);?> benutzt<br>(Total: <?php echo formatbytes($MountTotal);?>)
</td>
</tr>
</table>



<?php
function formatUptime($sec) {
    $txt = "";
	$intMin = 0;
	$intHours = 0;
	$intDays = 0;
    $intMin = $sec / 60;
    $intHours = $intMin / 60;
    $intDays = floor($intHours / 24);
    $intHours = floor($intHours - ($intDays * 24));
    $intMin = floor($intMin - ($intDays * 60 * 24) - ($intHours * 60));
    if ($intDays) {
        $txt .= $intDays . "&nbsp;Tag(e)&nbsp;";
    }
    if ($intHours) {
        $txt .= $intHours . "&nbsp;Stunde(n)&nbsp;";
    }
    return $txt . $intMin . "&nbsp;Minute(n)";
}
?>

<?php
function formatbytes($bytes) {
    $show = "";
	if ($bytes > pow(1024, 5)) {
        $show .= round($bytes / pow(1024, 5), 2);
        $show .= "&nbsp;PB";
    }
    else {
        if ($bytes > pow(1024, 4)) {
            $show .= round($bytes / pow(1024, 4), 2);
            $show .= "&nbsp;TB";
        }
        else {
            if ($bytes > pow(1024, 3)) {
                $show .= round($bytes / pow(1024, 3), 2);
                $show .= "&nbsp;GB";
            }
            else {
                if ($bytes > pow(1024, 2)) {
                    $show .= round($bytes / pow(1024, 2), 2);
                    $show .= "&nbsp;MB";
                }
                else {
                    $show .= round($bytes / pow(1024, 1), 2);
                    $show .= "&nbsp;KB";
                }
            }
        }
    }
    return $show;
}
?>
