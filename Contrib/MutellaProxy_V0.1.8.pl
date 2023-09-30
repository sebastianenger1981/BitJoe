#!/usr/bin/perl -I/root/.mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		Hauptdatei f�r MutellaProxy
##### Todo:			for statt foreach: ist schneller
########################################

system("clear");

# todo: connection counter - nach 5 mal keine ergebnisse bem�he den result cache
# connection request daten abholen: 20s, 10s, 10s, 7s, 5s, public result cache

my $VERSION = '0.18.1';

use strict;

# f�r den server
use IO::Socket;
# use IO::File;
use IO::Select;
use Net::hostent;

# debug
use Data::Dumper;

# mutella
use MutellaProxy::IO;
use MutellaProxy::Debug;
use MutellaProxy::Status;
use MutellaProxy::Parser;
use MutellaProxy::Daemon;
use MutellaProxy::Mutella;
use MutellaProxy::Logging;
use MutellaProxy::Mutella;
use MutellaProxy::IPFilter;
use MutellaProxy::SortRank;
use MutellaProxy::CheckSum;
use MutellaProxy::IOTransfer;
use MutellaProxy::ResultCache;
use MutellaProxy::ResultCleaner;
use MutellaProxy::LicenceManagement;

use constant CRLF => "\r\n";

# gib aus debug
# print $DEBUG->Debugging( $RefObj, $VarToDump, $ManualEditedText ,'SCREEN');

# logge debugmeldung
# $DEBUG->Debugging( $RefObj, $VarToDump );

##########################################################

my $IO				= MutellaProxy::IO->new();
my $DEBUG			= MutellaProxy::Debug->new();
my $PARSER			= MutellaProxy::Parser->new();
my $LOGGING			= MutellaProxy::Logging->new();
my $MUTELLA			= MutellaProxy::Mutella->new();
my $IPFILTER		= MutellaProxy::IPFilter->new();
my $SORTRANK		= MutellaProxy::SortRank->new();
my $CHECKSUM		= MutellaProxy::CheckSum->new();
my $TRANSFER		= MutellaProxy::IOTransfer->new();
my $CACHE			= MutellaProxy::ResultCache->new();
my $CLEANER			= MutellaProxy::ResultCleaner->new();
my $LICENCE			= MutellaProxy::LicenceManagement->new();

##############
my $MutellaSocket	= MutellaProxy::IO->CreateMutellaSocket();
my $ProxySocket		= MutellaProxy::IO->CreateProxySocket();
my $FILE			= '/root/.mutella/IDS';
my $NUMBEROFRESULTS	= 10;
##############

my $SendString;
my $IOReadFromClient;
my $ConnectionCounter	= 0;
my $DONE				= 0;

###################################

$SIG{INT}	= $SIG{TERM} = sub { $DEBUG->Debugging( '', $SIG , 'SignalHandler Interrupt' , ''); $DONE++; };

############################################################

my $IN = IO::Select->new($ProxySocket);

# create PID file, initialize logging, and go into the background
&init_server(PIDFILE);

die "can't setup server" unless $ProxySocket;
print "[Server $0 accepting clients on port 3381]\n";

