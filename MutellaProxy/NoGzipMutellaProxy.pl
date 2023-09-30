#!/usr/bin/perl -I/server/mutella/MutellaProxy


# gzip: http://search.cpan.org/~pmqs/IO-Compress-Zlib-2.001/lib/IO/Compress/Gzip.pm


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

# perl -MCPAN -e 'install "Crypt::Rijndael"'
# perl -MCPAN -e 'install "Crypt::CBC"'
# perl -MCPAN -e 'install "LWP::Simple"'
# perl -MCPAN -e 'install "String::Approx"' 
# perl -MCPAN -e 'install "Net::SCP::Expect"' 
# perl -MCPAN -e 'install "MIME::Lite"' 
# perl -MCPAN -e 'install "Sort::Array"' 
# perl -MCPAN -e 'install "File::Basename"' 
# perl -MCPAN -e 'install "Net::Nslookup"' 
# perl -MCPAN -e 'install "Digest::MD4"' 
# perl -MCPAN -e 'install "Digest::MD5"'
# perl -MCPAN -e 'install "IO::Socket::SSL"'
# perl -MCPAN -e 'install "CPAN"'
# perl -MCPAN -e 'install "Scalar::Util"'
# perl -MCPAN -e 'install "Net::SSLeay"'
# perl -MCPAN -e 'install "Crypt::SSLeay"'
# perl -MCPAN -e 'install "Crypt::IDEA"'
# perl -MCPAN -e 'install "Digest::SHA"'
# perl -MCPAN -e 'install "Crypt::RSA"'
# perl -MCPAN -e 'install "Crypt::Blowfish"'
# perl -MCPAN -e 'install "Crypt::GPG"'
# perl -MCPAN -e 'install "XML::Parser"'
# perl -MCPAN -e 'install "XMLRPC::Lite"'


##########
#### Merke: $FileTypeHashRef->{ 0 } = FORMATBILD|FORMATMP3 usw
#### Merke: $FileTypeHashRef->{ 1 } = 'jpg|mp3' usw
##########


system("clear");

# todo: connection counter - nach 5 mal keine ergebnisse bemühe den result cache
# connection request daten abholen: 20s, 10s, 10s, 7s, 5s, public result cache

my $VERSION = '0.5.0';

use strict;

# für den server
# use IO::Socket;
# use IO::File;
use IO::Select;
use Net::hostent;
use Getopt::Long;

my $port = 3381;
#GetOptions ("port=i" => \$port ); 
die "perl $0 -port 3381\n" if ( $port != 3381 );


# mutella
use MutellaProxy::IO;
use MutellaProxy::Time;
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
use constant PIDFILE => "/server/mutella/PID-NOGZIP.file";

# gib aus debug
# print $DEBUG->Debugging( $RefObj, $VarToDump, $ManualEditedText ,'SCREEN');

# logge debugmeldung
# $DEBUG->Debugging( $RefObj, $VarToDump );

##########################################################

my $IO				= MutellaProxy::IO->new();
my $TIME			= MutellaProxy::Time->new();
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

###################################

my $IOReadFromClient;
my $TIMEOUT			= 140;
my $DONE			= 0;

##############
my $MutellaSocket	= MutellaProxy::IO->CreateMutellaSocket( $TIMEOUT );
my $ProxySocket		= MutellaProxy::IO->CreateProxySocket( $port );
my $FILE			= '/server/mutella/IDS';
my $DEBUGOUT		= '/server/mutella/DebugScreen.txt';
my $NUMBEROFRESULTS	= 10;
##############

###################################

$SIG{'INT'}		= $SIG{'TERM'} =	sub { $DEBUG->Debugging( '', $SIG , 'SignalHandler Interrupt' , ''); $DONE++; };

############################################################

my $IN = IO::Select->new($ProxySocket);

# für die finale version aktiviere das init_server();
# create PID file, initialize logging, and go into the background
unlink PIDFILE;
&init_server(PIDFILE);

