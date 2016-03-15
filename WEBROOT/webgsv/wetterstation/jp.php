<?php
if($_GET["eis"] == "da") {
    header('Content-Type: image/jpeg');
    $imageFile = imagecreatefromjpeg($_SERVER["DOCUMENT_ROOT"]."/_extphp/wetterstation/pix/eis3.jpg");
    imagejpeg($imageFile);
    imagedestroy($imageFile);
    exit;
}
header('Content-Type: image/jpeg');
$imageFile = imagecreatefrompng($_GET["img"]."?".$_GET["sdate"]);
imagejpeg($imageFile);
imagedestroy($imageFile);
exit;
?>
