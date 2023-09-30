<?php

### datenbank spezifische sachen
define('BJPARIS_TABLE', 'bjparis');
define('COUPON_TABLE', 'coupon');
define('BILL_TABLE', 'payment');
define('USED_TABLE', 'usedcoupons');


# fuer den server
define('MYSQL_HOST', 'localhost'); 
define('MYSQL_USER', 'root'); 
define('MYSQL_PASS', ''); 
define('MYSQL_DATABASE', 'bitjoe'); 


define('MAXCOUPONSTOUSEADAY', '3');						# wieviel coupons darf ein user am tag maximal einlösen	

define('MAXREFERLENGHT', '25');							# wie lang darf ein pp referer string maximal sein
define('MAXINPUTSTRINGLENGHT', '150');						# wie lang darf ein vom user eingegebener string maximal sein

define('MAXREQUESTPERDAY', '75');						# wie oft darf eine IP auf anmelden drücken am tag
define('MAXSIGNUPREQUESTPERDAY', '30');						# wie oft darf eine IP auf signup drücken am tag
define('MAXTELLAFRIENDREQUESTPERDAY', '120');					# wie oft darf eine IP auf tell a friend drücken am tag

### mkdir /var/tmp/security && chown -R www-data:www-data security/
define('SECURITY_ACCESS_PATH', '/var/tmp/security');				# wo soll gespeichert werden, wie oft eine ip schon versucht hat zuzugreifen

define('PP_TRACKING_URI', 'http://www.bitjoepartner.com/affiliate/affiliate.php');	# welcher server soll genutzt werden zum generieren eines clicks
define('IP2COUNTRYCSV','/srv/server/wwwroot/lib/iptocountry_DECHAT.csv'); 	# wo soll nach der ip2country.csv gesucht werden

define('LOGINDEXACCESS', '/srv/server/logs/index_access.log');			# logging file für den zugriff auf die startseite
define('LOGSIGNUPACCESS', '/srv/server/logs/signup_access.log');		# logging file für den zugriff auf die signup
define('LOGLOGINACCESS', '/srv/server/logs/login_access.log');
define('LOGTELLAFRIENDACCESS', '/srv/server/logs/tellafriend.log');
define('LOGAPIHANDLERDACCESS', '/srv/server/logs/apihandler.log');
define('LOGCOUPONWEB', '/srv/server/logs/coupon_web.log');			
define('LOGCOUPONAPI', '/srv/server/logs/coupon_api.log');
define('LOGHANDYPAYMENTAPI', '/srv/server/logs/handypayment_api.log');
define('LOGPAYPALPAYMENTAPI', '/srv/server/logs/paypal_api.log');
define('LOGAGBREQUEST', '/srv/server/logs/agbs_api.log');
define('LOGRESENDSOFTWARE', '/srv/server/logs/resendsoftware_api.log');
define('LOGNEWACCOUNTBITJOEHANDY', '/srv/server/logs/newaccount_api.log');
define('LOGCHECKFORNEWVERSION', '/srv/server/logs/checkfornewversion_api.log');


define('TIPDESTAGESFILE', '/srv/server/wwwroot/lib/tipdestages.txt');		# textfile mit den tip des tages


define('VALIDCOUNTRYS', 'DE AT CH GB');						# user aus welchen ländern sollen wir als lead tracken
define('IS_SUCCESSFULL_SEARCHES', '1');						# 1 = successfull searches
define('IS_FLATRATE', '2');									# 2 = flatrate


define('MAXLENGTHCOUNTRYS', '3');							# was ist die max länge für ein länderkürzel	

define('DOWNLOADSOURCEMULTIPLY', '15');						# 1 suchanfrage hat max 15 sources

define('BITJOEHANDY_STANDART_VOLUME_SUCCESS', '3');			# not used: wieviele erfolgreiche suchversuche hat ein gratis user, der sich mittels bitjoe handy angemeldet hat
define('BITJOEHANDY_STANDART_VOLUME_OVERALL', '21');		# not used: wieviele suchversuche hat ein gratis user insgesamt, der sich mittels bitjoe handy angemeldet hat

define('STANDART_VOLUME_SUCCESS', '4');						# wieviele erfolgreiche suchversuche hat ein gratis user
define('STANDART_VOLUME_OVERALL', '12');					# wieviele suchversuche hat ein gratis user insgesamt	- wenn dieser wert angepasst wird muss auch cron/cron_leadtracking.pl angepasst werden