# accept loop
while (!$DONE) {

  next unless $IN->can_read;
  next unless my $HandyClientSocket = $ProxySocket->accept();

	# NEW: 12.7
  my $HandyClientIPAdress = $HandyClientSocket->sockhost;
  my $HandyClientHostName = $HandyClientSocket->peeraddr;

  print "Connection from $HandyClientHostName [IP:$HandyClientIPAdress] \n";

  #	my $client_ip = getpeername($HandyClientSocket);
  #	my ($port, $ipaddr) = unpack_sockaddr_in($client_ip);
  #	my $HandyClientIPAdress = inet_ntoa($ipaddr);


# NEW: 12.7
  # MutellaProxy::IPFilter->IPBlocker(): Start
  my $StatusFlag = $IPFILTER->IPBlocker( $HandyClientIPAdress );
  if ( $StatusFlag == 1 ) {
	printf "[Connect from %s - IP %s] - Rejected by IPBlocker\n", $HandyClientHostName, $HandyClientIPAdress;
	$DEBUG->Debugging( $IPFILTER, $StatusFlag , 'Rejected by IPBlocker: ' . $HandyClientHostName  , '');
	exit(0);	
  }; # if ( $StatusFlag == 1 ) {}
  # MutellaProxy::IPFilter->IPBlocker(): Ende


  my $hostinfo	= gethostbyaddr($HandyClientSocket->peeraddr);
  my $child		= launch_child();

  unless ($child) {
 
	close $ProxySocket;

	my $ReadFromClient = $IO->readSocket( $HandyClientSocket );
	my ( @IOReadFromClient ) = split("\r\n", $ReadFromClient); 


	# Checke das ServerStatusFlag: Start
	my $StatusFlag = MutellaProxy::Status->readStatus();
	if ( $StatusFlag ne '1' ) {
		# FC 808 - Server Busy - Flag to set when restart of MutellaProxy is needed
		$IO->writeSocket( $HandyClientSocket, "FC 808". CRLF );
		close $HandyClientSocket;
		$DEBUG->Debugging('' , $hostinfo , 'ServerBusy Flag - FC 808' , '');
		exit(0);
	}; # if ( $StatusFlag ne '1' ) {}
	# Checke das ServerStatusFlag: Ende
	

# NEW: 12.7
	# HIER DAS ENTSCHL�SSELN ANSETZEN: START
	# $IOReadFromClient[0] = MD5 Wert der Verschl�sselten Nachricht
	# $IOReadFromClient[1] = der public schl�ssel, anhand deren entschieden wird, welcher kryptkey zum entschl�sseln genommen werden muss 
	# $IOReadFromClient[2] = die verschl�sselte nachricht
	# 1.) teste, ob MD5 Wert f�r $IOReadFromClient[2] korrekt ist ja->goon: sende OK an handy zur�ck, nein: write error message an handyclient udn beende mich
	# 2.) hole den privaten KryptoKey f�r den public key $IOReadFromClient[1] mittels MutellaProxy::CryptoLibrary->GetPrivateCryptoKeyFromDatabase() 
	#   zu 2.)und speichere diesen tempor�r zwischen mittels MutellaProxy::CryptoLibrary->WritePrivateCryptoKeyForSession( );
	# 3.) entschl�ssele die nachricht ; diese ist dann das neue @IOReadFromClient
	# HIER DAS ENTSCHL�SSELN ANSETZEN: ENDE

	# Verschl�sseln: hole aus tempor�ren datei den privaten kryptokey mittels MutellaProxy::CryptoLibrary->WritePrivateCryptoKeyForSession(  );
	# verpacke alles: und dann verschl�ssele es: 
	# schicke dem handy: MD5\r\nCRYPTCONTENT\r\n
	

	############### Licence checken - Start ################
	my ( $Status, $FileTypeHashRef ) = $LICENCE->CheckLicence( \@IOReadFromClient );

	if ( $Status != 1 ) {
		
		print "CheckLicence failed - from: ", $hostinfo->name , "\n";
		$IO->writeSocket($HandyClientSocket, $Status . CRLF);
		close $HandyClientSocket;
		$LOGGING->LogToFileInvalidLicence( \$ReadFromClient );	
		my $len = length( $Status . CRLF );
		$TRANSFER->LogBytes( $len );
		exit(0);	# reicht das hier zum beenden ?
	
	}; # if ( $Status != 1 ) {}
	############### Licence checken - Ende ################


	# Checke, welche Art von Request reinkommt und benutze entsprechende Subroutine daf�r
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

	}; # if ( CheckStatusFlag( \@IOReadFromClient ) == 1 ) {}


	$DEBUG->Debugging( $IO, $ReadFromClient , 'Handy<->Proxy IO' , '' );

	# hier loggen wir mit,vieviel Traffic am tag entsteht -> sp�ter dann f�r jedes handy den traffic separat loggen
	my $len = length($ReadFromClient);
	$TRANSFER->LogBytes( $len );

	exit(0);

  }; #  unless ($child) {}

  close $HandyClientSocket;

}; # while (!$DONE) {}


die "Normal termination\n";


############################
######## FUNCTIONS #########
############################


