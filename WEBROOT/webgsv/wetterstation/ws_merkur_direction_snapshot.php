<?php
/*
if($_GET["eis"] == "da") {
    header('Content-Type: image/jpeg');
    $imageFile = imagecreatefromjpeg($_SERVER["DOCUMENT_ROOT"]."/_extphp/wetterstation/pix/eis2.jpg");
    imagejpeg($imageFile);
    imagedestroy($imageFile);
    exit;
}
*/
?>
<?php
	$anzkomplett = 0;

    @require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/parse_request.inc.php");
	@require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/php_mysql.php");
    parse_request($_GET);
	if(!(empty($_GET["injection"]))) { $injection = $_GET["injection"]; } else { $injection = time(); }


 function last_records($rcount) {
		global $datax;
		global $datay;
		global $maxspeed;
		global $wbeg;
		global $wend;
		global $anzkomplett;
		global $sdate;

		global $injection;
		$inj1 = $injection - 10*60;
		$inj2 = $injection + 10*60;
    	$query = "SELECT * from weather_merkur where tstamp > $inj1 and tstamp < $inj2 order by uid desc";
		$maxspeed = 0;;
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$x = $anzkomplett - 1;
    	for ($i=0; $i < $anzkomplett; $i++) {
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);
			$datay[$x] = $array["wind_direction"];
//			if ($array["wind_speed"] > $maxspeed) { $maxspeed = $array["wind_speed"]; }
    		$datax[$x] = $array["tstamp"];
    		if($i == 0) { $wend = $array["tstamp"]; }
    		$wbeg = $array["tstamp"];
    		$x--;
    	}
    	$maxspeed = $maxspeed + 5;
 }
include ($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/jpgraph/src/jpgraph.php");
include ($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/jpgraph/src/jpgraph_scatter.php");
last_records(200);


// The callback that converts timestamp to minutes and seconds
function TimeCallback($aVal) {
    return Date('H:i:s',$aVal);
}

// Setup the basic graph
$graph = new Graph(540,447,"auto",3);
$graph->SetMargin(30,10,50,70);



$graph->SetBackgroundImage("pix/typo_direction.png",BGIMG_FILLPLOT);
$graph->AdjBackgroundImage(0,0);
$graph->img->SetAntiAliasing("white");



$graph->title->Set('Merkur Windrichtungs-Sensor');
$graph->subtitle->Set(date('d.m.Y H:i:s',$wbeg).' - '.date('d.m.Y H:i:s',$wend));
$graph->SetAlphaBlending();

// Setup a manual x-scale (We leave the sentinels for the
// Y-axis at 0 which will then autoscale the Y-axis.)
// We could also use autoscaling for the x-axis but then it
// probably will start a little bit earlier than the first value
// to make the first value an even number as it sees the timestamp
// as an normal integer value.
$graph->SetScale("intlin",0,360,$datax[0],$datax[$anzkomplett - 1]);

$graph->yaxis->scale->ticks->Set(10); // Set major and minor tick to 10



// Setup the x-axis with a format callback to convert the timestamp
// to a user readable time
$graph->xaxis->SetLabelFormatCallback('TimeCallback');
$graph->xaxis->SetLabelAngle(90);


// Create the line
$p1 = new ScatterPlot($datay,$datax);



//$p1 = new LinePlot($datay,$datax);
//$p1->SetColor("#1FE55C");

// Set the fill color partly transparent
//$p1->SetFillColor("#1FE55C@0.6");

// Add lineplot to the graph
$graph->Add($p1);

// Output line
$graph->Stroke();
?>




