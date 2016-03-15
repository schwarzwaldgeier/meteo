<?php
	if(!(empty($_GET["injection"]))) { $injection = $_GET["injection"]; } else { $injection = time(); }
?>
<html>
<head>
<title>Wetterstation Merkur</title>
<link href="http://www.gsvbaden.de/templates/rhuk_solarflare_ii/css/template_css.css" rel="stylesheet" type="text/css" />
</head>
<body topmargin="0" leftmargin="0">
<h3>Merkur-Wetterstation Snapshot</h3>
<img src="http://www.gsvbaden.de/_extphp/wetterstation/ws_merkur_speed_snapshot.php?injection=<?php echo $injection;?>">
<br>
<img src="http://www.gsvbaden.de/_extphp/wetterstation/ws_merkur_direction_snapshot.php?injection=<?php echo $injection;?>">
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-1395385-3";
urchinTracker();
</script>


</body>
</html>


