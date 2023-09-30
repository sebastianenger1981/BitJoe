<?php

# $CaptchaID		= substr($_REQUEST["id"], 0, 32); 
$CaptchaID		= $_REQUEST["id"]; 
$CaptchaURI		= 'http://captcha.bitjoe.de:2087/MD5STORE/'.$CaptchaID.'.txt';
$CaptchaText	= file_get_contents($CaptchaURI);


$FONT_SIZE      = 23;   // Schriftgröße der Zeichen in Punkt
$IMG_WIDTH      = 170;  // Breite des Bild-Captchas in Pixel
$IMG_HEIGHT     = 70;   // Höhe des Bild-Captchas in Pixel

// Liste aller verwendeten Fonts
$FONTS[] = '/var/www/captcha/Choktoff.ttf';
$FONTS[] = '/var/www/captcha/BNEG98.ttf';

// Wir teilen dem Browser mit, dass er es hier mit einem JPEG-Bild zu tun hat.
header('Content-Type: image/jpeg', true);

// Wir erzeugen ein leeres JPEG-Bild von der Breite IMG_WIDTH und Höhe IMG_HEIGHT
$img = imagecreatetruecolor($IMG_WIDTH, $IMG_HEIGHT);

// Wir definieren eine Farbe mit Zufallszahlen
// Die Farbwerte sind durchgehend und absichtlich hoch (200 - 256) gewählt,
// um eine "leichte" Farbe zu erhalten
$col = imagecolorallocate($img, rand(200, 255), rand(200, 255), rand(200, 255));

// Wir füllen das komplette Bild mit der zuvor definierten Farbe
imagefill($img, 0, 0, $col);


$x = 14; // x-Koordinate des ersten Zeichens, 10 px vom linken Rand


$col = imagecolorallocate($img, rand(0, 199), rand(0, 199), rand(0, 199)); // einen zufälligen Farbwert definieren
$font = $FONTS[rand(0, count($FONTS) - 1)]; // einen zufälligen Font aus der Fontliste FONTS auswählen

$y = 50 + rand(0, 5); // die y-Koordinate mit einem Mindestabstand plus einem zufälligen Wert festlegen
$angle = rand(0, 10); // ein zufälliger Winkel zwischen 0 und 30 Grad

/*
 * Diese Funktion zeichnet die Zeichenkette mit den
 * gegeben Parametern (Schriftgröße, Winkel, Farbe, TTF-Font, usw.)
 * in das Bild.
 */
imagettftext($img, $FONT_SIZE, $angle, $x, $y, $col, $font, $CaptchaText);

$dim = imagettfbbox($FONT_SIZE, $angle, $font, $chr); // ermittelt den Platzverbrauch des Zeichens
$x += $dim[4] + abs($dim[6]) + 10; // Versucht aus den zuvor ermittelten Werten einen geeigneten Zeichenabstand zu ermitteln


imagejpeg($img); // Ausgabe des Bildes an den Browser
imagedestroy($img); // Freigeben von Speicher

exit(0);

?> 