<?php

require_once("/srv/server/wwwroot/lib/validate.inc.php");
require_once("/srv/server/wwwroot/lib/config.inc.php");



# Generate PINs
function generatePasswordForHandyAnmeldung(){

	$passwd = md5(uniqid(rand(), true) . time() );
	$from	= rand(7,32)-7;
	$pin	= strtolower(substr($passwd, $from, 7)); 

	if ( strlen($pin) == 7 ){
		return $pin;
	} else {
		return rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9);
	};

}; # function generatePasswordForHandyAnmeldung(){


function GetFlatrateValidUntilDateInDays( $date, $plus ){	# eg 2007-04-12, 6 days

	if ( strcmp($date,"0000-00-00" ) == 0 ) {
		$date = date("Y-m-d");
	};

	$dateSec 	= strtotime($date);
	$dateNewSec	= $dateSec + ( $plus * 24 * 60 * 60 );	# plus monat in unixtime
	$date		= date("Y-m-d", $dateNewSec);
	return $date;

}; # function GetFlatrateValidUntilDateInDays( $date, $plus ){


function ReadFile_( $FilePath ){

	return file_get_contents($FilePath);

}; # function WriteFile( $FilePath, $FileContent ){


function WriteFile( $FilePath, $FileContent ){

	$fh		= fopen($FilePath, 'wb');
	flock($fh, LOCK_EX);
	 $FileContent = trim( $FileContent);	# \n entfernen
	fwrite($fh,  $FileContent );
	fclose($fh);

	return 1;

}; # function WriteFile( $FilePath, $FileContent ){


function GenerateCatpchaText(){

	$CAPTCHA_LENGTH = 6;

	// Unser Zeichenalphabet
	$ALPHABET = array(	'A', 'B', 'C', 'D', 'E', 'F', 'G',
						'H', 'Q', 'J', 'K', 'L', 'M', 'N',
						'P', 'R', 'S', 'T', 'U', 'V', 'Y', '@' ,'!', '?',
						'W', '0', '1', '2', '3', '4', '5', '6', '7','8', '9');

	$captcha = '';

	for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {

		$captcha .= $ALPHABET[rand(0, count($ALPHABET) - 1)]; // ein zufälliges Zeichen aus dem definierten Alphabet ermitteln
		
	}; # for($i = 0; $i < $CAPTCHA_LENGTH; $i++) {

	return $captcha;

}; # function GenerateCatpchaText(){



function classifyO2Number( $MobilePhoneSimple ){	# 0170 7979271

	$tmp = $MobilePhoneSimple;
	$tmp = substr($tmp, 0, 4); 

	if ( $tmp == '0159' || $tmp == '0176' || $tmp == '0179' ) {
		
		return 1;

	} else {

		return 0;
	
	}; # if ( $tmp == '0159' || $tmp == '0176' || $tmp == '0179' ) {


}; # function classifyO2Number( $MobilePhoneSimple ){	




function check_ip_address($checkip, $jolly_char='') {
    if ($jolly_char=='.')        // dot ins't allowed as jolly char
        $jolly_char = '';
   
    if ($jolly_char!='') {
        $checkip = str_replace($jolly_char, '*', $checkip);        // replace the jolly char with an asterisc
        $my_reg_expr = "^[0-9\*]{1,3}\.[0-9\*]{1,3}\.[0-9\*]{1,3}\.[0-9\*]{1,3}$";
        $jolly_char = '*';
    }
    else
        $my_reg_expr = "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$";
   
    if (eregi($my_reg_expr, $checkip)) {
        for ($i = 1; $i <= 3; $i++) {
            if (!(substr($checkip, 0, strpos($checkip, ".")) >= "0" && substr($checkip, 0, strpos($checkip, ".")) <= "255")) {
                if ($jolly_char!='') {            // if exists, check for the jolly char
                    if (substr($checkip, 0, strpos($checkip, "."))!=$jolly_char)
                        return 0;
                }
                else
                    return 0;
            }
           
            $checkip = substr($checkip, strpos($checkip, ".") + 1);
        }
       
        if (!($checkip >= "0" && $checkip <= "255")) {        // class D
            if ($jolly_char!='') {            // if exists, check for the jolly char
                if ($checkip!=$jolly_char)
                    return 0;
            }
            else
                return 0;
        }
    }
    else
        return 0;
   
    return 1;

}; # function check_ip_address($checkip, $jolly_char='') {