sub FindFunction(){

	my $ArrayRef			= shift;
	my $ReadFromClientRef	= shift;
	my $hostinfo			= shift;
	my $HandyClientSocket	= shift;
		
	my @IOReadFromClient	= @{$ArrayRef};
	
	$MUTELLA->find( $MutellaSocket, $IOReadFromClient[5] );

	# Erstelle die CheckSumme f�r einen eingehenden Request - zusammengesetzt aus entsprechenden Werten
	my $ClientID = $CHECKSUM->MD5ToHEX( $hostinfo->name . time() . $MUTELLA->SimpleRandom() . $MUTELLA->URandom() . $#IOReadFromClient ); 
	
	printf "[Connect from %s - ID $ClientID ] - Submitted Search '$IOReadFromClient[5]' to Mutella\n", $hostinfo->name;

	$IO->writeSocket( $HandyClientSocket, $ClientID . CRLF );
	$IO->writeSocket( $HandyClientSocket, CRLF );

	open(WH,">$FILE/$ClientID") or die;
		print WH $IOReadFromClient[5];
	close WH;

	$LOGGING->LogToFileInit( $ReadFromClientRef );	
	$CLEANER->writeResultFile( $IOReadFromClient[5] );
	my $len = length( $ClientID . CRLF . CRLF ); 
	$TRANSFER->LogBytes( $len);

	return 1;

};	# sub FindFunction(){}


sub ResultFunction(){

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

	print "############# QueryNumber: $QueryNumber ############## \n";

	if ( $QueryNumber == 0 ) {
		print "############# ResultQuery Mismatch ############ \n";
		$IO->writeSocket($HandyClientSocket, "query invalid" . CRLF); # FC 106 senden
		my $len = length( "query invalid" . CRLF)
		$TRANSFER->LogBytes( $len );
		return;
	};
	
	my $DownloadHashRef			= $PARSER->ResultCommandParser( $MutellaSocket, $QueryNumber );
 	my $SortedResultsArrayRef	= $SORTRANK->SortRank( $DownloadHashRef, $SEARCH , $FileTypeHashRef );
	my $NumberOfResults			= $#{$SortedResultsArrayRef};

	print "############# Number of Results: $NumberOfResults ############## \n";
	
	# todo: speichere den ResultCache so ab, wie das suchergebnis lautet
	# schaue nach, ob ein g�ltiger cache f�r diesen suchbegriff existiert
	# lese den cache und gib den inhalt des caches als result aus

	# wenn noch kein ergebnis f�r die suchanfrage vorliegt - schaue nach im Cache und liefere ein Cache Ergebnis
	if ( $NumberOfResults == 0 || $NumberOfResults == -1 ) {

		# gib aus, dass der handy client noch etwas warten soll
		$IO->writeSocket( $HandyClientSocket, "busy" . CRLF , 0.10 ); # FC 303 
		my $len = length( "busy" . CRLF );
		$TRANSFER->LogBytes( $len );

	} else {
		
		my $RC = 0;
		foreach my $entry ( @{$SortedResultsArrayRef} ) {
			
			next if ( $RC > $NUMBEROFRESULTS );
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $entry );
			chop($SHA1) if ( length($SHA1) == 33 );	# fix f�r Sort::Array->Sort_Table();

			print "RESULT: $RC\n";
			print "DEBUG: RANK: '$RANK' \n";
			print "DEBUG: SIZE: '$SIZE' \n";
			print "DEBUG: SHA1: '$SHA1' \n";
			print "DEBUG: HOST: '$PEERHOST' \n";
			print " ############ \n\n";

			# $SendString .= $RANK . "\r\n" . $SIZE . "\r\n" . $SHA1 . "\r\n" . $PEERHOST . "\r\n";
			# $SendString .= $RANK ."\r\n". $SIZE ."\r\n". $SHA1 ."\r\n". $PEERHOST ."\r\n";
			$SendString .= $RANK .CRLF. $SIZE .CRLF. $SHA1 .CRLF. $PEERHOST .CRLF;

			$RC++;

		};	# foreach my $entry ( @{$SortedResultsArrayRef} ) {}

		$SendString .= CRLF;

		# letzter eintrag ist immer die anzahl der ergebnisse
		# $SendString .= $#{$SortedResultsArrayRef} . "\r\n\r\n";
		
		# gib die ergebnisse aus
		$IO->writeSocket( $HandyClientSocket, $SendString , 0.50 );
		$IO->writeSocket( $HandyClientSocket, CRLF );

		$CACHE->writeCache( $SortedResultsArrayRef, $QueryClientID, $SEARCH, 'PRIVATE' );		# schreibe f�r die id einen privaten cache
		$CACHE->writeCache( $SortedResultsArrayRef, $QueryClientID, $SEARCH, 'PUBLIC' );	# schreibe f�r den suchbegriff einen public cache

		$MUTELLA->del( $MutellaSocket, $QueryNumber );
		
		my $len = length( $SendString . CRLF )
		$TRANSFER->LogBytes( $len );
		$LOGGING->LogToFileGetResults( $ReadFromClientRef, $QueryClientID );	

	}; # if ( $NumberOfResults == 0 || $NumberOfResults == -1 ) {}

	return 1;

};	# sub ResultFunction(){}


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
	# later: lese privaten oder/und public cache
	my $SendString = $CACHE->readCache( $From, $To, $QueryClientID, 'PRIVATE' );

	# gib die ergebnisse aus
	$IO->writeSocket( $HandyClientSocket, $SendString , 0.50 );
	$IO->writeSocket( $HandyClientSocket, CRLF );

	# Logging
	$LOGGING->LogToFileGetResults( $ReadFromClientRef );	
	my $len = length( $SendString . CRLF );
	$TRANSFER->LogBytes( $len );

	return 1;

}; # sub ResultRangeFunction(){}


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
		$LOGGING->LogToFileInvalidLicence( $ArrayRef );	
		my $len = length( $Status . CRLF );
		$TRANSFER->LogBytes( $len );
		exit(0);
	};
	
	return 1;

}; # sub LicenceFunction(){}


sub ErrorFunction(){

	my $HandyClientSocket = shift;
		
	$IO->writeSocket( $HandyClientSocket, "FC 105" .CRLF , 0.50 );
	my $len = length( "FC 105" . CRLF );
	$TRANSFER->LogBytes( $len );
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

	print "perl $0\n";
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
