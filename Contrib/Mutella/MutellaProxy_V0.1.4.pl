#!/usr/bin/perl -I/root/.mutella/MutellaProxy

##########################################################
# tod: client has requested: eventuell rauslassen, wenn ResultCleaner.pm funzt
##########################################################

use strict;

# für den server
use IO::Socket;
use IO::File;
use IO::Select;
use Net::hostent;

# für die parameter
use Getopt::Std;

# debug
use Data::Dumper;

# mutella
use MutellaProxy::IO;
use MutellaProxy::Parser;
use MutellaProxy::Daemon;
use MutellaProxy::Mutella;
use MutellaProxy::Logging;
use MutellaProxy::Mutella;
use MutellaProxy::SortRank;
use MutellaProxy::ResultCache;
use MutellaProxy::ResultCleaner;
use MutellaProxy::LicenceManagement;
			
# md5
# later: use MutellaProxy::MD5->new()
# use Digest::MD5 qw(md5 md5_hex md5_base64);
use Digest::MD5 qw( md5_hex );
use constant CRLF => "\r\n";

##########################################################

my $IO				= MutellaProxy::IO->new();
my $PARSER			= MutellaProxy::Parser->new();
my $LOGGING			= MutellaProxy::Logging->new();
my $MUTELLA			= MutellaProxy::Mutella->new();
my $SORTRANK		= MutellaProxy::SortRank->new();
my $CACHE			= MutellaProxy::ResultCache->new();
my $CLEANER			= MutellaProxy::ResultCleaner->new();
my $LICENCE			= MutellaProxy::LicenceManagement->new();

##############
my $MutellaSocket	= MutellaProxy::IO->CreateMutellaSocket();
my $ProxySocket		= MutellaProxy::IO->CreateProxySocket();
my $FILE			= '/root/.mutella/IDS';
my $NUMBEROFRESULTS	= 10;
##############

my $listHashRef = {};
my %options;
my $ClientHasRequested = {};
my $SendString;

my $DONE	= 0;
$SIG{INT}	= $SIG{TERM} = sub { $DONE++ };

############################################################

getopts( 'u:hlf:', \%options ) or &usage();

my $IN = IO::Select->new($ProxySocket);

# create PID file, initialize logging, and go into the background
# init_server(PIDFILE);

die "can't setup server" unless $ProxySocket;
print "[Server $0 accepting clients on port $port]\n";

# accept loop
while (!$DONE) {

  next unless $IN->can_read;
  next unless my $HandyClientSocket = $ProxySocket->accept;
  my $hostinfo = gethostbyaddr($HandyClientSocket->peeraddr);

  my $child = launch_child();

  unless ($child) {
 
#	alle beiden sachen NICHT AKTIVIEREN,SONST KLAPPT ES NICHT  
#	$HandyClientSocket->autoflush(1);
#	$HandyClientSocket->blocking(0);

	close $ProxySocket;

	my $ReadFromClient = $IO->readSocket( $HandyClientSocket );
	my $IOReadFromClient;

	# hier entschlüsseln

	my $bytes_in	+= length($ReadFromClient);
	my ( @IOReadFromClient ) = split("\r\n", $ReadFromClient); 

	############### Licence checken - Start ################
	my ( $Status, $FileTypeHashRef ) = $LICENCE->CheckLicence( \@IOReadFromClient );

	if ( $Status != 1 ) {
		
		print "CheckLicence failed - from: ", $hostinfo->name , "\n";
		$IO->writeSocket($HandyClientSocket, $Status . CRLF);
		close $HandyClientSocket;
		$LOGGING->LogToFileInvalidLicence( \$ReadFromClient );	
		exit(0);	# reicht das hier zum beenden ?
	
	};
	############### Licence checken - Ende ################

	if ( CheckStatusFlag( \@IOReadFromClient ) == 1 ) {
		&FindFunction( \@IOReadFromClient , \$ReadFromClient , $hostinfo, $HandyClientSocket );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 2 ) {
		&ResultFunction( \@IOReadFromClient , \$ReadFromClient , $hostinfo, $HandyClientSocket, $FileTypeHashRef );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 3 ) {
		&DownloadStartFunction( \$ReadFromClient );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 4 ) {
		&DownloadEndFunction( \$ReadFromClient );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 5 ) {
		&LicenceFunction( $HandyClientSocket, \@IOReadFromClient );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 6 ) {
		&ResultRangeFunction( \@IOReadFromClient , \$ReadFromClient , $hostinfo, $HandyClientSocket );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == -1 ) {
		&ErrorFunction( $HandyClientSocket );

	} else {
		&ErrorFunction( $HandyClientSocket );

	};

	exit(0);

  }; #  unless ($child) {}

  close $HandyClientSocket;

}; # while (!$DONE) {}


die "Normal termination\n";


############################
######## FUNCTIONS #########
############################


