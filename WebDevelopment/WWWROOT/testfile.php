<?php







require_once("/srv/server/wwwroot/lib/functions.inc.php");

echo GetFlatrateValidUntilDateInDays("2008-05-01", 5);

exit;


$MobilePhoneBeauty	= '004916096268734';
$tmp				= $MobilePhoneBeauty;
$tmp = substr($tmp, 0, 4); 

if ( $tmp == '0049' ){
	# low cost sms plus nach deutschland
	
} else{
	# direkt plus nach ausland

}; # if ( $tmp == '0049' ){



/*

require_once("/srv/server/wwwroot/lib/wappush.inc.php");
SendWapPush( "01607979247", "UserPIN", "00491607979247");


 $CAPTCHA_LENGTH = 8;    // Länge der Captcha-Zeichenfolge, hier fünf Zeichen

  // Unser Zeichenalphabet
$ALPHABET = array('A', 'B', 'C', 'D', 'E', 'F', 'G',
				  'H', 'Q', 'J', 'K', 'L', 'M', 'N',
				  'P', 'R', 'S', 'T', 'U', 'V', 'Y',
				  'W', '2', '3', '4', '5', '6', '7');
$code = "";
for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {
	$chr = $ALPHABET[rand(0, count($ALPHABET) - 1)]; // ein zufälliges Zeichen aus dem definierten Alphabet ermitteln
	$code .= strtolower($chr);
};

session_start();
$captchaValidierungOk = false;

if (ereg('^[a-z]{4}$', $_POST['captcha_code']) &&         // eingabe syntaktisch korrekt
   !empty($_SESSION['captcha_code']) &&                   // code in der session
	  ($_SESSION['captcha_code']==$_POST['captcha_code'])) { // session-code = eingabe-code

  $captchaValidierungOk = true;
}

$_SESSION['captcha_code'] = $code;

@include ("http://www.formular-generator.de/captcha/formular.php?captcha_code=$code&v=1q");




echo $string;



    $CAPTCHA_LENGTH = 5;    // Länge der Captcha-Zeichenfolge, hier fünf Zeichen
    $FONT_SIZE      = 18;   // Schriftgröße der Zeichen in Punkt
    $IMG_WIDTH      = 170;  // Breite des Bild-Captchas in Pixel
    $IMG_HEIGHT     = 60;   // Höhe des Bild-Captchas in Pixel

    // Liste aller verwendeten Fonts
   # $FONTS[] = './ttf/kbyte.\ttf';
   # $FONTS[] = './ttf/actionj.\ttf';
    $FONTS[] = '/srv/server/wwwroot/XFILES.TTF';

    // Unser Zeichenalphabet
    $ALPHABET = array('A', 'B', 'C', 'D', 'E', 'F', 'G',
                      'H', 'Q', 'J', 'K', 'L', 'M', 'N',
                      'P', 'R', 'S', 'T', 'U', 'V', 'Y',
                      'W', '2', '3', '4', '5', '6', '7');

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
    $x = 10; // x-Koordinate des ersten Zeichens, 10 px vom linken Rand


    for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {

        $chr = $ALPHABET[rand(0, count($ALPHABET) - 1)]; // ein zufälliges Zeichen aus dem definierten Alphabet ermitteln
        $captcha .= $chr; // Der Zeichenfolge $captcha das ermittelte Zeichen anfügen

        $col = imagecolorallocate($img, rand(0, 199), rand(0, 199), rand(0, 199)); // einen zufälligen Farbwert definieren
        $font = $FONTS[rand(0, count($FONTS) - 1)]; // einen zufälligen Font aus der Fontliste FONTS auswählen

        $y = 25 + rand(0, 20); // die y-Koordinate mit einem Mindestabstand plus einem zufälligen Wert festlegen
        $angle = rand(0, 30); // ein zufälliger Winkel zwischen 0 und 30 Grad

        imagettftext($img, $FONT_SIZE, $angle, $x, $y, $col, $font, $chr);

        $dim = imagettfbbox($FONT_SIZE, $angle, $font, $chr); // ermittelt den Platzverbrauch des Zeichens
        $x += $dim[4] + abs($dim[6]) + 10; // Versucht aus den zuvor ermittelten Werten einen geeigneten Zeichenabstand zu ermitteln
    }

    imagejpeg($img); // Ausgabe des Bildes an den Browser
    imagedestroy($img); // Freigeben von Speicher



exit;

*/

?>