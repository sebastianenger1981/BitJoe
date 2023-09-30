#!/usr/bin/perl -I/root/.mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	13.07.2006
##### Function:		Hauptdatei für MutellaProxy
##### Todo:			for statt foreach: ist schneller
##### MileStones:	IPBlocker.pm->IPBlocker() funktioniert
#####				Status.pm->readStatus() funktioniert
#####				SortRank.pm->SortRank() funktioniert
########################################



system("clear");

# todo: connection counter - nach 5 mal keine ergebnisse bemühe den result cache
# connection request daten abholen: 20s, 10s, 10s, 7s, 5s, public result cache
# IOTransfer.pm funzt noch nicht

my $VERSION = '0.18.1';

use strict;

# für den server
use IO::Socket;
# use IO::File;
use IO::Select;
use Net::hostent;

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
use MutellaProxy::ResultCache;
use MutellaProxy::CryptoLibrary;
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
my $CACHE			= MutellaProxy::ResultCache->new();
my $CLEANER			= MutellaProxy::ResultCleaner->new();
my $CRYPTO			= MutellaProxy::CryptoLibrary->new();
my $LICENCE			= MutellaProxy::LicenceManagement->new();

##############
my $MutellaSocket	= MutellaProxy::IO->CreateMutellaSocket();
my $ProxySocket		= MutellaProxy::IO->CreateProxySocket();
my $FILE			= '/root/.mutella/IDS';
my $NUMBEROFRESULTS	= 10;
##############

my $IOReadFromClient;
my $ConnectionCounter	= 0;
my $TIMEOUT				= 120;
my $DONE				= 0;

###################################

$SIG{'INT'}		= $SIG{'TERM'} = sub { $DEBUG->Debugging( '', $SIG , 'SignalHandler Interrupt' , ''); $DONE++; };
$SIG{'ALRM'}	= sub { $MUTELLA->GetAndInstallUltraPeerHostList(); }; # fork und dann im prozess diese funktion aufrufen

############################################################

my $IN = IO::Select->new($ProxySocket);

# create PID file, initialize logging, and go into the background
# &init_server(PIDFILE);

die "can't setup server" unless $ProxySocket;
print "[Server $0 accepting clients on port 3381]\n";