sub ResultRangeFunction(){

	#	7.1 Suchergebnisse Ranged anfragen
	#	Status | Flag | IMEI | Lizenzkey |
	#	Clientversion | Suchbegriff | Results ID | RANGE FROM | RANGE TO

	my $ArrayRef			= shift;
	my $ReadFromClientRef	= shift;
	my $hostinfo			= shift;
	my $HandyClientSocket	= shift;
			
	my @IOReadFromClient	= @{$ArrayRef};
	my $QueryClientID		= $IOReadFromClient[6];

	my $From				= $IOReadFromClient[7];
	my $To					= $IOReadFromClient[8];

	printf "[Connect from %s - ID $QueryClientID ] - Sending Cache Result \n", $hostinfo->name;

	# benutze ResultCache.pm um eine ergebnis Range zu holen und an den client zu senden
	my $SendString = $CACHE->readCache( $From, $To, $QueryClientID );

	# gib die ergebnisse aus
	$IO->writeSocket( $HandyClientSocket, $SendString , 0.50 );
	$IO->writeSocket( $HandyClientSocket, CRLF );

	# Logging
	$LOGGING->LogToFileGetResults( $ReadFromClientRef );	

	return 1;

}; # sub ResultRangeFunction(){}


sub FindFunction(){

	my $ArrayRef			= shift;
	my $ReadFromClientRef	= shift;
	my $hostinfo			= shift;
	my $HandyClientSocket	= shift;
		
	my @IOReadFromClient	= @{$ArrayRef};
	
	$MUTELLA->find( $MutellaSocket, $IOReadFromClient[5] );

	my $ClientID = md5_hex( $hostinfo->name . time() . $MUTELLA->random() ); 
	
	printf "[Connect from %s - ID $ClientID ] - Submitted Search '$IOReadFromClient[5]' to Mutella\n", $hostinfo->name;

	$IO->writeSocket( $HandyClientSocket, $ClientID . CRLF );
	$IO->writeSocket( $HandyClientSocket, CRLF );

	open(WH,">$FILE/$ClientID") or die;
		print WH $IOReadFromClient[5];
	close WH;

	$LOGGING->LogToFileInit( $ReadFromClientRef );	
	$CLEANER->writeResultFile( $IOReadFromClient[5] );

	return 1;

};	# sub FindFunction(){}


sub ResultFunction(){

	# benutze ResultCache.pm und speichere die sortierten ergebnisse zwischen
	# ResultCache.pm speichere ergebisse

	my $ArrayRef			= shift;
	my $ReadFromClientRef	= shift;
	my $hostinfo			= shift;
	my $HandyClientSocket	= shift;
	my $FileTypeHashRef		= shift;
		
	my @IOReadFromClient	= @{$ArrayRef};
	my $QueryClientID		= $IOReadFromClient[6];
	my $SEARCH;

	chomp($QueryClientID);
	
	open(RH,"<$FILE/$QueryClientID");
		$SEARCH	= <RH>;	
	close RH;

	printf "[Connect from %s] - Searving Request for ID '$QueryClientID' and Query: '$SEARCH' \n", $hostinfo->name;
	my $QueryNumber = $MUTELLA->getResultID( $MutellaSocket, $SEARCH );

	print "############# QueryNumber: $QueryNumber \n";

	if ( $QueryNumber == 0 ) {
		print "############# ResultQuery Mismatch\n";
		$IO->writeSocket($HandyClientSocket, "query invalid" . CRLF); # FC 106 senden
		return -1;
	};
	
	my $DownloadHashRef		  = $PARSER->ResultCommandParser( $MutellaSocket, $QueryNumber );
 	my $SortedResultsArrayRef = $SORTRANK->SortRank( $DownloadHashRef, $SEARCH , $FileTypeHashRef );
		
	print "############# Number of Results: " . $#{$SortedResultsArrayRef} . " ############## \n";
		
	# wenn noch kein ergebnis für die suchanfrage vorliegt
	if ( $#{$SortedResultsArrayRef} == 0 ) {

		# wenn öfters als 5 mal kein ergebnis kam, dann lösche den eintrag aus dem mutella
		if ( %{$ClientHasRequested}->{ $QueryClientID } == 5 ) {
			
			# lösche den korrespondierenden $QueryNumber Eintrag
		
			$MUTELLA->del( $MutellaSocket, $QueryNumber );

			$IO->writeSocket( $HandyClientSocket, "no results" , 0.50 ); # FC 404 senden
			$IO->writeSocket( $HandyClientSocket, CRLF );

			# lösche den eintrag aus dem hash herraus:
			delete $ClientHasRequested->{ $QueryClientID };

		} else {

			# gib aus, dass der handy client noch etwas warten soll
			$IO->writeSocket( $HandyClientSocket, "busy" , 0.50 ); # FC 303 
			$IO->writeSocket( $HandyClientSocket, CRLF );

			# zähle hoch, wie oft für eine ClientID schon ein ergebnis angefragt wurde 
			$ClientHasRequested->{ $QueryClientID }++;

		};	# if ( %{$ClientHasRequested}->{ $QueryClientID } == 5 ) {}

	} else { # if ( $#{$SortedResultsArrayRef} != 0 ) {
		
		my $RC = 0;
		foreach  my $entry ( @{$SortedResultsArrayRef} ) {
			
			next if ( $RC > $NUMBEROFRESULTS );

			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split(' # ', $entry );
			
			print "DEBUG: $RANK \n";
			print "DEBUG: $PEERHOST \n";
			print "DEBUG: $SIZE \n";
			print "DEBUG: $SHA1 \n";

			$SendString .= $RANK . "\r\n" . $SIZE . "\r\n" . $SHA1 . "\r\n" . $PEERHOST . "\r\n";
			$RC++;

		};

		# gib die ergebnisse aus
		$IO->writeSocket( $HandyClientSocket, $SendString , 0.50 );
		$IO->writeSocket( $HandyClientSocket, CRLF );

		$CACHE->writeCache( $SortedResultsArrayRef );
		$MUTELLA->del( $MutellaSocket, $QueryNumber );
	
		$LOGGING->LogToFileGetResults( $ReadFromClientRef, $QueryClientID );	

	};

	return 1;

};	# sub ResultFunction(){}


