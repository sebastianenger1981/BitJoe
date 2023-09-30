<?php

require_once("/srv/server/wwwroot/lib/config.inc.php");

# Lastschrift example
### http://billing.micropayment.de/lastschrift/event/?account=12917&project=btjo3d&projectcampaign=bjlastschrift&theme=l2&paytext=bitjoe.de+Handy+Download+Flatre+f%FCr+3+Monate&free&seal=c7c371c5b515f34babeefde76713be76





function eBankStartseite( $phonenumber ){

	# call 2 pay 5 tages flatrate

	$date 				= time();
	$project 			= 'btjonma';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNEBANK;
	$accessKey 			= MICROPAYMENTACCESSKEY;
	$account			= MICROPAYMENTACCOUNT;
	$title				= 'anmeldunghandy_ebank_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Suchmaschine';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&freeparam=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/ebank2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function eBankStartseite( $phonenumber ){




function Call2PayStartseite( $phonenumber ){

	# call 2 pay 5 tages flatrate

	$date 			= time();
	$project 		= 'btjonm';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$title			= 'anmeldunghandy_call2pay_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Suchmaschine';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function Call2PayStartseite( $phonenumber ){




/*
18 Monate (entspricht ~5,55 EUR pro Monat) 99,95 EUR        
12 Monate (entspricht ~6,66 EUR pro Monat) 79,95 EUR       
6 Monate (entspricht ~8,33 EUR pro Monat) 49,95 EUR        
1 Monat 19,95 EUR    
15 Suchanfragen (bis zu 225 Downloads) 9,95 EUR       
6 Suchanfragen (bis zu 90 Downloads) 4,95 EUR    
*/


function Prize24(){

	$prize_pro = round( KOSTEN24MONATFLAT / 18, 2);	# 12 monats flat, auf 2 stellen nach komma runden
	return array( KOSTEN24MONATFLAT, $prize_pro );

}; # function Prize24(){


function Prize12(){

	$prize_pro = round( KOSTEN12MONATFLAT / 12, 2);	# 12 monats flat, auf 2 stellen nach komma runden
	return array( KOSTEN12MONATFLAT, $prize_pro );

}; # function Prize12(){



function Prize6(){

	$prize_pro = round( KOSTEN6MONATFLAT / 6, 2);	# 6 monats flat
	return array( KOSTEN6MONATFLAT, $prize_pro );

}; # function Prize6(){


function Prize3(){

	$prize_pro = round( KOSTEN1MONATFLAT / 1, 2);	# 3 monats flat
	return array( KOSTEN1MONATFLAT, $prize_pro );

}; # function Prize3(){


function PrizeHandy(){

	$prize_pro = round( KOSTENVOLUMEHANDY / 1, 2);	# 3 monats flat
	return array( KOSTENVOLUMEHANDY, $prize_pro );

}; # function PrizeHandy(){


function generatePaypalFlatHandy( $phonenumber ){

	$date 			= time();
	$title			= 'flathandy_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Flatrate Handy fuer 3 Tage';

	return array( $title, $desc, KOSTENFLATHANDY);

}; # function generatePaypalFlatHandy( $phonenumber ){


function generatePaypalBIG( $phonenumber ){

	$date 			= time();
	$title			= 'volumebig_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Volumentarif Gross';

	return array( $title, $desc, KOSTENVOLUMEBIG);

}; # function generatePaypalBIG( $phonenumber ){




function generatePaypalLOW( $phonenumber ){

	$date 			= time();
	$title			= 'volumelow_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Volumentarif Klein';

	return array( $title, $desc, KOSTENVOLUMELOW);

}; # function generatePaypalLOW( $phonenumber ){


function generatePaypalHandy( $phonenumber ){

	$date 			= time();
	$title			= 'volumehandy_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Volumentarif Handy';

	return array( $title, $desc, KOSTENVOLUMEHANDY);

}; # function generatePaypalHandy( $phonenumber ){



function generatePaypalTwentyFourMonths( $phonenumber ){

	$date 			= time();
	$title			= 'flat12_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Flatrate fuer 12 Monate';

	return array( $title, $desc, KOSTEN24MONATFLAT);

}; # function generatePaypalTwentyFourMonths( $phonenumber ){



function generatePaypalTwelveMonths( $phonenumber ){

	$date 			= time();
	$title			= 'flat12_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Flatrate fuer 12 Monate';

	return array( $title, $desc, KOSTEN12MONATFLAT);

}; # function generatePaypalTwelveMonths( $phonenumber ){


function generatePaypalSixMonths( $phonenumber ){

	$date 			= time();
	$title			= 'flat6_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Flatrate fuer 6 Monate';

	return array( $title, $desc, KOSTEN6MONATFLAT);

}; # function generatePaypalSixMonths( $phonenumber ){



function generatePaypalThreeMonths( $phonenumber ){

	$date 			= time();
	$title			= 'flat3_paypal_' . $phonenumber . '_' . $date;
	$desc			= 'bitjoe.de Handy Download Flatrate fuer 1 Monat';

	return array( $title, $desc, KOSTEN1MONATFLAT);

}; # function generatePaypalThreeMonths( $phonenumber ){



function generateBillingURIforFiveDaysFlatLastschrift( $phonenumber ){

	# call 2 pay 5 tages flatrate

	$date 			= time();
	$project 		= 'btjofl5';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNLASTSCHRIFT;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flathandy_lastschrift_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+3+Tage';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/lastschrift/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforFiveDaysFlatLastschrift( $phonenumber ){



function generateBillingURIforFiveDaysFlateBank( $phonenumber ){

	# call 2 pay 5 tages flatrate

	$date 			= time();
	$project 		= 'btjofl5';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNEBANK;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flathandy_ebank_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+3+Tage';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/ebank2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforFiveDaysFlateBank( $phonenumber ){


function generateBillingURIforFiveDaysFlatCall2Pay( $phonenumber ){

	# call 2 pay 5 tages flatrate

	$date 			= time();
	$project 		= 'btjofl5';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flathandy_call2pay_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+3+Tage';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforFiveDaysFlatCall2Pay( $phonenumber ){



function generateMicropaymentBillingURIforVolumeHandyCallToPay( $phonenumber ){

	# betrag in eurocent für 30 Suchanfragen call2pay

	$date 			= time();
	$project 		= 'btjohn';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$title			= 'volumehandy_call2pay_' . $phonenumber . '_' . $date;

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=d3&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateMicropaymentBillingURIforVolumeHandyCallToPay( $phonenumber ){





function generateBillingURIforTwentyFourMonthsFlatLastschrift( $phonenumber ){

	# lastschruft pay 24 monats flat

	$date 			= time();
	$project 		= 'btjo24d';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNLASTSCHRIFT;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flat24_lastschrift_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+18+Monate';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/lastschrift/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforTwentyFourMonthsFlatLastschrift( $phonenumber ){




function generateBillingURIforTwelveMonthsFlatLastschrift( $phonenumber ){

	# lastschruft pay 12 monats flat

	$date 			= time();
	$project 		= 'btjo12d';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNLASTSCHRIFT;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flat12_lastschrift_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+12+Monate';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/lastschrift/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforTwelveMonthsFlatLastschrift( $phonenumber ){





function generateBillingURIforSixMonthsFlatLastschrift( $phonenumber ){

	# lastschruft pay 6 monats flat

	$date 			= time();
	$project 		= 'btjo6d';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNLASTSCHRIFT;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flat6_lastschrift_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+6+Monate';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/lastschrift/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforSixMonthsFlatLastschrift( $phonenumber ){




function generateBillingURIforThreeMonthsFlatLastschrift( $phonenumber ){

	# lastschruft pay 3 monats flat

	$date 			= time();
	$project 		= 'btjo3d';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNLASTSCHRIFT;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
#	$text			= "BitJoe.de+Flatrate+fuer+3+Monate";
	$title			= 'flat3_lastschrift_' . $phonenumber . '_' . $date;
	$payment_lastschrift	= 'bitjoe.de+Handy+Download+Flatrate+f%FCr+1+Monat';

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&paytext=$payment_lastschrift&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/lastschrift/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforThreeMonthsFlatLastschrift( $phonenumber ){







function generateBillingURIforTwentyFourMonthsFlateBank( $phonenumber ){

	# ebank pay 24 monats flat

	$date 			= time();
	$project 		= 'btjomo24';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNEBANK;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$text			= "BitJoe.de+Flatrate+fuer+18+Monate";
	$title			= 'flat24_ebank_' . $phonenumber . '_' . $date;

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/ebank2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforTwentyFourMonthsFlateBank( $phonenumber ){




function generateBillingURIforTwelveMonthsFlateBank( $phonenumber ){

	# ebank pay 12 monats flat

	$date 			= time();
	$project 		= 'btjomo12';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNEBANK;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$text			= "BitJoe.de+Flatrate+fuer+12+Monate";
	$title			= 'flat12_ebank_' . $phonenumber . '_' . $date;

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/ebank2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforTwelveMonthsFlateBank( $phonenumber ){




function generateBillingURIforSixMonthsFlateBank( $phonenumber ){

	# ebank pay 6 monats flat

	$date 			= time();
	$project 		= 'btjomo6';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNEBANK;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$text			= "BitJoe.de+Flatrate+fuer+6+Monate";
	$title			= 'flat6_ebank_' . $phonenumber . '_' . $date;	#&free=3monatflat_$HANDYNR_$ASCIIDATE_$HASH

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/ebank2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforSixMonthsFlateBank( $phonenumber ){





# http://billing.micropayment.de/ebank2pay/event/?account=12917&project=btjomo3&projectcampaign=bjebank&theme=l2&paytext=BitJoe.de+Flatrate+f%FCr+3+Monate&seal=870811cfd46baa2b03b2830bbd915df9

function generateBillingURIforThreeMonthsFlateBank( $phonenumber ){

	# ebank pay 3 monats flat

	$date 			= time();
	$project 		= 'btjomo3';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNEBANK;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$text			= "BitJoe.de+Flatrate+fuer+1+Monat";
	$title			= 'flat3_ebank_' . $phonenumber . '_' . $date;

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=l2&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/ebank2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateBillingURIforThreeMonthsFlateBank( $phonenumber ){





function generateMicropaymentBillingURIforVolumeBigCallToPay( $phonenumber ){

	# betrag in eurocent für 30 Suchanfragen call2pay

	$date 			= time();
	$project 		= 'btjovo';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$title			= 'volumebig_call2pay_' . $phonenumber . '_' . $date;

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=d3&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateMicropaymentBillingURIforVolumeBigCallToPay( $phonenumber ){





function generateMicropaymentBillingURIforVolumeLowCallToPay( $phonenumber ){

	# betrag in eurocent für 10 Suchanfragen call2pay

	$date 			= time();
	$project 		= 'btjovf';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$title			= 'volumelow_call2pay_' . $phonenumber . '_' . $date;	#&free=3monatflat_$HANDYNR_$ASCIIDATE_$HASH

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=d3&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateMicropaymentBillingURIforVolumeLowCallToPay( $phonenumber ){




# http://billing.micropayment.de/call2pay/event/?account=12917&project=btjoon&projectcampaign=bjc2p&theme=d3&seal=911d657f6b26c055effa792d6346efb1
function generateMicropaymentBillingURIforThreeMonthsFlatCallToPay( $phonenumber ){

	# betrag in eurocent für 3 monats flat call2pay

	$date 			= time();
	$project 		= 'btjoon';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$title			= 'flat3_call2pay_' . $phonenumber . '_' . $date;	#&free=3monatflat_$HANDYNR_$ASCIIDATE_$HASH

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=d3&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/event/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function generateMicropaymentBillingURIforThreeMonthsFlatCallToPay( $phonenumber ){



function _testCall( $phonenumber ){

	# betrag in eurocent für 3 monats flat call2pay
	########## TEST TEST TEST TEST TEST #####

	$date 			= time();
	$project 		= 'btjocl';
	$projectcampaign	= MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL;
	$accessKey 		= MICROPAYMENTACCESSKEY;
	$account		= MICROPAYMENTACCOUNT;
	$title			= 'flat24_call2pay_' . $phonenumber . '_' . $date;	#&free=3monatflat_$HANDYNR_$ASCIIDATE_$HASH

	// parameter werden versiegelt
	$params = "account=$account&project=$project&projectcampaign=$projectcampaign&theme=d3&free=$title";
		
	// Bildung des Siegels
	$seal = md5($params . $accessKey);
	
	// URL bilden aus Zieladresse, versiegelte Parameter und Siegel
	$url = 'http://billing.micropayment.de/call2pay/file/?' . $params . '&seal=' . $seal;
	
	return $url;

}; # function _testCall( $phonenumber ){



return;


?>