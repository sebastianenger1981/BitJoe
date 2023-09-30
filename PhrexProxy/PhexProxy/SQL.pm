#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		SQL Verbindungen aufbauen
##### Todo:			
########################################

package PhexProxy::SQL;

use DBI;
use strict; no strict 'subs';
use PhexProxy::Time;
use DB_File;
use IO::Socket;
use LWP::UserAgent;
use HTTP::Request;

my $VERSION = '1.1 since 24.08.2009 with sql balancing!';

### later: alles aus config lesen  
#my $HOST	= "87.106.63.182";	# bitjoe.de
#my $DB		= "bitjoe";
#my $USER	= "bitjoe7724717820";
#my $PASS	= "bj236xw23571sdGdhS4522dSfH2";

#my $HOST	= "77.247.178.21";	# bitjoe.de
my $DB							= "bitjoe";
my $USER						= "root";
my $PASS						= "rouTer99";

my $ServerSocket;
my %CurrentSearchRequests		= ();
my $ServerStatus				= {};
my @admin_sms_deliver			= ('0041789354830');	# diese handynr sollen error sms bekommen
my $MaxFileSizeOfWebDocument	= (5 * 1024 * 1024);	# 5mb
my $MaxRedirectRequests			= 0;
my $AuthorEmail					= 'test@cpan.org';
my $Timeout						= 5;
my $CrawlDelay					= int(rand(3));
my $SMS_DB						= "/server/phexproxy/tmp/SMSDB.db";		unlink $SMS_DB || system("/bin/rm -rf $SMS_DB");
my $SendSmsDelay				= 300;	# nur alle 300 sekundn soll eine sms gesendet werden

my $MainSqlServer				= "77.247.178.21";	# read write sql server


my %SqlHosts					= (			# hier stehen die sql server drinne, die zum bitjoe balancing gehören
	"77.247.178.21"				=> "3306",	# sql Yeon server - 77.247.178.21
	"87.106.134.107"			=> "3306",	# 1und1 phex server - 87.106.134.107 # nur read sql server , hierdrauf wird NICHT geschrieben!
);


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub SQLConnect(){

	my $self	= shift;
	
	eval { 
		my $HOST	= "";
		$HOST		= CheckSqlServerConnection();
		my $dbh		= DBI->connect("DBI:mysql:database=$DB;host=$HOST", "$USER", "$PASS", {'RaiseError' => 0});
		### print "BJ PROTOCOL: 'DBI:mysql:database=$DB;host=$HOST'\n";
		return $dbh;
	}

	# my $drh		= DBI->install_driver("mysql");

};	# sub SQLConnect(){}





sub CheckSqlServerConnection(){

	while( my ($host,$port) = each(%SqlHosts)){
			
		$ServerSocket	= ProxyConnect($host,$port);
		
		if ( !defined($ServerSocket) && length($ServerSocket) <= 0 ) {
			# Send SMS
			$ServerStatus->{$host} = 0;
		} else {
			$ServerStatus->{$host} = 1;
		};
		eval {
			close($ServerSocket);
		}

	}; # while( my ($host,$ports) = each(%ParisHosts)){

	# nimm möglichst immer den main sql server
	if ( $ServerStatus->{$MainSqlServer} == 1 ) {
		return $MainSqlServer;
	};

	my $FinalGiveBackSqlServer = "";
	while( my ($ReturnHost,$status) = each(%{$ServerStatus})){
		next if ( $status == 0 || $status != 1 );	# ignoriere Status 0 oder Status ungleich 1
		$FinalGiveBackSqlServer = $ReturnHost;
	}; # while( my ($host,$ports) = each(%ParisHosts)){

	# print "SQL GIVEBACK;: '$FinalGiveBackSqlServer'\n";
	return $FinalGiveBackSqlServer;

}; # sub CheckSqlServerConnection(){




sub ProxyConnect(){

	my $host = shift;
	my $port = shift;

	my $Connection	= IO::Socket::INET->new( 
		PeerAddr	=> $host,	
		PeerPort	=> $port,	
		Proto		=> 'tcp',
		Timeout		=> 5,
		Reuse		=> 1 ) or SendStatusSMS("BITJOE SQLSERVER '$host':'$port' is down at: ".PhexProxy::Time->MySQLDateTime()."\n");	# later sms benachrichtigung

	return $Connection;

}# sub ProxyConnect(){




