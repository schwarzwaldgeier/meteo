<?php
    @require_once($_SERVER["DOCUMENT_ROOT"]."/inc/parse_request.inc.php");
	@require_once($_SERVER["DOCUMENT_ROOT"]."/sensitive.php");

	$sensitive = ParseSensitive("../../.sensitive");
    parse_request($_GET);

	$error = "";
	if(strlen($_GET["ws"])<1) { 	$error .= "no windspeed. "; $error = 1; }
	if(strlen($_GET["ows"])<1) { 	$error .= "no original windspeed. "; $error = 1; }
	if(strlen($_GET["wd"])<1) { 	$error .= "no winddirection. "; $error = 1; }
	if(strlen($_GET["owd"])<1) { 	$error .= "no original wind direction. "; $error = 1; }
	if(strlen($_GET["te"])<1) { 	$error .= "no temperature. "; $error = 1; }
	if(strlen($_GET["pr"])<1) { 	$error .= "no pressure. "; $error = 1; }
	if(strlen($_GET["ms"])<1) { 	$error .= "no max windspeed. "; $error = 1; }
	if(strlen($_GET["oms"])<1) { $error .= "no original max windspeed. "; $error = 1; }
	if(strlen($_GET["wc"])<1) { $error .= "no windchill. "; $error = 1; }
	if(strlen($_GET["hu"])<1) { $error .= "no humidity. "; $error = 1; }

      /*
      Test von Timm 
      */
      $inputDate = $_GET['xtsd'] ;
      $inputTime = $_GET['xtst'];  

	  
	  
      /*
      $newDate = date("Y-m-d", strtotime(str_replace('.', '-', $inputDate)) );
      */      
      $newDate = date("Y-m-d", strtotime($inputDate) );
      $writeTS = $newDate." ".$inputTime;
      
	if(empty($error)) {
		
		$url = 'http://openweathermap.org/data/post';
		
		

		$username = $sensitive['SENSITIVE_OPENWEATHERMAP_USERNAME'];
		$password = $sensitive['SENSITIVE_OPENWEATHERMAP_PASSWORD'];
		
		$postdata = array(
			"wind_dir" => 	($_GET["wd"]),
			"wind_speed" => sprintf(floatval($_GET["ows"]) * 0.27777777777778), //kph to m/s
			"wind_gust" => 	sprintf(floatval($_GET["oms"]) * 0.27777777777778),
			"temp" => 		$_GET["te"],
			"humidity" => 	$_GET["hu"],
			"pressure" =>	$_GET["pr"],
			"lat" =>		"48.764444",
			"long" =>		"8.280556",
			"alt" =>		"700",
			"name" =>		$sensitive['SENSITIVE_OPENWEATHERMAP_STATIONNAME'],
		
		);
		
		
		// create a new cURL resource
		$myRequest = curl_init($url);

		// do a POST request, using application/x-www-form-urlencoded type
		curl_setopt($myRequest, CURLOPT_POST, TRUE);
		// credentials
		curl_setopt($myRequest, CURLOPT_USERPWD, "$username:$password");
		// returns the response instead of displaying it
		
		curl_setopt($myRequest, CURLOPT_POSTFIELDS, $postdata);
		curl_setopt($myRequest, CURLOPT_RETURNTRANSFER, 1);

		// do request, the response text is available in $response
		$response = curl_exec($myRequest);
		// status code, for example, 200
		$statusCode = curl_getinfo($myRequest, CURLINFO_HTTP_CODE);
		
		

		// close cURL resource, and free up system resources
		curl_close($myRequest);
		print $statusCode.": ";
		print $response;
		

		$context  = stream_context_create($options);
		$result = file_get_contents($url, false, $context);
		var_dump($result);
		
		
	} else {
		print " OWM ERROR: $error $response";

	}
	if(empty($error)) {
		echo "Das hat funktioniert";
	} else {
		echo "ERROR: $error";
	}


?>