define('BUY_VOLUMENLOW_SUCCESS', '12');		# 5/15			# wieviel erfolgreiche suchanfragen stehen dem user zur verfügung, wenn er den einfachen volumentarif gekauft hat	
define('BUY_VOLUMENLOW_OVERALL', '36');						# wieviel maximale suchanfragen stehen dem user zur verfügung, wenn er den einfachen volumentarif gekauft hat

define('BUY_VOLUMENBIG_SUCCESS', '26');		# 12/36			# wieviel erfolgreiche suchanfragen stehen dem user zur verfügung, wenn er den hohen volumentarif gekauft hat	
define('BUY_VOLUMENBIG_OVERALL', '78');						# wieviel maximale suchanfragen stehen dem user zur verfügung, wenn er den hohen volumentarif gekauft hat

define('BUY_VOLUMENHANDY_SUCCESS', '6');	# new			# wieviel erfolgreiche suchanfragen stehen dem user zur verfügung, wenn er den handy volumentarif gekauft hat	
define('BUY_VOLUMENHANDY_OVERALL', '21');					# wieviel maximale suchanfragen stehen dem user zur verfügung, wenn er den handy volumentarif gekauft hat

### HandyAnmeldung Tarif 1 Payment
define('BUY_HANDYTARIF_1_SUCCESS', '5');					# wieviele erfolgreiche suchversuche hat ein HandyAnmeldung Tarif 1 Payment User
define('BUY_HANDYTARIF_1_OVERALL', '15');					# wieviele suchversuche hat ein HandyAnmeldung Tarif 1 Payment User insgesamt	- wenn dieser wert angepasst wird muss auch cron/cron_leadtracking.pl angepasst werden


define('BUY_FLATHANDY_DAYS', '4');							# wieviel tage flatrate stehen dem user zu,wenn er eine handy flatrate gekauft hat 
define('BUY_FLATHANDY_DAYS_STARTPAGE_ANMELDUNG', '14');		# wieviel tage flatrate stehen dem user zu,wenn er eine handy flatrate gekauft hat und sich von der startseite für 2,99€ angemeldet hat


define('TELL_A_FRIEND_TEXT', 'Hallo. Mit der bitjoe.de Handy Download Flatrate kannst du Mp3s, Klingeltoene, Java Spiele, Bilder, Videos und Dokumente wie Du willst auf dein Handy laden.'); # der text der bei tell a friend message angezeigt werden soll


# mobilant sms + sms wappush security key
define('MOBILANTHIDDENKEY', '');


# micropayment sachen
define('MICROPAYMENTACCESSKEY', '');	# access key für micropayment
define('MICROPAYMENTACCOUNT', '');
define('MICROPAYMENTPROJECTCAMPAIGNPAYTOCALL', '');		# bj bezahlcampagne
define('MICROPAYMENTPROJECTCAMPAIGNEBANK', '');
define('MICROPAYMENTPROJECTCAMPAIGNLASTSCHRIFT', '');


# Perl Api Request um den Coupon gleich zu Installieren vom Handy aus
define('BITJOEPERLAPIACCESSKEY', '');	# der auth key mit dem sich das perl api handler bei uns authentifieziert um einen coupon request zu stellen


# Payment Informationen hinterlegen

define('KOSTEN1MONATFLAT', '4.99');
define('KOSTEN6MONATFLAT', '49.95');
define('KOSTEN12MONATFLAT', '59.99');
define('KOSTEN24MONATFLAT', '59.99');	# 12monate
define('KOSTENVOLUMEHANDY', '2.99');
define('KOSTENFLATHANDY', '2.99');
define('KOSTENVOLUMELOW', '4.95');
define('KOSTENVOLUMEBIG', '9.95');


define('JADFILEPATH', '/srv/server/bitjoe');
define('WAPPUSHWEBPATH', '/srv/server/wwwroot/download');

define('CAPTCHABITJOELOCALPATH', '/srv/server/captchawwwroot/MD5STORE');	# wo werden captcha ids gespeichert ?
define('CAPTCHAURI', 'http://77.247.178.20/captcha/index.php?id=');						# wo holen wir unsere captchas her - aktuell vom bj suchserver

define('CHECKVERSION_DE', '/srv/server/wwwroot/lib/version/version_de.txt');
define('CHECKVERSIO_EN', '/srv/server/wwwroot/lib/version/version_en.txt');

# http://localhost/ads/callbacks/callback_sample.php?txn_id=BITJOE&aff_id=2&group_id=2&amount=1&cur=EUR&country_code=de&add_info=20080416
#<img src="http://localhost/ads/callbacks/callback_sample.php?txn_id=2342&aff_id=2&group_id=2&amount=1&cur=EU&country_code=DE&add_info=XXX" width="1" height="1" border="0" alt="">

/*
/callbacks mit .htaccess schützen
*/

?>