sub DownloadStartFunction(){

	my $ReadFromClientRef	= shift;
	$LOGGING->LogToFileStartDownload( $ReadFromClientRef );	
	print "DEBUG: Download Start Log\n";
	
	return 1;

};	# sub DownloadStartFunction(){}


sub DownloadEndFunction(){

	my $ReadFromClientRef	= shift;
	$LOGGING->LogToFileFinishDownload( $ReadFromClientRef );	
	print "DEBUG: Download End Log\n";
	
	return 1;

}; # sub DownloadEndFunction(){}


sub LicenceFunction(){

	my $HandyClientSocket	= shift;
   	my $ArrayRef			= shift;

	my ( $Status, $HashRef ) = $LICENCE->CheckLicence( $ArrayRef );
	
	if ( $Status != 1 ) {
		$IO->writeSocket($HandyClientSocket, $Status . CRLF);
		close $HandyClientSocket;
		exit(0);	# reicht das hier zum beenden ?
	};
	
	return 1;

}; # sub LicenceFunction(){}


sub ErrorFunction(){

	my $HandyClientSocket = shift;
		
	$IO->writeSocket( $HandyClientSocket, "FC 105" , 0.50 );
	$IO->writeSocket( $HandyClientSocket, CRLF );
	close $HandyClientSocket;

	return 1;

}; # sub ErrorFunction(){}


sub CheckStatusFlag(){
		
	my $ArrayRef = shift;
	
	if ( lc($ArrayRef->[0]) eq 'find' ) { # fi
		return 1;
	} elsif ( lc($ArrayRef->[0]) eq 'result' ){	# re
		return 2;
	} elsif ( lc($ArrayRef->[0]) eq 'dlstartlog' ){	# ds
		return 3;
	} elsif ( lc($ArrayRef->[0]) eq 'dlendlog' ){ # de
		return 4;
	} elsif ( lc($ArrayRef->[0]) eq 'licence' ){ # li
		return 5;
	} elsif ( lc($ArrayRef->[0]) eq 'resultrange' ){ # rr
		return 6;
	} else {
		return -1;
	};

	# always return false
	return -1;

}; # sub CheckStatusFlag(){}


sub usage() {

print "perl $0 -h : gives help\n"
	."perl $0 -l : lists currently queued search results in mutella\n"
	."perl $0 -f SEARCH QUERY: Search for your query in mutella!\n"
	."perl $0 -u ultrapeerlist.txt : conncect to ultrapeers from file\n";

	exit(0);

}; # sub usage() {}

############################################################

# find min:/size: $query

###########################################################
#
# use constant UNIXSOCKET		=> "/root/.mutella/socket";
#
############################################################

########## CLIENT SOCKET->MUTELLA ############
#
# my $MutellaSocket = IO::Socket::UNIX->new( 
#	Peer => UNIXSOCKET,
#    Type => SOCK_STREAM,
#    Timeout => 60 ) or die "can't connect to Unix Socket for CLIENT SOCKET->MUTELLA IO: $!\n";
#
# $MutellaSocket->autoflush(1) if (defined($MutellaSocket));
# $MutellaSocket->blocking(0) if (defined($MutellaSocket));
#
############## HANDY->SERVER SOCKET ###########
#
# use constant PIDFILE => '/tmp/web_fork.pid';
#
# my $port	= 3381;
# my $ProxySocket	= IO::Socket::INET->new( 
#	LocalPort => $port,
#    Listen    => SOMAXCONN,
#    Reuse     => 1 ) or die "Can't create listen socket: $!";
#
# $ProxySocket->setsockopt(SO_ERROR,SO_LINGER,SO_KEEPALIVE);
# $ProxySocket->autoflush(1);
# $ProxySocket->blocking(0);
#
