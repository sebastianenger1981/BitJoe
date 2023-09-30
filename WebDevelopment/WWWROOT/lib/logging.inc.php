<?php

require_once("/srv/server/wwwroot/lib/config.inc.php");

#setze den error handler auf eine spezifische funktion - in diesem fall soll nix ausgegeben werden
set_error_handler("beQuietLogging"); 
function beQuietLogging() { return; };




function LogCheckForNewVersion( $IP, $lang, $UP_MD5,$status ){

	$date		= date("Y-m-d h:i:s A");
	$handle 	= fopen(LOGCHECKFORNEWVERSION, "a");
	fwrite($handle, "[$date] [$IP] [lang=$lang] [up_md5=$UP_MD5] [status='$status']\n");
	fclose($handle);

}; # function LogCheckForNewVersion( $IP, $lang, $UP_MD5,$status ){



function LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, $status ){

	$date		= date("Y-m-d h:i:s A");
	$handle 	= fopen(LOGNEWACCOUNTBITJOEHANDY, "a");
	fwrite($handle, "[$date] [$IP] [phone=$MobilePhone] [phonefull=$MobilePhoneBeauty] [status='$status']\n");
	fclose($handle);

}; # function LogNewAccountBitJoeHandy( $MobilePhone, $MobilePhoneBeauty, $IP, $status ){




function LogResendSoftware( $MobilePhone, $Status, $error ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGRESENDSOFTWARE, "a");
	fwrite($handle, "[$date] [$remote_ip] [to=$MobilePhone] [status=$Status] [error=$error]\n");
	fclose($handle);

}; # function LogResendSoftware( $MobilePhone, $Status, $error ){




function LogAGBRequest( $email){

	$date				= date("Y-m-d h:i:s A");
	$remote_ip			= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 			= fopen(LOGAGBREQUEST, "a");
	fwrite($handle, "[$date] [$remote_ip] [$email] \n");
	fclose($handle);

}; # function LogAccessIndexPage(){


function LogHandyPaymentAPI( $remote_ip, $UP_MD5, $MicroPaymentURI, $tmp, $handle ){

	$date				= date("Y-m-d h:i:s A");
	$remote_ip_header	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 			= fopen(LOGHANDYPAYMENTAPI, "a");
	fwrite($handle, "[$date] [$remote_ip][$remote_ip_header] [$UP_MD5] [handle=$handle] [$tmp] [$MicroPaymentURI]\n");
	fclose($handle);

}; # function LogAccessIndexPage(){




function LogUseCouponAPI( $MobilePhone, $gift_code, $couponcode, $hc_contingent_volume_success, $hc_contingent_volume_overall, $web_flatrate_validUntil , $web_servicetype, $web_servicetype_new, $gift_how_often_valid, $gift_code_validUntil, $gift_success_search, $gift_overall_search, $gift_flat_validUntil, $bill_coupon_count, $bill_coupon_searches_bygift, $user_flat_validUntil,$user_success_search, $user_overall_search, $bjAccessProgramm, $bj_SEC_MD5, $bj_UP_MD5 ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGCOUPONAPI, "a");
	fwrite($handle, "[$date] [$remote_ip] [prog=$bjAccessProgramm] [phone=$MobilePhone] [sec_MD5=$bj_SEC_MD5] [up_MD5=$bj_UP_MD5] [giftcode=$gift_code] [giftcode_userinput=$couponcode] [uservolumensuccess_before_gift=$hc_contingent_volume_success] [uservolumenoverall_before_gift=$hc_contingent_volume_overall] [userflat_validUntil=$web_flatrate_validUntil] [user_servicetype_before_gift=$web_servicetype] [user_servicetype_after_gift=$web_servicetype] [gift_how_often_valid=$gift_how_often_valid] [gift_code_validUntil=$gift_code_validUntil] [gift_success_search=$gift_success_search] [gift_overall_search=$gift_overall_search] [gift_flat_validUntil=$gift_flat_validUntil] [bill_coupon_count=$bill_coupon_count] [bill_coupon_searches_bygift=$bill_coupon_searches_bygift] [usernew_flat_validUntil=$user_flat_validUntil] [user_success_search=$user_success_search] [user_overall_search=$user_overall_search] \n");
	fclose($handle);


}; # function LogUseCouponAPI(){}



function LogUseCouponWeb( $MobilePhone, $gift_code, $couponcode, $hc_contingent_volume_success, $hc_contingent_volume_overall, $web_flatrate_validUntil , $web_servicetype, $web_servicetype_new, $gift_how_often_valid, $gift_code_validUntil, $gift_success_search, $gift_overall_search, $gift_flat_validUntil, $bill_coupon_count, $bill_coupon_searches_bygift, $user_flat_validUntil,$user_success_search, $user_overall_search ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGCOUPONWEB, "a");
	fwrite($handle, "[$date] [$remote_ip] [phone=$MobilePhone] [giftcode=$gift_code] [giftcode_userinput=$couponcode] [uservolumensuccess_before_gift=$hc_contingent_volume_success] [uservolumenoverall_before_gift=$hc_contingent_volume_overall] [userflat_validUntil=$web_flatrate_validUntil] [user_servicetype_before_gift=$web_servicetype] [user_servicetype_after_gift=$web_servicetype] [gift_how_often_valid=$gift_how_often_valid] [gift_code_validUntil=$gift_code_validUntil] [gift_success_search=$gift_success_search] [gift_overall_search=$gift_overall_search] [gift_flat_validUntil=$gift_flat_validUntil] [bill_coupon_count=$bill_coupon_count] [bill_coupon_searches_bygift=$bill_coupon_searches_bygift] [usernew_flat_validUntil=$user_flat_validUntil] [user_success_search=$user_success_search] [user_overall_search=$user_overall_search] \n");
	fclose($handle);

}; # function LogUseCouponWeb(){



function LogTellAFriend( $MobilePhone, $MobilePhoneTo, $Status ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGTELLAFRIENDACCESS, "a");
	fwrite($handle, "[$date] [$remote_ip] [fromphone=$MobilePhone] [tophone=$MobilePhoneTo] [status=$Status] \n");
	fclose($handle);

}; # function LogAccessIndexPage(){



function LogAccessLoginPage(  ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGLOGINACCESS, "a");
	fwrite($handle, "[$date] [$remote_ip] \n");
	fclose($handle);

}; # function LogAccessIndexPage(){



function LogAccessIndexPage( $referingUrl, $refPP, $grpPP, $refUID, $Country, $err ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGINDEXACCESS, "a");
	fwrite($handle, "[$date] [$remote_ip] [webref=$referingUrl] [ppref=$refPP] [ppgrp=$grpPP] [userref=$refUID] [$Country] [err=$err] \n");
	fclose($handle);

}; # function LogAccessIndexPage(){


function LogAccessSignupPage( $referingUrl, $refPP, $grpPP, $refUID, $Country, $MobilePhone, $MobilePhoneBeauty, $MobilePhoneStatus ){

	$date		= date("Y-m-d h:i:s A");
	$remote_ip	= isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
	$handle 	= fopen(LOGSIGNUPACCESS, "a");
	fwrite($handle, "[$date] [$remote_ip] [webref=$referingUrl] [ppref=$refPP] [ppgrp=$grpPP] [userref=$refUID] [phone=$MobilePhone] [beautyphone=$MobilePhoneBeauty] [statusphone=$MobilePhoneStatus] [$Country] \n");
	fclose($handle);

}; # function LogAccessIndexPage(){



?>