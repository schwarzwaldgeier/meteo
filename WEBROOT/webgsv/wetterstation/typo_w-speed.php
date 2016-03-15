<?php
if($_GET["eis"] == "da") {
    header('Content-Type: image/jpeg');
    $imageFile = imagecreatefromjpeg($_SERVER["DOCUMENT_ROOT"]."/_extphp/wetterstation/pix/eis3.jpg");
    imagejpeg($imageFile);
    imagedestroy($imageFile);
    exit;
}
	$anzkomplett = 0;

    @require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/parse_request.inc.php");
	@require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/php_mysql.php");
    parse_request($_GET);
	if(!(empty($_GET["rec_count"]))) { $rec_count = $_GET["rec_count"]; } else { $rec_count = 10; }
	if(!(empty($_GET["avg_hours"]))) { $avg_hours = $_GET["avg_hours"]; } else { $avg_hours = 1; }

	if(!(empty($_GET["sdate"]))) { $sdate = $_GET["sdate"]; } else { $sdate = date("Y-m-d"); }

function last_records($rcount) {
		global $datax;
		global $datay;
		global $datay2;
		global $maxspeed;
		global $wbeg;
		global $wend;
		global $anzkomplett;
		global $sdate;
		$maxspeed = 0;
    	$query = "SELECT * from weather_merkur2 where record_datetime like '".$sdate."%' order by uid desc";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$x = $anzkomplett - 1;
    	for ($i=0; $i < $anzkomplett; $i++) {
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);
			$datay[$x] = round($array["wind_speed"],0);
			if ($array["max_speed"] < 1) {
				$boe = 0;
			} else {
				$boe = $array["max_speed"];
			}
			$datay2[$x] = round($boe,0);
			if ($array["wind_speed"] > $maxspeed) { $maxspeed = $array["wind_speed"]; }
			if ($array["max_speed"] > $maxspeed) { $maxspeed = $array["max_speed"]; }
    		$datax[$x] = $array["tstamp"];
    		if($i == 0) { $wend = $array["tstamp"]; }
    		$wbeg = $array["tstamp"];
    		$x--;
    	}
    	$maxspeed = $maxspeed + 1;
 }
include ($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/jpgraph/src/jpgraph.php");
include ($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/jpgraph/src/jpgraph_line.php");



// The callback that converts timestamp to minutes and seconds
function TimeCallback($aVal) {
    return Date('H:i:s',$aVal);
}

// Fake some suitable random data
/*
$now = time();
$datax = array($now);
for( $i=0; $i < 360; $i += 10 ) {
    $datax[] = $now + $i;
}




$n = count($datax);
$datay=array();
for( $i=0; $i < $n; ++$i ) {
    $datay[] = rand(30,150);
}

*/

// Setup the basic graph
$graph = new Graph(540,344,"auto",3);
$graph->SetMargin(30,30,50,70);

//$graph->img->SetImgFormat('jpg');


last_records(200);


//$graph->SetBackgroundImage("pix/merkur4.jpg",BGIMG_FILLPLOT);
//$graph->AdjBackgroundImage(0,0);
//$graph->img->SetAntiAliasing("white");



$graph->title->Set('Merkur Windgeschwindigkeits-Sensor (km/h)');
$graph->subtitle->Set(date('d.m.Y H:i:s',$wbeg).' - '.date('d.m.Y H:i:s',$wend));
$graph->SetAlphaBlending();

// Setup a manual x-scale (We leave the sentinels for the
// Y-axis at 0 which will then autoscale the Y-axis.)
// We could also use autoscaling for the x-axis but then it
// probably will start a little bit earlier than the first value
// to make the first value an even number as it sees the timestamp
// as an normal integer value.
$graph->SetScale("intlin",0,$maxspeed,$datax[0],$datax[$anzkomplett - 1]);
$graph->SetY2Scale("int",0,$maxspeed,$datax[0],$datax[$anzkomplett - 1]);

// Setup the x-axis with a format callback to convert the timestamp
// to a user readable time
$graph->xaxis->SetLabelFormatCallback('TimeCallback');
$graph->xaxis->SetLabelAngle(90);
$graph->AddLine(new PlotLine(HORIZONTAL,20,"#ff0000",1));

// Create the line
$p1 = new LinePlot($datay,$datax);
$p1->SetColor("#1FE55C");
// Set the fill color partly transparent
$p1->SetFillColor("#1FE55C@0.6");


$p2 = new LinePlot($datay2,$datax);
$p2->SetColor("#FF0000");
$p2->SetStyle("dotted");



// Add lineplot to the graph
$graph->Add($p1);
$graph->Add($p2);


// Output line
$graph->Stroke();
?>




