<?php

# phpinfo();

    $CAPTCHA_LENGTH = 6;    // Länge der Captcha-Zeichenfolge, hier fünf Zeichen
    $FONT_SIZE      = 23;   // Schriftgröße der Zeichen in Punkt
    $IMG_WIDTH      = 220;  // Breite des Bild-Captchas in Pixel
    $IMG_HEIGHT     = 70;   // Höhe des Bild-Captchas in Pixel

    // Liste aller verwendeten Fonts
	$FONTS[] = '/var/www/captcha/Choktoff.ttf';
	$FONTS[] = '/var/www/captcha/BNEG98.ttf';
	$FONTS[] = '/var/www/captcha/crackdr2.ttf';


    // Unser Zeichenalphabet
    $ALPHABET = array('A', 'B', 'C', 'D', 'E', 'F', 'G',
                      'H', 'Q', 'J', 'K', 'L', 'M', 'N',
                      'P', 'R', 'S', 'T', 'U', 'V', 'Y', '@' ,'!', '?',
                      'W', '0', '1', '2', '3', '4', '5', '6', '7','8', '9');

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

    $captcha = ''; // Enthält später den Captcha-Code als String
    $x = 8; // x-Koordinate des ersten Zeichens, 10 px vom linken Rand


    for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {

        $chr = $ALPHABET[rand(0, count($ALPHABET) - 1)]; // ein zufälliges Zeichen aus dem definierten Alphabet ermitteln
        $captcha .= $chr; // Der Zeichenfolge $captcha das ermittelte Zeichen anfügen

        $col = imagecolorallocate($img, rand(0, 199), rand(0, 199), rand(0, 199)); // einen zufälligen Farbwert definieren
        $font = $FONTS[rand(0, count($FONTS) - 1)]; // einen zufälligen Font aus der Fontliste FONTS auswählen

        $y = 25 + rand(0, 20); // die y-Koordinate mit einem Mindestabstand plus einem zufälligen Wert festlegen
        $angle = rand(0, 30); // ein zufälliger Winkel zwischen 0 und 30 Grad

        /*
         * Diese Funktion zeichnet die Zeichenkette mit den
         * gegeben Parametern (Schriftgröße, Winkel, Farbe, TTF-Font, usw.)
         * in das Bild.
         */
        imagettftext($img, $FONT_SIZE, $angle, $x, $y, $col, $font, $chr);

        $dim = imagettfbbox($FONT_SIZE, $angle, $font, $chr); // ermittelt den Platzverbrauch des Zeichens
        $x += $dim[4] + abs($dim[6]) + 10; // Versucht aus den zuvor ermittelten Werten einen geeigneten Zeichenabstand zu ermitteln
    }

    imagejpeg($img); // Ausgabe des Bildes an den Browser
    imagedestroy($img); // Freigeben von Speicher


	echo $font;
	exit(0);
?> 