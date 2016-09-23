
<?php
/*
Get and parse content of .sensitive because I don't speak python enough to use it ;)
outputs an associative array named $sensitive like 
	[ROUTER_IP] => 1.1.1.1
    [ROUTER_PW] => *****
    [ANDROIDNOTIFY_APIKEY] => "********************"
    [SENSITIVE_BERGRECHNER_URL] => "********************"
    [SENSITIVE_GSVHOME_URL] => "********************"
    [SENSITIVE_GSVHOME_USER] => "********************"
    [SENSITIVE_GSVHOME_PW] => "********************"
    [SENSITIVE_LENKUNG_URL] => "********************"
    [SENSITIVE_LENKNUG_USER] => "********************"
    [SENSITIVE_LENKNUG_PW] => "********************"
    [EMAIL_LIST] => "********************"
    [SENSITIVE_OPENWEATHERMAP_URL] => "********************"
    [SENSITIVE_OPENWEATHERMAP_USERNAME] => "********************"
    [SENSITIVE OPENWEATHERMAP_PW] => "********************"
    [SENSITIVE_OPENWEATHERMAP_STATIONNAME] => "********************"


*/

function ParseSensitive($file) {
	$sensitivedebug=false;
	$sensitive;
	$index = array();


	$file = file_get_contents('.sensitive', true);
	$file = preg_replace("/(^[\r\n]*|[\r\n]+)[\s\t]*[\r\n]+/", "\n", $file); //remove blank lines, http://stackoverflow.com/a/709684
	$sensitive = explode("\n", $file);

	foreach($sensitive as $arr) {
		if(!(preg_match("/#/",$arr)) && $arr!="") { // all except comments and blanks
			
			$arr = str_replace("export ", "", $arr)	;
			$contents = explode("=", $arr, 2);
			$index[$contents[0]] = $contents[1];
			$output = $index;
		}
	}
	$sensitive = $output;

	if($sensitivedebug){
		echo "<pre>";
		print_r($sensitive);
		echo "</pre>";

	}

	return $sensitive;

}

?>