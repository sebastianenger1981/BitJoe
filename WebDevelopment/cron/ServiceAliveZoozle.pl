#!/usr/bin/perl

###########################
### Autor: Sebastian Enger / B.Sc. 
### Copyright: Sebastian Enger
### Licence: Own Usage - not allowed to distribute
### Contact: sebastian.enger@gmail.com | icq: 135846444
### Hint: latest version always in 'Homepages\www.zoozle.net\zoozle\service_alive_test'
###########################

use IO::Socket::INET;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request;
use MIME::Lite;		# perl -MCPAN -e 'install "MIME::Lite"'
use Net::Ping;		# perl -MCPAN -e 'install "Net::Ping"'
use strict;

# debug
### use Data::Dumper;

# ###### env EDITOR=joe crontab -e


######
my $MaxFileSizeOfWebDocument	= (5 * 1024 * 1024);	# 5mb
my $MaxRedirectRequests			= 5;
my $AuthorEmail					= 'test@cpan.org';
my $Timeout						= 20;
my $CrawlDelay					= int(rand(3));
my $Version						= "Version 1.a -20080811 @11.02 Uhr-";
my @ports_to_check				= ("22","80");
my @admin_mail_deliver			= ('thecerial@gmail.com','torsten.morgenroth@gmail.com');	# diese emails sollen error meldungen bekommen
my @admin_sms_deliver			= ('+491607979247');		# diese handynr sollen error sms bekommen
######


my %ZoozleHosts				= (
	"www.zoozle.net"	=> "www.zoozle.net [87.106.71.144]",		
	"www.zoozle.org"	=> "www.zoozle.org [87.106.134.107]",
);

my %ZoozleAliveIDs				= (
	"www.zoozle.net"	=> "ALIVEID=e424bb41bcb33975620f2c67ce836158",		
	"www.zoozle.org"	=> "ALIVEID=21bd6def1ac1eb50478caab621395580",
);


######################
#### Alive checks ####
######################

# 1. head check
# 2. get check 
# 3. tcp connection alive test port 22=ssh port 80=web
# 4. Content ALIVE ID CHECK
# 5. ping check



while( my ($host,$desc) = each(%ZoozleHosts) ){

	my $globalError									= $ZoozleHosts{$host};

	my ( $HeadStatus, $HeadDesc )					= Head($host);
	my ( $GetStatus, $GetDesc )						= Get($host);
	my ( $GetIndexHtmlStatus, $GetIndexHtmlDesc )	= GetIndexHtml($host);
	my ( $GetZoozlePHPStatus, $GetZoozlePHPDesc )	= GetZoozlePHP($host);
	my ( $ContentStatus, $ContentDesc )				= ContentCheck($host, $GetDesc);
	my ( $TcpStatus, $TcpDesc )						= TcpConnectionCheck($host);
	my ( $PingStatus, $PingDesc )					= PingCheck($host);
	my $globalStatus								= $HeadStatus.$GetStatus.$ContentStatus.$TcpStatus.$PingStatus.$GetIndexHtmlStatus.$GetZoozlePHPStatus;

	if ( $HeadStatus != 1 ) {
		$globalError .= " - $HeadDesc";
	};

	if ( $GetStatus != 1 ) {
		$globalError .= " - $GetDesc";
	};

	if ( $GetIndexHtmlStatus != 1 ) {
		$globalError .= " - $GetIndexHtmlDesc";
	};

	if ( $GetZoozlePHPStatus != 1 ) {
		$globalError .= " - $GetIndexHtmlDesc";
	};

	if ( $ContentStatus != 1 ) {
		$globalError .= " - $GetZoozlePHPDesc";
	};

	if ( $TcpStatus != 1 ) {
		$globalError .= " - $TcpDesc";
	};

	if ( $PingStatus != 1 ) {
		$globalError .= " - $PingDesc";
	};

	$globalError					= MySQLDateTime() . " $globalError";

	if ( $globalStatus != 1111111 ) {	# 5 einsen weil 5 alive checks
	
		print "ERROR: $globalError \n";
		SendStatusSMS($globalError);
		SendStatusMail($globalError);

	} elsif ( $globalStatus == 11111 ) {

		print "WORKING: " . MySQLDateTime() . " ". $ZoozleHosts{$host} ."\n";

	}; # if ( $globalStatus != 11111 ) {	# 5 einsen weil 5 alive checks

}; # while( my ($uri,$desc) = each(%ZoozleHosts) ){


