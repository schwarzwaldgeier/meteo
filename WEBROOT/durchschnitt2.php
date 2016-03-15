<?php

function isMobileDevice()
{
    
    return false;
    
}

function WindDirectionColor ($wdir)
{
		define("WRED", "#660000");
		define("WGREEN", "#006600");
		define("WYELLOW", "#ffff99");
		define("SYELLOW", "#666600");
		define("SRED", "#FF9999");
		define("SGREEN", "#CCFFCC");
		
	//West:
		if (($wdir >= 181) && ($wdir <= 219)) { //181 - 219
            $columnColor = WYELLOW;     
        }
        else if (($wdir >= 220) && ($wdir <= 300)) { //220 - 300
            $columnColor = WGREEN;
        }
        else if (($wdir >= 301) && ($wdir <= 330)) { //301 - 330
            $columnColor = WYELLOW;
        } 
		
      	//SP Nordost
        else if (($wdir >= 10) && ($wdir <= 19)) {
            $columnColor = WYELLOW;  
        }
        else if (($wdir >= 20) && ($wdir <= 50)) {
            $columnColor = WGREEN;    
        }
        else if (($wdir >= 51) && ($wdir <= 60)) {
            $columnColor = WYELLOW;    
        }
		else $columnColor = SRED;
		return $columnColor;
}

function WindDirectionNormalName ($direction)
{
	$d = $direction;
	$sectorSize = 22.5;
	
	//N
	if (
		($d>=360-1*($sectorSize/2) && $d<=360) 
		|| //360er-Übertrag
		($d>=0 && $d< 1*($sectorSize/2)) 
		)
		$w = "N";
	//NNO
	else if ($d>=1*($sectorSize/2) && $d< 3*($sectorSize/2)) 
		$w = "NNO";
	
	//NO
	else if ($d>=3*($sectorSize/2) && $d< 5*($sectorSize/2)) 
		$w = "NO";
	
	//ONO
	else if ($d>=5*($sectorSize/2) && $d< 7*($sectorSize/2)) 
		$w = "ONO";
	//O
	else if ($d>=7*($sectorSize/2) && $d< 9*($sectorSize/2)) 
		$w = "O";
	//OSO
	else if ($d>=9*($sectorSize/2) && $d< 11*($sectorSize/2)) 
		$w = "OSO";
	//SO
	else if ($d>=11*($sectorSize/2) && $d< 13*($sectorSize/2)) 
		$w = "SO";
	//SSO
	else if ($d>=13*($sectorSize/2) && $d< 15*($sectorSize/2)) 
		$w = "SSO";
	//S
	else if ($d>=15*($sectorSize/2) && $d< 17*($sectorSize/2)) 
		$w = "S";
	//SSW
	else if ($d>=17*($sectorSize/2) && $d< 19*($sectorSize/2)) 
		$w = "SSW";
	//SW
	else if ($d>=19*($sectorSize/2) && $d< 21*($sectorSize/2)) 
		$w = "SW";
	//WSW
	else if ($d>=21*($sectorSize/2) && $d< 23*($sectorSize/2)) 
		$w = "WSW";
	//W
	else if ($d>=23*($sectorSize/2) && $d< 25*($sectorSize/2)) 
		$w = "W";
	//WNW
	else if ($d>=25*($sectorSize/2) && $d< 27*($sectorSize/2)) 
		$w = "WNW";
	//NW
	else if ($d>=27*($sectorSize/2) && $d< 29*($sectorSize/2)) 
		$w = "NW";
	//NNW
	else if ($d>=29*($sectorSize/2) && $d< 31*($sectorSize/2)) 
		$w = "NNW";
	else
		$w = "-";
		
return $w;	
}

function WindSpeedColor($speed) //Weist Windgeschwindigkeiten eine Farbe zu. 40 km/h ist schließlich nicht startbar, nur weil er schön aus West kommt - Sebastian
{
		define("WRED", "#660000");
		define("WGREEN", "#006600");	
		define("WYELLOW", "#ffff99");
		define("SRED", "#FF9999");
		
	$limitEasy = 15; 		$colorEasy = WGREEN;
	$limitModerate = 20; 	$colorModerate = WYELLOW;
							$colorHard = SRED;						
	//Subjektive Einschätzung meinerseits. 
	
	if ($speed <= $limitEasy)
		$color=$colorEasy;
	else if ($speed <= $limitModerate)
		$color = $colorModerate;
	else 
		$color = $colorHard;
		
return $color;	
}