# accept loop
while (!$DONE) {

  next unless $IN->can_read;
  next unless my $HandyClientSocket = $ProxySocket->accept();
  my $hostinfo	= gethostbyaddr($HandyClientSocket->peeraddr);

  my $HandyClientIPAdress = $HandyClientSocket->sockhost;
  my $HandyClientHostName = $hostinfo->name;

  # print "Connection from [IP:$HandyClientIPAdress] DNS-Name: $HandyClientHostName \n";

  # Starte den IPBlocker() und gucke ob, eine HandyIP nicht erwünscht ist: Start
  my $BlockerFlag = $IPFILTER->IPBlocker( $HandyClientIPAdress );
  if ( $BlockerFlag == -1 ) {
	printf "[Connect from $HandyClientHostName IP $HandyClientIPAdress] - Rejected by IPBlocker\n";
	$DEBUG->Debugging( $IPFILTER, $BlockerFlag , "[Connect from $HandyClientHostName IP $HandyClientIPAdress] - Rejected by IPBlocker " , '');
	exit(0);	
  }; # if ( $StatusFlag == 1 ) {}
  # IPBlocker(): Ende


  my $child	= launch_child();


  unless ($child) {
 
	close $ProxySocket;

	
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


	# Nehme den Content vom Handy an
	my $ReadFromClient = $IO->readSocket( $HandyClientSocket );
	my ( @IOReadFromClient ) = split("\r\n", $ReadFromClient ); 


	# NEW: 12.7
	# HIER DAS ENTSCHLÜSSELN ANSETZEN: START
	# $IOReadFromClient[0] = MD5 Wert der Verschlüsselten Nachricht
	# $IOReadFromClient[1] = der public schlüssel, anhand deren entschieden wird, welcher kryptkey zum entschlüsseln genommen werden muss 
	# $IOReadFromClient[2] = die verschlüsselte nachricht
	# 1.) teste, ob MD5 Wert für $IOReadFromClient[2] korrekt ist ja->goon: sende OK an handy zurück, nein: write error message an handyclient udn beende mich
	# 2.) hole den privaten KryptoKey für den public key $IOReadFromClient[1] mittels MutellaProxy::CryptoLibrary->GetPrivateCryptoKeyFromDatabase() 
	#   zu 2.)und speichere diesen temporär zwischen mittels MutellaProxy::CryptoLibrary->WritePrivateCryptoKeyForSession( );
	# 3.) entschlüssele die nachricht ; diese ist dann das neue @IOReadFromClient
	# HIER DAS ENTSCHLÜSSELN ANSETZEN: ENDE

	# Verschlüsseln: hole aus temporären datei den privaten kryptokey mittels MutellaProxy::CryptoLibrary->WritePrivateCryptoKeyForSession(  );
	# verpacke alles: und dann verschlüssele es: 
	# schicke dem handy: MD5\r\nCRYPTCONTENT\r\n
	
	####################### crypto abi implementatione #####################
#	$IOReadFromClient[0] = MD5 Wert der Verschlüsselten Nachricht
#	$IOReadFromClient[1] = der public schlüssel 
#	$IOReadFromClient[2] = die verschlüsselte nachricht
	
#	my $PrivateCryptoKey = $CRYPTO->GetPrivateCryptoKeyFromDatabase( $IOReadFromClient[1] );
#	if ( $PrivateCryptoKey == -1 ) {
#		# fehlermeldung an client ausgeben
#		&ErrorFunction( $HandyClientSocket );
#		exit(0);
#	}; # if ( $PrivateKey == -1 ) {}
#
#	my $PlainText = $CRYPTO->Decrypt( $PrivateCryptoKey, $IOReadFromClient[2] );
#
#	if ( $IOReadFromClient[0] ne $CHECKSUM->MD5ToHEX($PlainText) ) {
#		# schreibe dem client, das er die daten nochmal übertragen soll
#	};
#
#	my ( @IOReadFromClient ) = split("\r\n", $PlainText ); 


	############### Licence checken - Start ################
	my ( $Status, $FileTypeHashRef ) = $LICENCE->CheckLicence( \@IOReadFromClient );

	if ( $Status != 1 ) {
		print "CheckLicence failed - from: ", $hostinfo->name , "\n";
		$IO->writeSocket($HandyClientSocket, $Status . CRLF);
		close $HandyClientSocket;
		$LOGGING->LogToFileInvalidLicence( \$ReadFromClient );	
		exit(0);
	}; # if ( $Status != 1 ) {}
	############### Licence checken - Ende ################


	# Checke, welche Art von Request reinkommt und benutze entsprechende Subroutine dafür
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

	# hier loggen wir mit,vieviel Traffic am tag entsteht -> später dann für jedes handy den traffic separat loggen
	
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

	# Erstelle die CheckSumme für einen eingehenden Request - zusammengesetzt aus entsprechenden Werten
	my $ClientID = $CHECKSUM->MD5ToHEX( $hostinfo->name . time() . $CRYPTO->SimpleRandom() . $CRYPTO->URandom() . $#IOReadFromClient ); 
	
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

	if ( $QueryNumber eq 'NORESULTS' ) {
		print "############# ResultQuery Mismatch ############ \n";
		
		# todo: speichere den ResultCache so ab, wie das suchergebnis lautet
		# schaue nach, ob ein gültiger cache für diesen suchbegriff existiert
		# lese den cache und gib den inhalt des caches als result aus

		$IO->writeSocket($HandyClientSocket, "query invalid" . CRLF); # FC 106 senden
		return 0;
	}; # if ( $QueryNumber eq 'NORESULTS' ) {}
	
	my $DownloadHashRef			= $PARSER->ResultCommandParser( $MutellaSocket, $QueryNumber );
 	my $SortedResultsArrayRef	= $SORTRANK->SortRank( $DownloadHashRef, $SEARCH , $FileTypeHashRef );
	my $NumberOfResults			= $#{$SortedResultsArrayRef};

	print "############# Number of Results: $NumberOfResults ############## \n";
	
	# wenn noch kein ergebnis für die suchanfrage vorliegt - schaue nach im Cache und liefere ein Cache Ergebnis
	if ( $NumberOfResults == 0 || $NumberOfResults == -1 ) {

		# gib aus, dass der handy client noch etwas warten soll
		$IO->writeSocket( $HandyClientSocket, "busy" . CRLF , 0.10 ); # FC 303 
		
	} else {
		
		my $RC = 0;
		my $SendString;

		foreach my $entry ( @{$SortedResultsArrayRef} ) {
			
			next if ( $RC > $NUMBEROFRESULTS );
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $entry );
			chop($SHA1) if ( length($SHA1) == 33 );	# fix für Sort::Array->Sort_Table();

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

		# gib die ergebnisse aus
		# $IO->writeSocket( $HandyClientSocket, $SendString , 0.50 );
		# $IO->writeSocket( $HandyClientSocket, CRLF );
		$IO->writeSocket( $HandyClientSocket, $SendString . CRLF );

		$CACHE->writeCache( $SortedResultsArrayRef, $QueryClientID, $SEARCH, 'PRIVATE' );		# schreibe für die id einen privaten cache
		$CACHE->writeCache( $SortedResultsArrayRef, $QueryClientID, $SEARCH, 'PUBLIC' );	# schreibe für den suchbegriff einen public cache

		$MUTELLA->del( $MutellaSocket, $QueryNumber );
		
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
	$IO->writeSocket( $HandyClientSocket, \$SendString , 0.50 );
	$IO->writeSocket( $HandyClientSocket, CRLF );

	# Logging
	$LOGGING->LogToFileGetResults( $ReadFromClientRef );	
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
		exit(0);
	}; # if ( $Status != 1 ) {}
	
	return 1;

}; # sub LicenceFunction(){}


sub ErrorFunction(){

	my $HandyClientSocket = shift;
		
	$IO->writeSocket( $HandyClientSocket, "FC 105" .CRLF );
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