exit(0);


sub SendStatusSMS(){

	my $errormsg	= shift;
	$errormsg		=~ s/([^A-Za-z0-9ß])/sprintf("%%%02X", ord($1))/seg;	# perl urlencode
	my $sendfrom	= '+4916023777337';	# diese rufnummer ist auf meinem handy unter dem namen 'Service Alive' eingetragen
	$sendfrom		=~ s/([^A-Za-z0-9ß])/sprintf("%%%02X", ord($1))/seg;	# perl urlencode

	foreach my $smsto (@admin_sms_deliver) {

		$smsto =~ s/([^A-Za-z0-9ß])/sprintf("%%%02X", ord($1))/seg;

		# wenn man über mobile marketing senden will, muss der server mit der ip bei mobile marketing freigeschalten sein / werden
		my $MessageURI	= "http://gateway.mobile-marketing-system.de/send_sms.php?username=KU-T6VI&password=FMBS1ZXA&recipient=$smsto&sender=$sendfrom&text=$errormsg&route=route1&dlr=1";
		my ($status,$desc) = Get($MessageURI);
		### print "SMS Sending - Status: '$status' - Return: '$desc' \n";
		
	}; # foreach my $smsto (@admin_sms_deliver) {

	return 1;

}; # sub SendStatusSMS(){



sub SendStatusMail(){

	my $texttosend	= shift;
	my $curenttime	= MySQLDateTime();

	foreach my $mailto (@admin_mail_deliver) {
		
		my $msg = MIME::Lite->new(
			
			From     => 'servicealive@bitjoe.com',
			To       => $mailto,
			# Cc       =>'some@other.com, some@more.com',
			Subject  => "ServiceAlive Zoozle Error at $curenttime",
			Data     => $texttosend,

		); # my $msg = MIME::Lite->new(

		$msg->send;

	}; # foreach my $mailto (@admin_mail_deliver) {

	return 1;

}; # sub SendStatusMail(){



sub PingCheck(){

	my $host = shift;
    my $ping = Net::Ping->new();
    
	if ( $ping->ping($host,$Timeout) ) {
		$ping->close();
		return (1,1);
	} else {
		$ping->close();
		return (0, "Ping Error");
	};

}; # sub PingCheck(){



sub ContentCheck(){

	my $host		= shift;
	my $content		= shift;
	
	my (@content)	= split("\n", $content );
	my $status		= 0;

	# org <!-- ALIVEID=21bd6def1ac1eb50478caab621395580 -->
	# net <!-- ALIVEID=e424bb41bcb33975620f2c67ce836158 -->
	# print "$host - AliveID $ZoozleAliveIDs{$host} \n";

	foreach my $line ( @content ) {
	
		if ( $line =~ /$ZoozleAliveIDs{$host}/ig ) {
			$status = 1;
		}; # if ( $line =~ /$ZoozleAliveIDs{$host}/ig ) {
		
	}; # foreach my $line ( @content ) {

	if ( $status == 1 ) {
		return (1, 1);
	} else {
		return (0,"AliveID Error");
	};

}; # sub ContentCheck(){




