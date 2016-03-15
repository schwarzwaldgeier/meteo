<?php
$cachefile = $_SERVER["DOCUMENT_ROOT"] . "_extphp/wetterstation/cache/76530.wetter.cache";

if(!(file_exists($cachefile))) {
	dowetter($cachefile);
	$wettercached = true;
} else {
		$timediff = time() - filemtime($cachefile);
		if ($timediff <= 3600) { $wettercached = true; }
}
if (!$wettercached) {
	dowetter($cachefile);
}

$getstuff = file_get_contents($cachefile);

$inraw = explode("<td>",$getstuff);
$getstuff = eregi_replace("\|","<br>",$getstuff);
$in = explode("<td>",$getstuff);
$wetter[0]["day"] = $in[2];
$wetter[0]["am"] = $in[6];
$wetter[0]["noon"] = $in[10];
$wetter[0]["pm"] = $in[14];
$wetter[1]["day"] = $in[3];
$wetter[1]["am"] = $in[7];
$wetter[1]["noon"] = $in[11];
$wetter[1]["pm"] = $in[15];
$wetter[2]["day"] = $in[4];
$wetter[2]["am"] = $in[8];
$wetter[2]["noon"] = $in[12];
$wetter[2]["pm"] = $in[16];

//echo "<pre>";
//print_r($wetter);
//echo "</pre>";
?>

<table width="700" style="padding: 0px; border: 0px; margin: 0px;" cellpadding="0" border="0" cellspacing="0">
<tr>
	<th style="background-color: #000099; color: #dddddd; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="160" align="right" valign="top">Tag</th>
	<th style="background-color: #000099; color: #dddddd; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top">Vormittag</th>
	<th style="background-color: #000099; color: #dddddd; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top">Nachmittag</th>
	<th style="background-color: #000099; color: #dddddd; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top">Abend</th>
</tr>
<tr>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="160" align="right"><?php echo $wetter[0]["day"];?></td>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[0]["am"];?></td>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[0]["noon"];?></td>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[0]["pm"];?></td>
</tr>
<tr>
	<td style="background-color: #9999ff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="160" align="right"><?php echo $wetter[1]["day"];?></td>
	<td style="background-color: #9999ff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[1]["am"];?></td>
	<td style="background-color: #9999ff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[1]["noon"];?></td>
	<td style="background-color: #9999ff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[1]["pm"];?></td>
</tr>
<tr>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="160" align="right"><?php echo $wetter[2]["day"];?></td>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[2]["am"];?></td>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[2]["noon"];?></td>
	<td style="background-color: #ccccff; padding-top: 5px; padding-right: 5px; padding-bottom: 5px; text-align: right;" width="180" align="right" valign="top"><?php echo $wetter[2]["pm"];?></td>
</tr>
</table>




<?php
function dowetter($cachefile) {
	$uri = "http://www.wetteronline.de/cgi-bin/citywind?WMO=10737&LANG=de&BKM=Baden-Wuerttemberg/Baden-Baden&SID=w";
	$getstuff = file_get_contents($uri);
	$getstuff = eregi_replace(".*\<b\>Wind in der Region Baden-Baden\<\/b\>\<\/font\>\<\/td\>","",$getstuff);
	$getstuff = eregi_replace("Beaufort.*","",$getstuff);
	$getstuff = eregi_replace(".*class=\"navitable\"\>","",$getstuff);
	$getstuff = eregi_replace("\<font face=\"Arial,Helvetica\" size=\"2\"\>","",$getstuff);
	$getstuff = eregi_replace("\<\/font\>","",$getstuff);
	$getstuff = eregi_replace("\<\/b\>","",$getstuff);
	$getstuff = eregi_replace("\<b\>","",$getstuff);
	$getstuff = eregi_replace("height=\"..\" ","",$getstuff);
	$getstuff = eregi_replace("align=\"center\" ","",$getstuff);
	$getstuff = eregi_replace("valign=\"middle\" ","",$getstuff);
	$getstuff = eregi_replace("align=\"right\" ","",$getstuff);
	$getstuff = eregi_replace("&nbsp;"," ",$getstuff);
	$getstuff = eregi_replace("\t"," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace("  "," ",$getstuff);
	$getstuff = eregi_replace(" \<","<",$getstuff);
	$getstuff = eregi_replace("\<font color=\"#ff0000\"\>","",$getstuff);
	$getstuff = eregi_replace(" width=\"...\"","",$getstuff);
	$getstuff = eregi_replace(" class=\"whiterow\"","",$getstuff);
	$getstuff = eregi_replace("\<tr\>"," ",$getstuff);
	$getstuff = eregi_replace("\<\/tr\>"," ",$getstuff);
	$getstuff = eregi_replace("\<\/td\>"," ",$getstuff);
	$getstuff = eregi_replace("\<br\>","|",$getstuff);
	$getstuff = eregi_replace("\n","",$getstuff);
	$getstuff = eregi_replace("\<td colspan=\"4\"\>.*","",$getstuff);
	$getstuff = eregi_replace("Böen\|","Böen",$getstuff);
	//echo "<textarea style=\"width: 800px; height: 500px;\">";
	//echo $getstuff;
	// echo "</textarea>";
	$f=file_put_contents($cachefile, $getstuff);
}