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

<div data-role="collapsible">
   <h3>Forecast 3 Tage</h3>
	
		<div class="ui-grid-c">
			<div class="ui-block-a"><div class="ui-bar ui-bar-b" >Tag</div></div>
			<div class="ui-block-b"><div class="ui-bar ui-bar-b" >Vorm.</div></div>
			<div class="ui-block-c"><div class="ui-bar ui-bar-b" >Nachm.</div></div>
			<div class="ui-block-d"><div class="ui-bar ui-bar-b" >Abend</div></div>

    		<div class="ui-block-a"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[0]["day"]);?></div></div>
    		<div class="ui-block-b"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[0]["am"]);?></div></div>
    		<div class="ui-block-c"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[0]["noon"]);?></div></div>
    		<div class="ui-block-d"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[0]["pm"]);?></div></div>

    		<div class="ui-block-a"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #9999ff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[1]["day"]);?></div></div>
    		<div class="ui-block-b"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #9999ff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[1]["am"]);?></div></div>
    		<div class="ui-block-c"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #9999ff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[1]["noon"]);?></div></div>
    		<div class="ui-block-d"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #9999ff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[1]["pm"]);?></div></div>

    		<div class="ui-block-a"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[2]["day"]);?></div></div>
    		<div class="ui-block-b"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[2]["am"]);?></div></div>
    		<div class="ui-block-c"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[2]["noon"]);?></div></div>
    		<div class="ui-block-d"><div class="ui-bar ui-bar-d" style="height: 120px; background-color: #ccccff !important; background-image: none !important; text-align:right;"><?php echo dobr($wetter[2]["pm"]);?></div></div>

	</div>		
</div>





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

function dobr($istr) {
//	if(!(eregi("\<br\>",$istr))) {
//		$istr .= "<br>&nbsp;";
//	}
	return $istr;
}
?>