# Generate 32 bit ids
function generateUniqueID(){

	return md5(uniqid(rand(), true) . time() );
	
}; # function generateUniqueID(){




# Datum1, Datum2: hole die Tage vom entfernter gelegten Datum und addiere diese Tage zu dem am näher gelegenen 
# Hinweis: zuerst Datum, und dann der Datumsbetrag Datum2 um den Datum1 es erweitert werden soll
function AddionOfTwoDates($date1,$date2){

	$date1_unixtimestamp = strtotime($date1);
	$date2_unixtimestamp = strtotime($date2);
	
	if ( strcmp($date2,"0000-00-00" ) == 0 ) {
		$date2_unixtimestamp = strtotime( date("Y-m-d") );
	};

	if ( $date2_unixtimestamp > $date1_unixtimestamp ) {
		$diff = $date2_unixtimestamp - $date1_unixtimestamp;
		if ( strcmp($date1,"0000-00-00" ) == 0 ) {
			$date2_unixtimestamp += 0;
		} else {
			$date2_unixtimestamp += $diff;
		};
		return date("Y-m-d", $date2_unixtimestamp);
	}  elseif ( $date2_unixtimestamp == $date1_unixtimestamp ) {
		return date("Y-m-d", $date1_unixtimestamp);	# beide datumsangaben gleichgross also egal welches zurückgegeben wird
	};

}; # function AddionOfTwoDates($date1,$date2){


# checke ob ein gültiges Asiidate übergeben wurde
function checkAsciiDate( $date ) {

	list($year,$month,$day) = explode("-", $date);

	if ( $month > 12 ){
		return 0;
	};
	
	if ( $day > 31 ){
		return 0;
	};

	if ( digit($year) && digit($month) && digit($day) ){
		return 1;
	} else {
		return 0;
	};

}; # function checkAsciiDate( $date ) {


# Generate PINs
function generateCouponCode(){

	$passwd = md5(uniqid(rand(), true) . time() );
	$from	= rand(10,32)-10;
	$coupon	= strtolower(substr($passwd, $from, 10)); 

	if ( strlen($coupon) == 10 ){
		return $coupon;
	} else {
		return rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9).rand(0,9);
	};

}; # function generatePassword(){


function GetFlatrateValidUntilDate( $date, $plus ){	# eg 2007-04-12, 6months

	if ( strcmp($date,"0000-00-00" ) == 0 ) {
		$date = date("Y-m-d");
	};

	$dateSec 	= strtotime($date);
	$dateNewSec	= $dateSec + ( $plus * 31 * 24 * 60 * 60 );	# plus monat in unixtime
	$date		= date("Y-m-d", $dateNewSec);
	return $date;

}; # function GetFlatrateValidUntilDate( $date, $plus ){



function readTipDesTages(){

	$lines 	= file ( TIPDESTAGESFILE );
	$count 	= count($lines) - 1;
	$rand 	= rand(0, $count);

	return $lines[$rand];
	
}; # function readTipDesTages(){


function classifyCountryByPhoneNumber( $phone ){

	$pattern_de	= "/^(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
	$pattern_at	= "/^(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
	$pattern_ch	= "/^(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
	$pattern_uk	= "/^07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";

	if ( preg_match($pattern_de, $phone) ) {
		return "DE";
	} elseif ( preg_match($pattern_at, $phone) ) {
		return "AT";
	} elseif ( preg_match($pattern_ch, $phone) ) {
		return "CH";
	} elseif ( preg_match($pattern_uk, $phone) ) {
		return "GB";
	} else {
		
		require_once("/srv/server/wwwroot/lib/ip2country.inc.php");

		$RemoteIP	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
		$iplook 	= new ip2country($RemoteIP);	# ip2country.inc.php

		if ( $iplook->LookUp() ){
			return $iplook->Prefix1;
		
		}; # if ( $iplook->LookUp() ){

	}; # if ( preg_match($pattern_de, $phone) ) {

}; # function classifyCountryByPhoneNumber( $phone ){



