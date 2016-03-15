<?php

function isMobileDevice()
{
    return false;    
}


@require_once($_SERVER["DOCUMENT_ROOT"] . "/inc/parse_request.inc.php");
@require_once($_SERVER["DOCUMENT_ROOT"] . "/inc/php_mysql.php");
parse_request($_GET);


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

$dat120   = rawdata_avg(120);
$vereist  = "";
$checkeis = false;



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
}
?>


<img width="540" alt="Windrichtungs-Messung Wetterstation Merkur" src="http://www.schwarzwaldgeier.de/_extphp/wetterstation/typo_w-direction.php?sdate=<?php
echo $sdate; echo $vereist;?>">


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