sub SendStatusSMS(){

	my $errormsg	= shift;
	my $sendfrom	= '004916023777337';	# diese rufnummer ist auf meinem handy unter dem namen 'Service Alive' eingetragen
	my $password	= "84c9293acd49fc6e4f22a53ffa25c195";
	my $LastSmsSend = RequestCounterRead();

	foreach my $smsto (@admin_sms_deliver) {

		my $MessageURI	= "http://www.sms-revolution.ch/API/httpsms.php?user=delicious&password=$password&text=$errormsg&to=$smsto&typ=3";
		
		if ( time() > $LastSmsSend + $SendSmsDelay ) {
			my ($status,$desc) = &Get($MessageURI);
			#	print "SMS Sending - Status: '$status' - Return: '$desc' \n";
			&RequestCounterWrite();
		}; # if ( time() > $LastSmsSend + $SendSmsDelay ) {
		
	}; # foreach my $smsto (@admin_sms_deliver) {

	return 1;

}; # sub SendStatusSMS(){




sub Get() {
		
	#my $self	= shift;
	my $url		= shift;
	my $referer	= $url;
	
	my $UA		= LWP::UserAgent->new( keep_alive => 1 );
	
	$UA->agent("Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; YPC 3.0.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)");
	$UA->timeout( $Timeout );
	$UA->max_size( $MaxFileSizeOfWebDocument );
	$UA->from( $AuthorEmail );
	$UA->max_redirect( $MaxRedirectRequests );
	$UA->parse_head( 1 );
	$UA->protocols_allowed( [ 'http', 'https', 'ftp', 'ed2k'] );
	$UA->protocols_forbidden( [ 'file', 'mailto'] );
	$UA->requests_redirectable( [ 'HEAD', 'GET', 'POST'] );

	my $req = HTTP::Request->new( GET => $url );
	$req->referer($referer);

	my $res = $UA->request($req);

	if ( $res->is_success ) {

		#$StatusHashRef->{ 'OBJ' } = $res; 
		return $res->content; 
		
	}; # if ($res->is_success) {

	return 0;

}; # sub GET() {



sub RequestCounterWrite(){

	tie(%CurrentSearchRequests, 'DB_File', $SMS_DB ) || warn "can't open $SMS_DB: $!";
	flock(%CurrentSearchRequests,LOCK_EX);
		$CurrentSearchRequests{'LASTACCESS'} = time();
	flock(%CurrentSearchRequests, LOCK_UN);
	untie(%CurrentSearchRequests);

	return;
	
};	# sub NoResultDatabaseManager(){



sub RequestCounterRead(){

	tie(%CurrentSearchRequests, 'DB_File', $SMS_DB ) || warn "can't open $SMS_DB: $!";
		if ( length($CurrentSearchRequests{'LASTACCESS'}) > 0 ) {
			return $CurrentSearchRequests{'LASTACCESS'};
		} else {
			return 0;
		}
	untie(%CurrentSearchRequests);
		
};	# sub NoResultDatabaseManager(){



sub dumpa(){
	my $ReturnHost		= "";
	my $status			= "";
	my @ReturnHostArr	= ();
	my $ReturnHostArr;

	while( ($ReturnHost,$status) = each(%{$ServerStatus})){
		next if ( $status == 0 );
		print "HOST:'$ReturnHost' und status:'$status' \n";

		# der mainsql server ist verfügbar mit positivem status wert, nehme ihn
		if ( ($ReturnHost eq $MainSqlServer) && ($status == 1) ) {		# 'eq' gleich
		#	print "Main SQL [$ReturnHost] is available! \n";
			push(@ReturnHostArr, $ReturnHost);
			return $ReturnHost;
		} elsif ( ($ReturnHost ne $MainSqlServer) && ($status == 1) ) {	# 'ne' nicht gleich
		#	print "SQL [$ReturnHost] is alive \n";
			push(@ReturnHostArr, $ReturnHost);
			return $ReturnHost;
		}

	}; # while( my ($host,$ports) = each(%ParisHosts)){

use Data::Dumper;
	print Dumper @ReturnHostArr;
	print Dumper $ReturnHostArr;

	if ( length($ReturnHostArr[0]) > 0 ){
		return $ReturnHostArr[0];
	} else {
		return $MainSqlServer;	
	};
}

return 1;