function DisplayWindDirectionArrow($direction)
{
    if ($direction >= 0 && $direction <= 360) {
?>
		<svg width="32px" height="32px" xmlns="http://www.w3.org/2000/svg">
			<g>
				<title>Windrichtung</title>
				<g transform="rotate(<?php
        echo round($direction, 0);
?>, 16, 16)" >
					<path fill="#000000" d="m21,4l-10,0l5,24"/>
				</g>
			</g>
		</svg>
		
		
		<?php
        
        echo "&nbsp;";
        echo round($direction, 0) . "&#x00b0;&nbsp;(".WindDirectionNormalName($direction).")";
		//echo round($direction, 0) . "&#x00b0;";
    } else {
        echo "-"; //Wert nicht feststellbar / Nullwind
        //echo '<!--  Fehlerhafte Windrichtung: ' . $direction . ' -->';
    }
}

?>

<?php
@require_once($_SERVER["DOCUMENT_ROOT"] . "/inc/parse_request.inc.php");
@require_once($_SERVER["DOCUMENT_ROOT"] . "/inc/php_mysql.php");
parse_request($_GET);
?>

<?php

if ($_COOKIE["gei"] != "ichbineingeier") {
    $wrefer = $_SERVER["HTTP_REFERER"];
    $void   = mysql_select_db($db);
    if (!(empty($_REQUEST["jalUserName"]))) {
        $wname = $_REQUEST["jalUserName"];
    } else {
        $wname = "";
    }
    $wbrowser = $_SERVER["HTTP_USER_AGENT"];
    $wquery   = "INSERT INTO redir_stats (uname,ubrause,urefer) values ('$wname','$wbrowser','$wrefer')";
    if ($void != 1) {
        $error .= "could not select database $db !!!!";
    }
    $wresult = mysql_query($wquery);
    if ($wresult != 1) {
        $error .= "could not issue sql-statement ($wquery) !!!!";   
    }
}
?>

<?php
$dat120   = rawdata_avg(120);
$vereist  = "";
$checkeis = false;
?>



<?php

if (!(empty($_GET["rec_count"]))) {
    $rec_count = $_GET["rec_count"];
} else {
    $rec_count = 10;
}
if (!(empty($_GET["avg_hours"]))) {
    $avg_hours = $_GET["avg_hours"];
} else {
    $avg_hours = 2;
}
if (!(empty($_GET["sdate"]))) {
    $sdate = $_GET["sdate"];
} else {
    $sdate = date("Y-m-d");
}


define("WRED", "#660000");
define("WGREEN", "#006600");
define("SYELLOW", "#666600");
define("SRED", "#FF9999");
define("SGREEN", "#CCFFCC");
define("WYELLOW", "#ffff99");

/*

define("WRED", "red");
define("WGREEN", "green");
define("SYELLOW", "yellow");
define("SRED", "red");
define("SGREEN", "green");
define("WYELLOW", "yellow");
*/

?>


<?php
function last_records($rcount)
{
    //check, ob wir die Tabelle kleiner brauchen
   
}    
?>


<?php
if ($sdate == date("Y-m-d")) {
    if (!$vereist) {
        last_records($rec_count);
    }
?>

<?php
    if (isMobileDevice())
        echo '<div class="responsive">';
?>
<br>	  
     <table style="width: 96%; border: 1px #0000ff solid; line-height: 15px; ">
    		<strong>Durchschnittswerte</strong>

    		<tr>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="15%" valign="top">Windrichtung</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="10%" valign="top">Geschw.</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="10%" valign="top">B&ouml;e</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="15%" valign="top">Luftdruck</td>
    		<td style="color: #ffffff; background-color: #0000ff; text-align:right;" align="right" width="25%" valign="top">Mess-Zeit</td>    		
            </tr>


<?php
    if ($vereist) {
?>
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
<!--
            <td align="right" valign="top">0&#x00b0;&nbsp;C</td>
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
<?php
    } else {

        data_avg(20);
        data_avg(60);  
        data_avg(120);
    }
?>
	</table><?php
    if (isMobileDevice())
        echo '</div>';
?>

<br>

<?php
}
?>
<!-- Test --!>
</td>
</tr></div>


<?php