die "can't setup server" unless $ProxySocket;
print STDOUT "[Server $0 Verion $VERSION accepting clients on port 3381]\n";


# print $MutellaSocket "open 62.146.88.94.6346 \n";	# krasser ultrapeer mit 87 TB horizont


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
	print STDOUT "[ Connect from DNS $HandyClientHostName <-> IP $HandyClientIPAdress ] - Rejected by IPBlocker\n";
	
	$DEBUG->Debugging( $IPFILTER, $BlockerFlag , "[Connect from DNS $HandyClientHostName <-> IP $HandyClientIPAdress] - Rejected by IPBlocker " , '');
	$IO->writeSocket( $HandyClientSocket, "FC 908". CRLF );
	close $HandyClientSocket;
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
		$IO->writeSocket( $HandyClientSocket, "FC 909". CRLF );
		close $HandyClientSocket;
		$DEBUG->Debugging('' , $hostinfo , 'ServerBusy Flag - FC 909' , '');
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
#	
#	my $PrivateCryptoKey = $CRYPTO->GetPrivateCryptoKeyFromDatabase( $IOReadFromClient[1] );
#	if ( $PrivateCryptoKey == -1 ) {
#		&ErrorFunction( $HandyClientSocket );
#		exit(0);
#	}; # if ( $PrivateKey == -1 ) {}
#
#	my $PlainText = $CRYPTO->Decrypt( $PrivateCryptoKey, $IOReadFromClient[2] );
#
#	if ( $IOReadFromClient[0] ne $CHECKSUM->MD5ToHEX($IOReadFromClient[2]) ) {
#		# schreibe dem client, das er die daten nochmal übertragen soll
#	};
#
#	my ( @IOReadFromClient ) = split("\r\n", $PlainText ); 


	############### Licence checken - Start ################
	my ( $Status, $FileTypeHashRef ) = $LICENCE->CheckLicence( \@IOReadFromClient );

	if ( $Status != 1 ) {
		print "CheckLicence failed - from: DNS $HandyClientHostName <-> IP $HandyClientIPAdress\n";
		
		$IO->writeSocket($HandyClientSocket, $Status . CRLF);
		close $HandyClientSocket;
		$LOGGING->LogToFileInvalidLicence( \$ReadFromClient );	
		exit(0);
	}; # if ( $Status != 1 ) {}
	############### Licence checken - Ende ################


	# Checke, welche Art von Request reinkommt und benutze entsprechende Subroutine dafür
	if ( CheckStatusFlag( \@IOReadFromClient ) == 1 ) {
		&FindFunction( \@IOReadFromClient , \$ReadFromClient , $hostinfo, $HandyClientSocket, $FileTypeHashRef );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 2 ) {
		&ResultFunction( \@IOReadFromClient , \$ReadFromClient , $hostinfo, $HandyClientSocket, $FileTypeHashRef );
		
	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 3 ) {
		&DownloadStartFunction( \$ReadFromClient );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 4 ) {
		&DownloadEndFunction( \$ReadFromClient );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 5 ) {
		&LicenceFunction( $HandyClientSocket, \@IOReadFromClient );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == 6 ) {
		&ResultRangeFunction( \@IOReadFromClient , \$ReadFromClient , $hostinfo, $HandyClientSocket, $FileTypeHashRef );

	} elsif ( CheckStatusFlag( \@IOReadFromClient ) == -1 ) {
		&ErrorFunction( $HandyClientSocket );

	} else {
		&ErrorFunction( $HandyClientSocket );

	}; # if ( CheckStatusFlag( \@IOReadFromClient ) == 1 ) {}


	$DEBUG->Debugging( $IO, $ReadFromClient , 'Handy<->Proxy IO' , '' );

	# hier loggen wir mit,vieviel Traffic am tag entsteht -> später dann für jedes handy den traffic separat loggen
	
	exit(0);

  }; #  unless ($child) {}


