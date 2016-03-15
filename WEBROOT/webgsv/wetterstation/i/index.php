<?php
    @require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/parse_request.inc.php");
	@require_once($_SERVER["DOCUMENT_ROOT"]."_extphp/wetterstation/inc/php_mysql.php");
    parse_request($_GET);
	if(!(empty($_GET["sdate"]))) { $sdate = $_GET["sdate"]; } else { $sdate = date("Y-m-d"); }
	if(!(empty($_GET["rec_count"]))) { $rec_count = $_GET["rec_count"]; } else { $rec_count = 10; }
	define("WRED","#660000");
	define("WGREEN","#006600");
	define("SYELLOW","#666600");
	define("SRED","#FF9999");
	define("SGREEN","#CCFFCC");
	define("WYELLOW","#ffff99");

?>
<!DOCTYPE html> 
<html> 
	<head> 
	<title>Merkur-Wetter</title> 
	<meta name="viewport" content="width=device-width, initial-scale=1"> 
	<link rel="stylesheet" href="http://code.jquery.com/mobile/1.1.1/jquery.mobile-1.1.1.min.css" />
	<script src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
	<script src="http://code.jquery.com/mobile/1.1.1/jquery.mobile-1.1.1.min.js"></script>
</head> 
<body> 

<div data-role="page">

	<div data-role="header" data-theme="e">
		<h1>Merkur-Wetter</h1>
	</div><!-- /header -->

	<div data-role="content">	

<div data-role="collapsible-set">
	
	
<div data-role="collapsible">
   <h3>Letzten 10 Messungen</h3>
	
		<div class="ui-grid-d">
			<div class="ui-block-a"><div class="ui-bar ui-bar-b" >WEST</div></div>
			<div class="ui-block-b"><div class="ui-bar ui-bar-b" >KMH</div></div>
			<div class="ui-block-c"><div class="ui-bar ui-bar-b" >BÖE</div></div>
			<div class="ui-block-d"><div class="ui-bar ui-bar-b" >ZEIT</div></div>
			<div class="ui-block-e"><div class="ui-bar ui-bar-b" >NO</div></div>


    <?php
    	$query = "SELECT * from weather_merkur order by uid desc LIMIT $rec_count";
    	$void = mysql_select_db($db);
    	$result = mysql_query($query);
    	$anzkomplett = @mysql_num_rows($result);
    	$fa = 0;
    	for ($i=0; $i < $anzkomplett; $i++) {
    	    if ($fa == 0) {
    	    	$bgs = "#cccccc"; $fa = 1;
    	    } else {
    	    	$bgs = "#dddddd"; $fa = 0;
    	    }
    		$void = mysql_data_seek($result, $i);
    		$array = mysql_fetch_array($result, MYSQL_ASSOC);

			$fcol = WRED;
			$scol = SRED;
    		if(($array["wind_direction"] >= 181) && ($array["wind_direction"] <= 219)) {
    			$scol = WYELLOW; $fcol = SYELLOW;
    		}
    		if(($array["wind_direction"] >= 220) && ($array["wind_direction"] <= 300)) {
    			$scol = WGREEN; $fcol = SGREEN;
    		}
    		if(($array["wind_direction"] >= 301) && ($array["wind_direction"] <= 330)) {
    			$scol = WYELLOW; $fcol = SYELLOW;
    		}

			$nfcol = WRED;
			$nscol = SRED;
    		if(($array["wind_direction"] >= 10) && ($array["wind_direction"] <= 19)) {
    			$nscol = WYELLOW; $nfcol = SYELLOW;
    		}
    		if(($array["wind_direction"] >= 20) && ($array["wind_direction"] <= 50)) {
    			$nscol = WGREEN; $nfcol = SGREEN;
    		}
    		if(($array["wind_direction"] >= 51) && ($array["wind_direction"] <= 60)) {
    			$nscol = WYELLOW; $nfcol = SYELLOW;
    		}


    ?>
    		<div class="ui-block-a"><div class="ui-bar ui-bar-d" style="color: <?php echo $fcol;?>; background-color: <?php echo $scol;?> !important; background-image: none !important; text-align:right;"><?php echo $array["wind_direction"];?>°</div></div>
    		<div class="ui-block-b"><div class="ui-bar ui-bar-d" style="text-align:right;"><?php echo $array["wind_speed"];?></div></div>
    		<div class="ui-block-c"><div class="ui-bar ui-bar-d" style="text-align:right;"><?php echo $array["max_speed"];?></div></div>

<?php if (date("I") == 0) { ?>
<!-- Sommerzeit -->
    		<div class="ui-block-d"><div class="ui-bar ui-bar-d" style="text-align:right;"><?php echo date("H:i",$array["tstamp"]+3600);?></div></div>
<?php } else { ?>
<!-- Winterzeit -->
    		<div class="ui-block-d"><div class="ui-bar ui-bar-d" style="text-align:right;"><?php echo date("H:i",$array["tstamp"]);?></div></div>
<?php } ?>
 
    		<div class="ui-block-e"><div class="ui-bar ui-bar-d" style="color: <?php echo $nfcol;?>; background-color: <?php echo $nscol;?> !important; background-image: none !important; text-align:right;"><?php echo $array["wind_direction"];?>°</div></div>
    <?php
    	}
    ?>
</div>		
</div>
	
	
<div data-role="collapsible">
   <h3>Wind-Speed heute</h3>
   <img width="100%" alt="Windgeschwindigkeits-Messung Wetterstation Merkur" title="Windgeschwindigkeits-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-speed.php?sdate=<?php echo $sdate;?><?php echo $vereist;?>">
</div>
<div data-role="collapsible">
   <h3>Wind-Richtung heute</h3>
   <img width="100%" alt="Windgrichtungs-Messung Wetterstation Merkur" src="http://www.gsvbaden.de/_extphp/wetterstation/typo_w-direction.php?sdate=<?php echo $sdate;?><?php echo $vereist;?>">
</div>

<?php include($_SERVER["DOCUMENT_ROOT"] . "_extphp/wetterstation/WOi.php");?>


</div>
	
	</div><!-- /content -->

</div><!-- /page -->



</body>
</html>