sub TcpConnectionCheck(){

	my $host		= shift;
	# my $desc		= $ZoozleHosts{$host};
	my $hoststats	= '';	# enthält den string mit den valid informationen, ausgehend ob tcp connect erfolgreich oder nicht
	my $portserror	= '';	#
	my $ValidString = '';	# enthält den string, der rauskommen muss, wenn alles korrekt ist


	foreach my $port (@ports_to_check) {
	
		my $sock = IO::Socket::INET->new(PeerPort  => $port,
			PeerAddr => $host,
			PeerPort => $port,
            Proto    => 'tcp');
		# or return "$desc [$port] TCP Alive Failed";

		if ( eval { $sock->connected } ) {
			$hoststats .= 1;
		} else {
			$hoststats .= 0;	
			$portserror .= " $port ";
		}; # if ( $sock->connected ) {

		eval { close($sock); };
		
		$ValidString .= 1;
	}; # foreach my $port (@ports_to_check) {

	if ( $hoststats == $ValidString ) {
		return (1,1);
	} else {
		return (0,"[$portserror] TCP Error");
	};

}; # sub TcpConnectionCheck(){




sub Head(){
	
	my $url		= shift;
	# my $desc	= $ZoozleHosts{$url};

	if ( $url !~ /^http/i ) {
		$url = "http://$url/index.php";
	}; # if ( $url !~ /^http/i ) {

	my $UA		= LWP::UserAgent->new( keep_alive => 1 );

	$UA->agent("ZoozleAliveTest $Version");
	$UA->timeout( $Timeout );
	$UA->max_size( $MaxFileSizeOfWebDocument );
	$UA->from( $AuthorEmail );
	$UA->max_redirect( $MaxRedirectRequests );
	$UA->parse_head( 1 );
	$UA->protocols_allowed( [ 'http', 'https', 'ftp', 'ed2k'] );
	$UA->protocols_forbidden( [ 'file', 'mailto'] );
	$UA->requests_redirectable( [ 'HEAD', 'GET', 'POST'] );
	
	sleep $CrawlDelay;

	my $req = HTTP::Request->new( HEAD => $url );
	my $res = $UA->request($req);

	if ( $res->is_success ) {
		
	#	my $Statuscode = sprintf('%.1s', $res->code);
	#
	#	# Erfolg 2xx | Umleitung 3xx
	#	if ( $Statuscode == 2 || $Statuscode == 3 ) {	
	#	
	#		$StatusHashRef->{ 'LEN' } = $res->header('Content-Length');
	#		$StatusHashRef->{ 'MOD' } = $res->header('Last-Modified');
	#	
	#	};

		return (1,1);	# erfolgreich
	} else { # if ( $Statuscode
		return (0,"[80] HEAD Error");
	}; # if ( $res->is_success ) {

}; # sub Head(){


sub Get() {
	
	my $url		= shift;
	# my $desc	= $ZoozleHosts{$url};

	if ( $url !~ /^http/i ) {
		$url = "http://$url/index.php";
	}; # if ( $url !~ /^http/i ) {

	my $UA		= LWP::UserAgent->new( keep_alive => 1 );

	$UA->agent("ZoozleAliveTest $Version");
	$UA->timeout( $Timeout );
	$UA->max_size( $MaxFileSizeOfWebDocument );
	$UA->from( $AuthorEmail );
	$UA->max_redirect( $MaxRedirectRequests );
	$UA->parse_head( 1 );
	$UA->protocols_allowed( [ 'http', 'https', 'ftp', 'ed2k'] );
	$UA->protocols_forbidden( [ 'file', 'mailto'] );
	$UA->requests_redirectable( [ 'HEAD', 'GET', 'POST'] );
		
	sleep $CrawlDelay;

	my $req = HTTP::Request->new( GET => $url );
	my $res = $UA->request($req);

	if ( $res->is_success ) {
		return (1,$res->content); 
  	} else {
      	return (0,"[80] GET Error");
  	}; # if ($res->is_success) {

}; # sub GET() {