function classifyVorwahlByPhoneNumber( $phone ){

	$pattern_de	= "/^(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
	$pattern_at	= "/^(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
	$pattern_ch	= "/^(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
	$pattern_uk	= "/^07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";

	if ( preg_match($pattern_de, $phone) ) {
		return "0049";
	} elseif ( preg_match($pattern_at, $phone) ) {
		return "0043";
	} elseif ( preg_match($pattern_ch, $phone) ) {
		return "0041";
	} elseif ( preg_match($pattern_uk, $phone) ) {
		return "0044";
	} else {
		
		require_once("/srv/server/wwwroot/lib/ip2country.inc.php");

		$RemoteIP	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
		$iplook 	= new ip2country($RemoteIP);	# ip2country.inc.php

		if ( $iplook->LookUp() ){
			$land = $iplook->Prefix1;
			
			if ( strstr($land, "DE") ){
				return "0049";
			} elseif ( strstr($land, "CH") ){
				return "0041";
			} elseif ( strstr($land, "AT") ){
				return "0043";
			} elseif ( strstr($land, "UK") ){
				return "0044";
			} else {
				return "";
			};
		
		}; # if ( $iplook->LookUp() ){

	}; # if ( preg_match($pattern_de, $phone) ) {

	return "";
	
}; # function classifyVorwahlByPhoneNumber( $phone ){