function data_avg($mins)
{
    $ws          = 0;
    $te          = 0;
    $pr          = 0;
    $ms          = 0;
    $wd_u        = 0;
    $wd_v        = 0;
    $wd_w        = 0;
    $mytime      = time() - $mins * 60;
    #$query = "SELECT avg(wind_speed) as wind_speed,avg(wind_direction) as wind_direction from weather_merkur2 where tstamp > $mytime limit 1";
    $query       = "SELECT wind_speed, wind_direction, temperature, pressure, wind_maxspeed from weather_merkur2 where tstamp > $mytime";
    $void        = mysql_select_db($db);
    $result      = mysql_query($query);
    $anzkomplett = @mysql_num_rows($result);
    $x           = $anzkomplett - 1;
    $recs        = $anzkomplett;
    if ($recs > 0) {
        for ($i = 0; $i < $anzkomplett; $i++) {
            $void  = mysql_data_seek($result, $i);
            $array = mysql_fetch_array($result, MYSQL_ASSOC);
            $wd_u += sin(round($array["wind_direction"], 0) * M_PI / 180);
            $wd_v += cos(round($array["wind_direction"], 0) * M_PI / 180);
            $ws += round($array["wind_speed"], 0);
            $te += round($array["temperature"], 0);
            $pr += round($array["pressure"], 0);
            $recs = $array["recs"];
            if ($array["wind_maxspeed"] > $ms) {
                $ms = round($array["wind_maxspeed"], 0);
            }   
        }      
        $wd_u = $wd_u / $anzkomplett;
        $wd_v = $wd_v / $anzkomplett;
        $wd_w = atan2(abs($wd_u), abs($wd_v)) * 180 / M_PI;
        
        if (($wd_u >= 0) && ($wd_v >= 0)) {
            $wd_w = $wd_w;
        }
        if (($wd_u >= 0) && ($wd_v < 0)) {
            $wd_w = 180 - $wd_w;
        }
        if (($wd_u < 0) && ($wd_v >= 0)) {
            $wd_w = 360 - $wd_w;
        }
        if (($wd_u < 0) && ($wd_v < 0)) {
            $wd_w = 180 + $wd_w;
        }
        $wd_w = round($wd_w, 0);
        $ws   = round($ws / $anzkomplett);
        $te   = round($te / $anzkomplett);
        $pr   = round($pr / $anzkomplett);
    }
    
    $arr["wd"] = $wd_w;
    $arr["ws"] = $ws;
    $arr["te"] = $te;
    $arr["pr"] = $pr;
    $arr["ms"] = $ms;
    
    //return $arr;
    
    //$fcol = WRED;  
?>
    		<tr style="background-color: #cccccc; color:black; font-weight: bold">
                <td style="color: black; font-weight: bold; text-align:right; background-color: <?php echo WindDirectionColor($array["wind_direction"]); ?>" align="right" valign="top">
                <?php
        DisplayWindDirectionArrow($array["wind_direction"]);
    ?></td>
                <td style="text-align:right; background-color: <?php echo WindSpeedColor(round($array["ws"], 0)) ?>;" valign="top"><?php
        echo $arr["ws"];
    ?>&nbsp;km/h</td>
                <td style="text-align:right;" valign="top" background-color: <?php echo WindSpeedColor(round($array["ms"], 0)) ?>;" valign="top"><?php
        echo $arr["ms"];
    ?>&nbsp;km/h</td>
    <!--
                <td align="right" valign="top"><?php
        echo $arr["te"];
    ?>&#x00b0;&nbsp;C</td>
    -->
                <td style="text-align:right;" valign="top"><?php
        echo $arr["pr"];
    ?> hpa</td>
                <td style="text-align:right;" valign="top">letzte <?php
        echo $mins;
    ?> Minuten</td>
    		
            </tr>

<?php 
} ?>


<?php

function rawdata_avg($mins)
{
    $ws           = 0;
    $te           = 0;
    $pr           = 0;
    $ms           = 0;
    $wd_u         = 0;
    $wd_v         = 0;
    $wd_w         = 0;
    $mytime       = time() - $mins * 60;
    $query        = "SELECT min(wind_speed) mis, max(wind_speed)mas, min(wind_direction) mid, max(wind_direction) mad from weather_merkur2 where tstamp > $mytime";
    $void         = mysql_select_db($db);
    $result       = mysql_query($query);
    $void         = mysql_data_seek($result, 0);
    $array        = mysql_fetch_array($result, MYSQL_ASSOC);
    $arr["wdmin"] = $array["mid"];
    $arr["wdmax"] = $array["mad"];
    $arr["wsmin"] = $array["mis"];
    $arr["wsmax"] = $array["mas"];
    return $arr;
}

?>
</div>
