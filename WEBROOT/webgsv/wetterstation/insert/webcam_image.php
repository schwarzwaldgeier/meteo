<?php
$verzeichnis = $_SERVER["DOCUMENT_ROOT"] . "/_extphp/wcam/"; 

$ex = "";
if ( time() < date_sunrise(time(), SUNFUNCS_RET_TIMESTAMP, 48.45, 8.14, 90, date("O")/100) ) {
	$ex = 1;
}
if ( time() > date_sunset(time(), SUNFUNCS_RET_TIMESTAMP, 48.45, 8.14, 90, date("O")/100) ) {
	$ex = 1;
}

if ($ex) {
	echo "we are not in time...";
} else {

   	$xxmin = ceil(date("i") / 5) * 5;
	if ($xxmin == 60) { $xxmin = 59; }
	$xxmin = str_pad($xxmin,2,"0",STR_PAD_LEFT);
   	$xxdate = date("Y-m-d_H")."-".$xxmin;
	$co = 0;
	if (file_exists($verzeichnis . date("Ymd") . "/$xxdate"."_windfaehnl.jpg")) { $co = $co + 1; }
	if (file_exists($verzeichnis . date("Ymd") . "/$xxdate"."_baden-baden.jpg")) { $co = $co + 1; }
	if (file_exists($verzeichnis . date("Ymd") . "/$xxdate"."_battert.jpg")) { $co = $co + 1; }

	if ($co < 3) {
        $ch = curl_init("http://213.144.29.4/snap.jpg?JpegSize=XL");
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_BINARYTRANSFER,1);
        $rawdata=curl_exec($ch);
        curl_close ($ch);
        $imageFile = imagecreatefromstring($rawdata);
        $ri = imagecreatetruecolor(535,438);
        $im = imagecreatetruecolor(300,25);
        $th = imagecreatetruecolor(85,70);
        ImageCopy ($im, $imageFile, 0,0,200,431,330,25);
        imagecopyresampled  ($th, $imageFile, 0, 0, 0, 0, 85, 70, 704, 576);
        imagecopyresampled  ($ri, $imageFile, 0, 0, 0, 0, 535, 438, 704, 576);
        echo writeCamImage($verzeichnis,$im,$imageFile,$th,$ri);
        imagedestroy($imageFile);
        imagedestroy($im);
        imagedestroy($th);
        exit;
	}
}


function writeCamImage($verz,$ihandle,$ohandle,$thandle,$rhandle) {
    	$img = "";
        if ( imagecolorat($ihandle,271,3) < 5000000 && imagecolorat($ihandle,271,3) > 3000000 ) {
    		$img = "windfaehnl";
    		$txt = "Startplatz West";
        }  
        if ( imagecolorat($ihandle,2,2) < 5000000 && imagecolorat($ihandle,2,2) > 3000000 ) {
    		$img = "battert";
    		$txt = "Fahnen / Battert";
        }  
        if ( imagecolorat($ihandle,69,19) < 5000000 && imagecolorat($ihandle,69,19) > 3000000 ) {
    		$img = "baden-baden";
    		$txt = "Baden-Baden";
        }  
    	if($img) {
            	$xmin = ceil(date("i") / 5) * 5;
            	if ($xmin == 60) { $xmin = 59; }
            	$xmin = str_pad($xmin,2,"0",STR_PAD_LEFT);
            	$xdate = date("Y-m-d_H")."-".$xmin;
            	$ydate = date("d.m.Y H").":".$xmin;
                $xdir = $verz . date("Ymd");
                if (!is_dir($xdir)) { mkdir($xdir,0777); chmod($xdir,0777); }
                $xdir = $xdir . "/";
    			if (!file_exists($xdir . "$xdate"."_".$img.".jpg")) {
    		    	
    		    	imagefilledrectangle($rhandle,0,0,535,15,7000000);
        			imagestring($rhandle, 5, 0, 0, "Webcam-Bild " . $ydate . " (".$txt.")", 0);
    			    imagejpeg($rhandle,$xdir . "$xdate"."_".$img.".jpg",65);
    		    	chmod($xdir . "$xdate"."_".$img.".jpg",0777);
    		    	imagejpeg($thandle,$xdir . "thumb_$xdate"."_".$img.".jpg",75);
    		    	chmod($xdir . "thumb_$xdate"."_".$img.".jpg",0777);
    		    }
    	}

    	return $img;
}

?>