#  $HandyClientSocket->close( SSL_ctx_free => 1 );
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
	my $FileTypeHashRef		= shift;
		
	my @IOReadFromClient	= @{$ArrayRef};
	
	$IOReadFromClient[5] =~ s/ä/ae/ig;
	$IOReadFromClient[5] =~ s/ö/oe/ig;
	$IOReadFromClient[5] =~ s/ü/ue/ig;
	$IOReadFromClient[5] =~ s/ß/ss/ig;

	select(undef, undef, undef, 0.2 );
	$MUTELLA->find( $MutellaSocket, "$IOReadFromClient[5] $FileTypeHashRef->{1}" ); 

	my $CurTime = $TIME->MySQLDateTime();

	# printf "[Connect from %s at $CurTime ] - Submitted Search '$IOReadFromClient[5] $FileTypeHashRef->{1}' to Mutella\n", $hostinfo->name;
	printf STDOUT "[ Connect from %s at $CurTime ] - Submitted Search '$IOReadFromClient[5] $FileTypeHashRef->{1}' to Mutella\n", $HandyClientSocket->sockhost;

	# Erstelle die CheckSumme für einen eingehenden Request - zusammengesetzt aus entsprechenden Werten
	my $ClientID = $CHECKSUM->MD5ToHEX( $hostinfo->name . time() . $CRYPTO->SimpleRandom() . $CRYPTO->URandom() . $#IOReadFromClient ); 

	$IO->writeSocket( $HandyClientSocket, $ClientID . CRLF );
	$IO->writeSocket( $HandyClientSocket, CRLF );
	$IO->WriteFile( "$FILE/$ClientID", "$IOReadFromClient[5] $FileTypeHashRef->{1}" );	# merke die den suchbegriff für die HandyID $ClientID

	$LOGGING->LogToFileInit( $ReadFromClientRef );	
	$CLEANER->writeResultFile( "$IOReadFromClient[5] $FileTypeHashRef->{1}" );
	
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

	my $tmpSearch	= $IO->ReadFileIntoScalar( "$FILE/$QueryClientID" );
	my $SEARCH		= ${$tmpSearch};

	my $CurTime		= $TIME->MySQLDateTime();
	
	# printf "[Connect from %s] - Searving Request for ID '$QueryClientID' and Query: '$SEARCH' \n", $hostinfo->name;
	printf STDOUT "[Connect from %s at $CurTime ]  - Searving Request for Query: '$SEARCH' \n", $HandyClientSocket->sockhost;
	my $QueryNumber = $MUTELLA->getResultID( $MutellaSocket, $SEARCH );

	if ( $QueryNumber eq 'NORESULTS' ) {
		print "############# ResultQuery Mismatch - Trying to Send Result from Cache ############ ";
		
		my $SendString = $CACHE->readCache( 0, 9, $SEARCH, $FileTypeHashRef );

		if ( length($SendString) != 0 ) {
			print " Success\n";
			$IO->writeSocket( $HandyClientSocket, $SendString . CRLF );
			$LOGGING->LogToFileGetResults( $ReadFromClientRef );
			return 1;
		} else {
			print " Failure\n";
			$IO->writeSocket($HandyClientSocket, "FC 105 C" . CRLF); # FC 105 senden - query invalid
			return 0;
		}; # if ( length($SendString) != 0 ) {}

	   # unlink "$FILE/$QueryClientID";

	}; # if ( $QueryNumber eq 'NORESULTS' ) {}
	

	my $DownloadHashRef			= $PARSER->ResultCommandParser( $MutellaSocket, $QueryNumber, $FileTypeHashRef, $SEARCH );
	
	# wenn kein Ergebnis von Parser.pm zurückkommt, dann stelle die Anfrage nochmal
	if ( keys(%{$DownloadHashRef}) == 0 ) {
		select(undef, undef, undef, 0.05 );
		$DownloadHashRef			= $PARSER->ResultCommandParser( $MutellaSocket, $QueryNumber, $FileTypeHashRef );
	};
	
	my $SortedResultsArrayRef	= $SORTRANK->SortRank( $DownloadHashRef, $SEARCH , $FileTypeHashRef );
	my $NumberOfResults			= $#{$SortedResultsArrayRef};

	print "############# Number of Results: $NumberOfResults ############## \n";
	

	# wenn noch kein ergebnis für die suchanfrage vorliegt - schaue nach im Cache und liefere ein Cache Ergebnis
	if ( $NumberOfResults == 0 || $NumberOfResults == -1 ) {

		# gib aus, dass der handy client noch etwas warten soll
		$IO->writeSocket( $HandyClientSocket, "FC 808" . CRLF , 0.10 ); # FC 808 
		
	} else {
		
		my $RC = 0;
		my $SendString;

		foreach my $entry ( @{$SortedResultsArrayRef} ) {
			
			next if ( $RC > $NUMBEROFRESULTS );
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $entry );

			chop($SHA1) if ( length($SHA1) == 33 );	# fix für Sort::Array->Sort_Table();

			if ( $RANK != -3333 && $PEERHOST != -3333 && $SIZE != -3333 && $SHA1 != -3333 ){
							
				my $SizeKB = ( $SIZE / 1024 );
				my $SizeMB = ( $SizeKB / 1024 );
				
				$SizeKB = sprintf ("%.2f", $SizeKB);
				$SizeMB = sprintf ("%.2f", $SizeMB);

				print "RESULT: $RC\n";
				print "DEBUG: RANK: '$RANK' \n";
				print "DEBUG: SIZE: '$SIZE' Bytes und $SizeKB KB| $SizeMB MB \n";
				print "DEBUG: SHA1: '$SHA1' \n";
				print "DEBUG: HOST: '$PEERHOST' \n";
				print " ############ \n\n";

				# $SendString .= $RANK ."\r\n". $SIZE ."\r\n". $SHA1 ."\r\n". $PEERHOST ."\r\n";
				$SendString .= $RANK .CRLF. $SIZE .CRLF. $SHA1 .CRLF. $PEERHOST .CRLF;

				$RC++;

			}; # if ( $RANK != -1000 ...

		};	# foreach my $entry ( @{$SortedResultsArrayRef} ) {}

		$SendString .= CRLF;

		$IO->writeSocket( $HandyClientSocket, $SendString . CRLF );
		$MUTELLA->del( $MutellaSocket, $QueryNumber );
			
		$CACHE->writeCache( $SortedResultsArrayRef, $SEARCH, $FileTypeHashRef );
		$LOGGING->LogToFileGetResults( $ReadFromClientRef, $QueryClientID );	

		# unlink "$FILE/$QueryClientID";

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
	my $FileTypeHashRef		= shift;
			
	my @IOReadFromClient	= @{$ArrayRef};
	my $QueryClientID		= $IOReadFromClient[6];

	my $From				= $IOReadFromClient[7];
	my $To					= $IOReadFromClient[8];

	chomp($QueryClientID);

	my $tmpSearch	= $IO->ReadFileIntoScalar( "$FILE/$QueryClientID" );
	my $SEARCH		= ${$tmpSearch};

	printf "[Connect from %s - ID $QueryClientID ] - Sending Cache Result \n", $hostinfo->name;

	# benutze ResultCache.pm um eine ergebnis Range zu holen und an den client zu senden
	# later: lese privaten oder/und public cache
	# my $SendString = $CACHE->readCache( $From, $To, $QueryClientID, );
	my $SendString = $CACHE->readCache( $From, $To, $SEARCH, $FileTypeHashRef );

	# gib die ergebnisse aus
	$IO->writeSocket( $HandyClientSocket, $SendString . CRLF );
	
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
		
	$IO->writeSocket( $HandyClientSocket, "FC 105 A" . CRLF );
	close $HandyClientSocket;
	exit(0);
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