# Function: handy nummer checken, und im erfolgsfall die nummer in gültiges länderspezifisches format bringen
function checkHandyNummer($string, $lang){

	# Regex Library: http://regexlib.com/Search.aspx?k=mobile+phone&c=-1&m=-1&ps=20

	$lang		= strtolower($lang);
	$pattern	= "";

	if ( $lang == "de" ){
	
		# $string	= str_replace("0049","", $string);
		# $pattern1	= "/^(01)([4|5|6|7])([0-9]{1})([0-9]{5,10})$/";
		$pattern1	= "/^(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern2	= "/^(0049)(1)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern3	= "/^(0049)(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern4	= "/^(049)(1)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern5	= "/^(049)(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern6	= "/^\+(49)(1)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern7	= "/^\+(49)(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern8	= "/^(49)(1)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern9	= "/^(49)(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern10	= "/^\+(0049)(1)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$pattern11	= "/^\+(0049)(01)([4|5|6|7]{1})([0-9]{1})([0-9]{5,10})$/";
		$ersetzung 	= '00491';
		
		if ( preg_match($pattern1, $string) ) {
			
			$suchmuster 	= '/^(01)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern2, $string) ) {
			
			$suchmuster 	= '/^(0049)(1)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern3, $string) ) {
			
			$suchmuster 	= '/^(0049)(01)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern4, $string) ) {

			return $string;

		} elseif ( preg_match($pattern5, $string) ) {

			$suchmuster 	= '/^(049)(01)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern6, $string) ) {

			$suchmuster 	= '/^\+(49)(1)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern7, $string) ) {
			
			$suchmuster 	= '/^\+(49)(01)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern8, $string) ) {
		
			$suchmuster 	= '/^(49)(1)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern9, $string) ) {
	
			$suchmuster 	= '/^(49)(01)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;
		
		} elseif ( preg_match($pattern10, $string) ) {
		
			$suchmuster 	= '/^\+(0049)(1)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern11, $string) ) {
	
			$suchmuster 	= '/^\+(0049)(01)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} else {
			
			# echo "Die eingegebene Nummer entspricht nicht dem g�ltigen Format.";
			return 0;
			
		}; # if( preg_match($pattern, $string) ) {

	} elseif ( $lang == "at" ){

		#$string		= str_replace("0043","", $string);
		$pattern1	= "/^(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern2	= "/^(0043)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern3	= "/^(0043)(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern4	= "/^(043)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern5	= "/^(043)(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern6	= "/^\+(43)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern7	= "/^\+(43)(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern8	= "/^(43)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern9	= "/^(43)(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern10	= "/^\+(0043)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$pattern11	= "/^\+(0043)(0)([6]{1})([0|4|5|6|7|8|9]{1})([0-9]{1})([0-9]{6,})$/";
		$ersetzung 	= '0043';

		if ( preg_match($pattern1, $string) ) {
			
			$suchmuster 	= '/^(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern2, $string) ) {
			
			$suchmuster 	= '/^(0043)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern3, $string) ) {
			
			$suchmuster 	= '/^(0043)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern4, $string) ) {
			
			return $string;

		} elseif ( preg_match($pattern5, $string) ) {

			$suchmuster 	= '/^(043)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern6, $string) ) {
		
			$suchmuster 	= '/^\+(043)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;
		
		} elseif ( preg_match($pattern7, $string) ) {

			$suchmuster 	= '/^\+(043)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;	
		
		} elseif ( preg_match($pattern8, $string) ) {

			$suchmuster 	= '/^(43)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern9, $string) ) {

			$suchmuster 	= '/^(43)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern10, $string) ) {

			$suchmuster 	= '/^\+(0043)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern11, $string) ) {

			$suchmuster 	= '/^\+(0043)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} else {
		
			return 0;

		};

	} elseif ( $lang == "ch" ){

		# http://www.handykult.de/forums/showthread.php?t=131701
		# aber in der Schweiz sind unter den Vorwahlen der drei etablierten Netzbetreiber swisscom mobile (079), Sunrise (076) und orange CH (078) die Rufnummern siebenstellig.
		# Tele2 CH, In&Phone, Migros Mobile haben um eine Stelle l�ngere 077x Vorwahlen, bei den Rufnummern bin ich jetzt unsicher, denke aber das die auch siebenstellig sind.

		# $string		= str_replace("0041","", $string);
		$pattern1	= "/^(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern2	= "/^(0041)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern3	= "/^(0041)(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern4	= "/^(041)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern5	= "/^(041)(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern6	= "/^\+(41)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern7	= "/^\+(41)(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern8	= "/^(41)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern9	= "/^(41)(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern10	= "/^\+(0041)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$pattern11	= "/^\+(0041)(0)([7]{1})([6|7|8|9]{1})([0-9]{6,})$/";
		$ersetzung 	= '0041';
	
		if ( preg_match($pattern1, $string) ) {
			
			$suchmuster 	= '/^(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern2, $string) ) {
			
			$suchmuster 	= '/^(0041)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern3, $string) ) {
			
			$suchmuster 	= '/^(0041)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern4, $string) ) {
			
			return $string;

		} elseif ( preg_match($pattern5, $string) ) {

			$suchmuster 	= '/^(041)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern6, $string) ) {
		
			$suchmuster 	= '/^\+(041)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;
		
		} elseif ( preg_match($pattern7, $string) ) {

			$suchmuster 	= '/^\+(041)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;	
		
		} elseif ( preg_match($pattern8, $string) ) {

			$suchmuster 	= '/^(41)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern9, $string) ) {

			$suchmuster 	= '/^(41)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern10, $string) ) {

			$suchmuster 	= '/^\+(0041)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern11, $string) ) {

			$suchmuster 	= '/^\+(0041)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} else {
		
			return 0;

		};
	
	
	} elseif ( $lang == "gb") {

		# uk -> ^07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$
		$pattern1	= "/^07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern2	= "/^(0044)07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern3	= "/^(0044)7([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern4	= "/^(044)07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern5	= "/^(044)7([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern6	= "/^\+(44)07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern7	= "/^\+(44)7([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern8	= "/^(44)07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern9	= "/^(44)7([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern10	= "/^\+(0044)07([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$pattern11	= "/^\+(0044)7([\d]{3})[(\D\s)]?[\d]{3}[(\D\s)]?[\d]{3}$/";
		$ersetzung 	= '0044';
	
		if ( preg_match($pattern1, $string) ) {
			
			$suchmuster 	= '/^(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern2, $string) ) {
			
			$suchmuster 	= '/^(0044)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern3, $string) ) {
			
			$suchmuster 	= '/^(0044)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern4, $string) ) {
			
			return $string;

		} elseif ( preg_match($pattern5, $string) ) {

			$suchmuster 	= '/^(044)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern6, $string) ) {
		
			$suchmuster 	= '/^\+(044)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;
		
		} elseif ( preg_match($pattern7, $string) ) {

			$suchmuster 	= '/^\+(044)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;	
		
		} elseif ( preg_match($pattern8, $string) ) {

			$suchmuster 	= '/^(44)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern9, $string) ) {

			$suchmuster 	= '/^(44)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern10, $string) ) {

			$suchmuster 	= '/^\+(0044)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} elseif ( preg_match($pattern11, $string) ) {

			$suchmuster 	= '/^\+(0044)(0)/i';
			$string		= preg_replace($suchmuster, $ersetzung, $string);
			return $string;

		} else {
		
			return 0;

		};

	} else { 

		return $string;

	}; # if ( $lang == "at" ){
		
}; # function checkHandyNummer($string, $lang){



# Generate PINs
function generatePassword(){

	$passwd = md5(uniqid(rand(), true) . time() );
	$from	= rand(4,32)-4;
	$pin	= strtolower(substr($passwd, $from, 4)); 

	if ( strlen($pin) == 4 ){
		return $pin;
	} else {
		return rand(0,9).rand(0,9).rand(0,9).rand(0,9);
	};

}; # function generatePassword(){


# Checke ob user aus gültigem Land kommt
function CheckCountryCode( $land ){
	
	if ( strlen($land) > MAXLENGTHCOUNTRYS ){
		return 0;
	};

	$land 		= strtoupper($land);
	$validCountrys	= explode(" ", VALIDCOUNTRYS);
	
	foreach ( $validCountrys as $Country ) {
		if ( $land == strtoupper($Country) ){
			return 1;
		}; # if ( strstr(strtoupper($land), strtoupper($Country)) ){

	}; # foreach ( $validCountrys as $Country ) {

	return 0;

}; # function CheckCountryCode( $land ){


# checke referer
# 1=valid | 0=invalid,weil keine nummer | -1 referer id lenght ist zu lang
function checkRefererPP( $refID ){

	if ( strlen($refID) > MAXREFERLENGHT ){
		return -1;	# 0=false
	};

	# gültige referers sind nur nummern!
	if ( digit($refID) ){
		return 1;
	} elseif ( !digit($refID) ){
		return 0;
	};

}; # function checkRefererPP( $refID ){



# fehler message formatieren
function formatErrorMessage( $string ){

	return "<b style=\"FONT-SIZE: 8pt; COLOR: #ff0000; TEXT-ALIGN: center; TEXT-DECORATION: none\">$string</b>";
	
}; # function formatErrorMessage( $string ){


# input string prüfen
function checkInput($string, $type, $minLenght, $maxLength ){

	#######
	### I: String, (I,L,M) minLenght, maxLenght
	### O: 1|0|-1=stringlengt
	#######

	$type = strtoupper($type);	# typ immer gross

	if ( strlen($string) >= $minLenght && strlen($string) <= $maxLength ) {
	} else {
		return 0;
	};	

	if ( $type == 'I' ){		# int
		
		if ( digit($string) ){
			return 1;
		} elseif ( !digit($string) ){
			return 0;
		};

	} elseif ( $type == 'L' ){	# letter a-Z
			
		if ( alpha($string) ){
			return 1;
		} elseif ( !alpha($string) ){
			return 0;
		};

	} elseif ( $type == 'M' ){	# mixed letter int
	
		if ( alpha_numeric($string) ){
			return 1;
		} elseif ( !alpha_numeric($string) ){
			return 0;
		};
	}; # if ( $type == 'I' ){

	return 0;

}; # function checkInput($string, $type){




# email prüfen
function checkEmailAddress($email) {
	
	// First, we check that there's one @ symbol, and that the lengths are right
	if (!ereg("^[^@]{1,64}@[^@]{1,255}$", $email)) {
		// Email invalid because wrong number of characters in one section, or wrong number of @ symbols.
		return 0;
	};

	// Split it into sections to make life easier
	$email_array = explode("@", $email);
	$local_array = explode(".", $email_array[0]);
	
	for ($i = 0; $i < sizeof($local_array); $i++) {
		if (!ereg("^(([A-Za-z0-9!#$%&'*+/=?^_`{|}~-][A-Za-z0-9!#$%&'*+/=?^_`{|}~\.-]{0,63})|(\"[^(\\|\")]{0,62}\"))$", $local_array[$i])) {
			return 0;
		};
	}; # for ($i = 0; $i < sizeof($local_array); $i++) {

	if (!ereg("^\[?[0-9\.]+\]?$", $email_array[1])) { // Check if domain is IP. If not, it should be valid domain name
		$domain_array = explode(".", $email_array[1]);
		if (sizeof($domain_array) < 2) {
			return 0; // Not enough parts to domain
		};
		for ($i = 0; $i < sizeof($domain_array); $i++) {
			if (!ereg("^(([A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9])|([A-Za-z0-9]+))$", $domain_array[$i])) {
				return 0;
			};
		}; # for ($i = 0; $i < sizeof($domain_array); $i++) {
	}; # if (!ereg("^\[?[0-9\.]+\]?$", 

	return 1;

}; # function checkEmailAddress($email) {


# string abschneiden an position X
function shortenString( $string, $length ){

	if (!is_int($length) || !is_numeric($length) ){
		$length = 50;

	}; # if (!is_int($length) || !is_numeric($length) )

	if ( strlen($string) >= $length ) {
		# lösche alles nach dem 200sten zeichen bei überlangen eingaben
		$string = substr($string, 0, $length);		

	}; # if ( strlen($string) >= $length ) {

	return $string;

}; # function shortenString( $string, $length ){



?>