sub GetIndexHtml() {
	
	my $url		= shift;
	# my $desc	= $ZoozleHosts{$url};

	if ( $url !~ /^http/i ) {
		$url = "http://$url/index.html";
	}; # if ( $url !~ /^http/i ) {

	my $UA		= LWP::UserAgent->new( keep_alive => 1 );

	$UA->agent("ZoozleAliveTest $Version");
	$UA->timeout( $Timeout );
	$UA->max_size( $MaxFileSizeOfWebDocument );
	$UA->from( $AuthorEmail );
	$UA->max_redirect( $MaxRedirectRequests );
	$UA->parse_head( 1 );
	$UA->protocols_allowed( [ 'http', 'https', 'ftp', 'ed2k'] );
	$UA->protocols_forbidden( [ 'file', 'mailto'] );
	$UA->requests_redirectable( [ 'HEAD', 'GET', 'POST'] );
		
	sleep $CrawlDelay;

	my $req = HTTP::Request->new( GET => $url );
	my $res = $UA->request($req);

	if ( $res->is_success ) {
		if ( length($res->content) < 20000 ) {
			return (0,"[80] GETINDEXHTML Error - Html to Small");
		} elsif ( length($res->content) > 20000 ) {
			return (1,$res->content); 
		}; # if ( length($res->content) < 20000 ) {
  	} else {
      	return (0,"[80] GETINDEXHTML Error");
  	}; # if ($res->is_success) {

}; # sub GetIndexHtml() {


sub GetZoozlePHP() {
	
	my $url		= shift;
	# my $desc	= $ZoozleHosts{$url};

	if ( $url !~ /^http/i ) {
		$url = "http://$url/zoozle.php";
	}; # if ( $url !~ /^http/i ) {

	my $UA		= LWP::UserAgent->new( keep_alive => 1 );

	$UA->agent("ZoozleAliveTest $Version");
	$UA->timeout( $Timeout );
	$UA->max_size( $MaxFileSizeOfWebDocument );
	$UA->from( $AuthorEmail );
	$UA->max_redirect( $MaxRedirectRequests );
	$UA->parse_head( 1 );
	$UA->protocols_allowed( [ 'http', 'https', 'ftp', 'ed2k'] );
	$UA->protocols_forbidden( [ 'file', 'mailto'] );
	$UA->requests_redirectable( [ 'HEAD', 'GET', 'POST'] );
		
	sleep $CrawlDelay;

	my $req = HTTP::Request->new( GET => $url );
	my $res = $UA->request($req);

	if ( $res->is_success ) {
		if ( length($res->content) < 20000 ) {
			return (0,"[80] GETZOOZLEPHP Error - Html to Small");
		} elsif ( length($res->content) > 20000 ) {
			return (1,$res->content); 
		}; # if ( length($res->content) < 20000 ) {
  	} else {
      	return (0,"[80] GETZOOZLEPHP Error");
  	}; # if ($res->is_success) {

}; # sub GetZoozlePHP() {


sub MySQLDateTime(){

	my ( $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst ) = localtime(time);
	$year = $year+1900;
	$mon = $mon + 1;

	if ( length($mon) == 1 ) {
		$mon = "0". $mon;
	};
	if ( length($mday) == 1 ) {
		$mday = "0". $mday;
	};
	if ( length($sec) == 1 ) {
		$sec = "0". $sec;
	};
	if ( length($min) == 1 ) {
		$min = "0". $min;
	};
	if ( length($hour) == 1 ) {
		$hour = "0". $hour;
	};
	   
	return $year ."-". $mon ."-". $mday .' '. $hour .':'. $min .':'. $sec;
	
}; # sub MySQLDateTime() {}


#print "net: HeadStatus: '$HeadStatus' -  HeadDesc: '$HeadDesc'\n";
#print "net: GetStatus: '$GetStatus' -  ContentStatus: '$ContentStatus'\n";
#print "net: TcpStatus: '$TcpStatus' -  TcpDesc: '$TcpDesc'\n";
#print "net: PingStatus: '$PingStatus' -  PingDesc: '$PingDesc'\n";

