#!/usr/bin/perl -I/server/phexproxy/PhexProxy

use lib "/server/phexproxy/PhexProxy";
use strict;
# use warnings;

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	26.1.2008
##### Function:		Hauptdatei für PhexProxy
##### Todo:			for statt foreach: ist schneller
##### Hint:			minimum StringLength of one Result is about 70 Chars long
########################################

# root: -20 <> 20 | normal: 0 <> 20
my $ServicePriority = "-1";				
system("renice $ServicePriority $$");

### TODO: Encoding unicode  / zeile 499

use Encode;
use Socket;
use DB_File;
use IO::Select;
use Fcntl ':flock';

use Digest::MD5 qw( md5_hex );
#use Digest::MD4 qw( md4_hex );
#use Digest::SHA1 qw( sha1_hex );

#use LWP::UserAgent;			# perl -MCPAN -e 'force install "LWP::UserAgent"'	
#use HTTP::Cookies;				# perl -MCPAN -e 'force install "HTTP::Cookies"'
#use HTTP::Request;				# perl -MCPAN -e 'force install "HTTP::Request"'
use LWP::Simple qw($ua get);	# perl -MCPAN -e 'force install "LWP::Simple"'


my @NeededModules	= ( "Encode","Socket","DB_File","IO::Select","Fcntl","LWP::Simple", "Digest::MD5" );
foreach my $module ( @NeededModules ) {
	
	if( !eval("require $module;") ){
		die "Critical Error: Module '$module' is not available on server! try: \"perl -MCPAN -e 'force install \"$module\"' \" !\n";
	};

}; # foreach my $module ( @NeededModules ) {



# use POSIX ":sys_wait_h";
# use POSIX qw(ceil);
#use Data::Dumper;
use PhexProxy::IO;
#use PhexProxy::SMS;
#use PhexProxy::ICQ;
use PhexProxy::Gzip;
use PhexProxy::Time;
use PhexProxy::Phex;
use PhexProxy::Daemon;
use PhexProxy::Logging;			# perl -MCPAN -e 'force install "Math::BigFloat"'
# use PhexProxy::CheckSum;
use PhexProxy::Messages;
use PhexProxy::FileTypes;
use PhexProxy::PhexSortRank;
use PhexProxy::CryptoLibrary;
use PhexProxy::LicenceManagement;


# definiere die paris host server hier, von denen wir die description ( für debug zwecke ) nehmen
my %ParisHostsDesc			= (
	"87.106.63.182"			=> "bitjoe.at [Quad Core 2.5Ghz]",				# bitjoe.at
	"81.169.141.129"		=> "phexproxy [celeron-2.4Ghz]",				# phexproxy celeron
	"81.169.137.179"		=> "Dual Core [ 2.5Ghz]",
	"85.214.77.110"			=> "alleonleinshops.com [celeron-2.4Ghz]",		# alleonleinshops.com
	"85.214.122.130"		=> "usenext mirror zoozle [Dual Core 2.3Ghz]",	# usenext mirror zoozle
	"77.247.178.21"			=> "8-Core-Xeon [3,4Ghz]",
	"77.247.178.20"			=> "Quad-Core AMD [2,4Ghz]",
	"81.169.137.179"		=> "AMD Dual Core",
	"85.214.90.176"			=> "Dual Core Opteron [2,4 GHz]",
	"127.0.0.1"				=> "Dual Core Opteron [2,4 GHz]",
);

# definiere die paris host server hier, die angefragt werden sollen
my %ParisHosts				= (
#	"81.169.137.179"		=> "3383-3384-3385-3386",					# bitjoepartner.com server - 81.169.137.179	
#	"77.247.178.21"			=> "3383-3384-3385-3386-3387-3388-3389",	# sql server - 77.247.178.21
#	"87.106.134.107"		=> "3383-3384-3385-3386",					# 1und1 phex server - 87.106.134.107
);

my $FastestDistributedServer = "127.0.0.1";	# Ergebnisse vom schnellsten Server sollen zuerst verarbeitet werden


my %PhexSearchConnections	= ();
my %CurrentSearchRequests	= ();
my %ParisSocketsHash		= ();
my %ParisResultCache		= ();
my %ConnectionsDB			= ();
my $CurrentSearchRequests;
my $ParisSocketsHash;
my $BalancingConfigHashRef  = {};
my $ConnectionsDB			= {};
my $ServerConfigHashRef		= {};
my $ParisResultCache;
my $ParisSocketsHashRef;
my $HandyClientHostname;
my $HandyClientSocket;
my $MaxSearchTime;
my $phexports;
my $port;
my $ServerListVersion;
my $ServerListSendString	= "";
my @ValidPhex				= (); # hierdrin werden die noch gültigen phexe vorgehalten, alle die noch suchanfragen frei haben
my @ParisHosts				= ();

my $DONE							= 0;
# my $port							= 23072;		# 8080 Port von Programm $0
my $MaxCacheValidTime				= 300;		# in sekunden
my $MaximumAllowedLoad				= 25;		# for development tests, sonst auf 10 stellen
my $NUMBEROFRESULTS					= 15;		# anzahl der ergebnisse,die dem client gesendet werden sollen, orginal: 15
my $SearchCountBeforeBusy			= 15;		# anzahl von aktuellen suchanfragen, bevor dem client mitgeteilt wird, das der service ausgelastet ist
my $MaxSearchStringLength			= 120;		# max suchstring länge
my $ParisHostCount					= keys( %ParisHosts );
my $SuchZeitHandyAnmeldung			= 21;		# wie lange soll bei einem handy anmeldung user gesucht werden lassen
my $PaymentHandleKeepAlive			= 3 * 60;	# PaymentHandleKeepAlive Minuten lang wird versucht das Timeout Handle aktiv zu halten
my $PaymentHandleKeepAliveTimeout	= 5;		# alle PaymentHandleKeepAliveTimeout sekunden wird das payment handle aktualisiert 

# my $MaxResultServeTimeout	= 7;			# wait max of time for results for while read ParisResult socket!
# my $MaxRetryOnFailedIORead	= 2;		# maximal sooft nochmal versuchen den Server neu anzufragen nach ergebnissen
# my $MaxRetryOnFailedIOSleep	= 1;		# zwischen den abholvorgaengen von einem server zufällig bis zu X sec schlafen
# my $DeleteEntriesAfterTry	= 2;			# lösche die Anfragen aus dem Phex nachdem DeleteEntriesAfterTry Versuch
# my $MaxNoResultTries		= 4;			# nach maximal 4 erfolglosen versuchen wird versucht einen eintrag aus dem Cache zu lesen

# Später - wenn pro Core $0 lauft:  
my $OverallLogFile			= "/server/logs/bjparisBackend_overall.log";
my $SearchLogFile			= "/server/logs/bjparisBackend_search.log";
my $TmpFilePath				= "/server/phexproxy/tmp";									mkdir $TmpFilePath;			# für temp sachen
my $FILE					= "/server/phexproxy/IDS";									mkdir $FILE;					# für cliend ids speichern
my $DBFlatFile				= "/server/phexproxy/tmp/DistributedConnections_$$.db";		unlink $DBFlatFile || system("/bin/rm -rf $DBFlatFile");							# connections db database
my $CurrentSearchesDatabase	= "/server/phexproxy/tmp/CurrentSearchesDatabase.db";		unlink $CurrentSearchesDatabase || system("/bin/rm -rf $CurrentSearchesDatabase");	# CurrentSearchesDatabase database 
my $PhexSearchConnectionsDB = "/server/phexproxy/tmp/PhexSearchConnectionsDB.db";		unlink $PhexSearchConnectionsDB || system("/bin/rm -rf $PhexSearchConnectionsDB");
my $ResultCacheFile			= "/server/phexproxy/cache/DistributedResultCache.db";		mkdir "/server/phexproxy/cache/";													# result cache database
my $ConnectionsDBFile		= "/server/phexproxy/tmp/ConnectionsDB.db";					unlink $ConnectionsDBFile || system("/bin/rm -rf $ConnectionsDBFile");	# $ConnectionsDBFile database 
my $BalancingConfigFile		= "balancing.cfg";	# hier steht die balancing config drinne
my $ServerlistConfigFile	= "serverlist.cfg";	# hier steht die serverlist config drinne
my $ServerStartupConfigFile	= "startup.cfg";	# hier stehen die ip und port werte drinne,die genommen werden sollen

my ($ServerIPAdress)		= `LANG=US_us ifconfig eth0`=~/inet addr:([\d.]+)/;
my $MaxRawDataToProcess		= sprintf("%.0f", 2000 * 1024);																			



# Lese hier die Server Startup Config ein
my $ServerConfigHashRef		= ReadBalancingConfig( $ServerStartupConfigFile );
# Verarbeite hier die Server Startup Config!
while ( my( $server,$data ) = each(%{$ServerConfigHashRef}))  {
	
	my ( $port_, $phexports_ ) = split(":", $data );
	chomp($server); chomp($port_); chomp($phexports_);
		
	if ( $server eq $ServerIPAdress ) {
		$port		= $port_;
		$phexports	= $phexports_;
		#print "'$server' und '$port' - '$phexports'\n";
	}; # if ( $server eq $ServerIPAdress ) {

}# while ( my( $server,$data ) = each(%{$ServerConfigHashRef}))  {


use constant VERSION		=> "'DistributedPhexProxy -v1.6.6- 08.09.2009 @ 13.50 Uhr'";
use constant PIDFILE		=> "/server/phexproxy/phexdistributedproxy-pid.txt"; unlink PIDFILE;
use constant BJPARISAPIAUTH	=> "35a75e3c5f958834650db467357f2633";			# perl API KEY
use constant COUPONAPIURI	=> "http://bitjoe.com/api/installvoucher.php";	#### http://bitjoe.com/api/installvoucher.php?vouchercode=38b055218b&accesscode=35a75e3c5f958834650db467357f2633&web_up_md5=1461a6d4b95fe2dd1a76375f79e4bdcf

use constant CRLF			=> "\r\n";
use constant SEPARATOR		=> "#";		# former '##'
use constant LINEEND		=> "\r";


my $IO						= PhexProxy::IO->new();
my $Socket					= PhexProxy::IO->CreateHandyDistributedSocket( $ServerIPAdress, $port );
#my $ICQ						= PhexProxy::ICQ->new();
#my $SMS						= PhexProxy::SMS->new();
my $GZIP					= PhexProxy::Gzip->new();
my $TIME					= PhexProxy::Time->new();
my $PHEX					= PhexProxy::Phex->new();
my $Token					= $PHEX->readToken();
my $IN						= IO::Select->new($Socket);
my $LOGGING					= PhexProxy::Logging->new();
my $MESSAGES				= PhexProxy::Messages->new();
my $FILETYPES				= PhexProxy::FileTypes->new();
my $SORTRANK				= PhexProxy::PhexSortRank->new();
my $CRYPTO					= PhexProxy::CryptoLibrary->new();
my $LICENCE					= PhexProxy::LicenceManagement->new();
$Socket->autoflush(0);

unlink PIDFILE;
### &init_server(PIDFILE);	# Server als Deamon starten


system("clear");
die "can't setup $0 socket\n" unless $Socket;
print "[Server $0 Version " . VERSION . " accepting clients on host $ServerIPAdress port $port with Service Priority '$ServicePriority']\n";


# signal handler installieren
### $SIG{'HUP'} = $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'ABRT'} = $SIG{'KILL'} = $SIG{'TERM'} = $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'HUP'} = sub { close($Socket); $ICQ->SendICQMessage("DistributedBitJoeParis has been stopped"); unlink $DBFlatFile || system("/bin/rm -rf $DBFlatFile"); die "Signal Handler: $0 has been killed \n";  };
$SIG{'HUP'} = $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'ABRT'} = $SIG{'KILL'} = $SIG{'TERM'} = $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'HUP'} = sub { close($Socket); unlink $DBFlatFile || system("/bin/rm -rf $DBFlatFile"); die "Signal Handler: $0 has been killed \n";  };


# befülle hier den phexcontainer, den brauchen wir um später eine instanz zu haben, die immer alle möglichen phex connections vorhaltne kann
my @ports = split("-", $phexports );
foreach my $portPP ( @ports ) {
	push(@ParisHosts ,"$ServerIPAdress:$portPP");
}; # foreach

my $ParisHostCount		= scalar(@ParisHosts);


########################
##### while accept loop
########################


while (!$DONE) {

	tie(%ParisSocketsHash, 'DB_File', $DBFlatFile, O_RDWR|O_CREAT ) || die "can't open $DBFlatFile: $!";

	next unless $IN->can_read;
	next unless $HandyClientSocket	= $Socket->accept();

	my $HandyClientHostname;

	eval { 
		# from Socket.pm;
		my $client_ip			= getpeername($HandyClientSocket);
		my ($port, $ipaddr)		= unpack_sockaddr_in($client_ip);
		$HandyClientHostname	= inet_ntoa($ipaddr);	# ist IP Adresse
	}; # eval { 
	

	if($@){

		# wird hoffentlich nie erreicht, denn sonst kann nicht bestimmt werden ,wie oft schon erfolglos gesucht wurde
		$HandyClientHostname = "127.0.0.1";
		print "Fehler $@ aufgetreten\n";

	}; # if($@){

	### print "Erstelle Verbindungs ID\n";
	my $MD5		= md5_hex($HandyClientHostname . time() . $CRYPTO->URandom(256) . $$ . rand(512) );	# MD5 Wert für gesicherte Zuordnung Verbindung<->$DBFlatFile Eintrag
	my $child	= launch_child();
	

	unless ($child) {

		close $Socket;

		# RequestCounterWrite( 1 );


		######
		###	hier verarbeiten wir die beiden config files
		######
		
		# lese hier die balancing configuration ein
		$BalancingConfigHashRef = ReadBalancingConfig( $BalancingConfigFile );
		$MaxSearchTime			= $BalancingConfigHashRef->{'maxsearchtime'};

		# lese hier die serverlist.cfg ein 
		$ServerConfigHashRef	= ReadBalancingConfig( $ServerlistConfigFile );
		$ServerListVersion		= $ServerConfigHashRef->{'version'};
		$ServerListSendString	.= "v=$ServerListVersion;";

		while( my ($desc,$value) = each(%{$ServerConfigHashRef})){
			if ( $desc =~ /server/ig) {
				$ServerListSendString .= $value;
			};
		}; # while( my ($host,$ports) = each(%ParisHosts)){
		


		# Automatischer Load Check: Start
		my $LoadScalarRef					= $IO->ReadFileIntoScalar("/proc/loadavg");
		my ($CurrentLoad,undef,undef,undef) = split(" ", ${$LoadScalarRef});
		if ( $CurrentLoad >= $MaximumAllowedLoad ) {
			
			print "Current Load is '$CurrentLoad' and higher than allowed\n";
			#$IO->writeSocket( $HandyClientSocket, $GZIP->gzip_compress_string("-1##FC MSG=$LoadErrorMessage") . CRLF ); # FC 909: load auf dem server zu hoch 
			$IO->writeSocket( $HandyClientSocket, $GZIP->gzip_compress_string("-1##FC MSG=FC 909") . CRLF );
			close $HandyClientSocket;
			exit(0);

		}; # if ( $CurrentLoad > $MaximumAllowedLoadForPhex ) {
		# Automatischer Load Check: End
	


		# Nehme den Content vom Handy an
		my $ReadFromClient		= $IO->readSocket( $HandyClientSocket );
		my $ReadFromClientOrg	= $ReadFromClient;
		my @ReadFromClient		= split('##', $ReadFromClient );
	


		# Abschnitt Entschlüsselung Handynachricht
		####################### crypto api implementatione #####################
		#	$IOReadFromClient[0] = MD5 Wert der Verschlüsselten Nachricht
		#	$IOReadFromClient[1] = der public schlüssel 
		#	$IOReadFromClient[2] = die verschlüsselte nachricht
			
		my $PrivateCryptoKey = $CRYPTO->GetPrivateCryptoKeyFromDatabase( $ReadFromClient[1] );
		if ( $PrivateCryptoKey == -1 || length($PrivateCryptoKey) != 32 ) {
		
			my $CryptoErrorMessage	= $MESSAGES->{'MessageHandlerEN'}{'4'};
			print STDERR "Error: Crypto false publickey - got: '$ReadFromClient[1]'\n";
			$IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string("-1##FC MSG=$CryptoErrorMessage") . CRLF);	# Crypto false privatekey
			close $HandyClientSocket;

			exit(0);

		}; # if ( $PrivateKey == -1 ) {}

		
		##	# @IOReadFromClient 	= split("##", $stuff ); 
		##	# result:              result##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
		##	# find:                find##SEARCH##b001000100##UP_MD5##SEC_MD5##VERSION##SERVERLISTVERSION
		##	# coupon:              coupon##COUPONCODE##FIRSTINSTALL##UP_MD5##SEC_MD5##VERSION
		##	# payment:			   payment##Tarif##leer##UP_MD5##SEC_MD5##VERSION
		##	# paymentenhanced:	   paymentenhanced##Tarif##leer##UP_MD5##SEC_MD5##VERSION
		##	# paymentdetails:	   paymentdetails##leer##leer##UP_MD5##SEC_MD5##VERSION
		##  # agb				   agb##email##leer##UP_MD5##SEC_MD5##VERSION
		##	# createaccount:       createaccount##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
		##	# my ( $service, $search, $ClientID, $UP_MD5, $SEC_MD5 )	= split("##", $stuff );  
		##	# my ( $service, $search, $FileStats, $UP_MD5, $SEC_MD5 )	= split("##", $stuff );  

				
		# Eigentliche Entschlüsselung mittels Java AES
		my $PlainText			= $CRYPTO->Decrypt( $PrivateCryptoKey, $ReadFromClient[2] );
		my @IOReadFromClient	= ();	# resette das wichtige Array
	
		my ( $stuff	)			= split("\r\n", $PlainText ); 
		my ( $service, $search, $FileStats, $UP_MD5, $SEC_MD5, $version, $srvlstversion, $language ) = split("##", $stuff );  # find=$FileStats | result=$ClientID
		$version =~ s/^\s+//; $version =~ s/^\s+//; chomp($version);
		$language =~ s/^\s+//; chomp($language);
		$srvlstversion =~ s/^\s+//; $srvlstversion =~ s/^\s+//; chomp($srvlstversion);
		$SEC_MD5 =~ s/^\s+//; $UP_MD5 =~ s/^\s+//; # leerzeichen entfernen
		$SEC_MD5 =~ s/\s+$//; $UP_MD5 =~ s/\s+$//;
		my $CurTime				= $TIME->MySQLDateTime();


		# Busy message schicken
		my $CurrentRunning = RequestCounterRead();
		if ( ($CurrentRunning >= $SearchCountBeforeBusy) && ($service eq 'find') ) {
			
			$IO->writeSocket( $HandyClientSocket, $GZIP->gzip_compress_string("-1##FC MSG=FC 909") . CRLF ); # FC 909: load auf dem server zu hoch 
			close $HandyClientSocket;
			exit(0);

		}; # if ( $CurrentRunning >= $SearchCountBeforeBusy ) {


	

		# Abschnitt Licence Check: start
		my ( $Status, $ResultHashRef ) = $LICENCE->CheckLicence( $UP_MD5, $SEC_MD5, $HandyClientHostname );
		
		if ( $Status != 1 ) {	
			
			my $LicenceErrorMessage;

			if ( $Status == 0 ) {
				
				if ( $service eq 'find' || $service eq 'result' ) {	

					# coupon request dürfen bei positivem Status Flag gleich 0 durchgeführt werden
					# diese if anweisung sorgt dafür das find und result request geblockt werden bei Status flag gleich 0
					
					$LicenceErrorMessage = $MESSAGES->WelcomeMessageHandler( $ResultHashRef, $language ); #$MESSAGES->{'MessageHandler'}{'31'};	
					
					#$IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string("$Status##FC MSG=$LicenceErrorMessage") . CRLF);
					$IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string("-1##FC MSG=$LicenceErrorMessage") . CRLF);
					close $HandyClientSocket;
					exit(0);

				}; # if ( $service ne 'coupon') {

			} elsif ( $Status == -1 ){

					$LicenceErrorMessage = $MESSAGES->{'MessageHandlerEN'}{'3'};
					
					#$IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string("$Status##FC MSG=$LicenceErrorMessage") . CRLF);
					$IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string("-1##FC MSG=$LicenceErrorMessage") . CRLF);
					close $HandyClientSocket;
					exit(0);

			}; # if ( $Status == 0 ) {
				
		}; # if ( $Status != 1 ) {}

		# Abschnitt Licence Check: Ende

		# Abschnitt Verbindungsaufbau
		# erstelle den socket zum paris programm 
		
			
		my $COUNT			= 0;

		# Setzte hier eine Datei exclusive Sperrung des DB Flat Files hinter %ParisSocketsHash durch
		open(FLOCK,"<$DBFlatFile");
		flock(FLOCK,LOCK_EX);
	
		my $searchcontainer		= 'suche'.RequestCounterRead();
		my $PhexInstancesToUse	= $BalancingConfigHashRef->{$searchcontainer};

		if ( length($PhexInstancesToUse) == 0 ) {
			$PhexInstancesToUse = $BalancingConfigHashRef->{'suche1'};
		}
				
	#	print "RequestCounterRead(): " . RequestCounterRead() . " \n";
	#	print "PhexInstancesToUse=$PhexInstancesToUse\n";
	#	print "searchcontainer=$searchcontainer\n";
	
		for ( my $i = 0; $i <= $PhexInstancesToUse - 1; $i++ ) {
		
			my $ReadConString = ConnectionReadPhexCount("PhexWriteConnection");
			
			if ( $ReadConString == $ParisHostCount - 1 ) {
				$ReadConString = -1;
			}

			$ReadConString++;
			
	#		print "[$ReadConString/$PhexInstancesToUse] $ParisHosts[$ReadConString] \n";
			my ( $host,$port )	= split(":", $ParisHosts[$ReadConString]);
			
			$ParisSocketsHashRef->{$COUNT}->{'HOST'}		= $host;			# diese werte werden im verlauf genutzt
			$ParisSocketsHashRef->{$COUNT}->{'PORT'}		= $port;
			$ParisSocketsHashRef->{$COUNT}->{'HOSTNAME'}	= $ParisHostsDesc{$host};

			ConnectionWritePhexCount("PhexWriteConnection",$ReadConString);

			$COUNT++;

		}; # for (my $i = 0; $i <= $PhexInstancesToUse-1; $i++ ) {

		# hebe hier eine Datei exclusive Sperrung des DB Fkat Files hinter %ParisSocketsHash wieder auf
		flock(FLOCK, LOCK_UN);
		close(FLOCK);

		# dont modify this value!
		# my $COUNT_READ_ONLY = scalar( @ParisHosts ) - 1;
		my $COUNT_READ_ONLY = $COUNT;

		##########
		#### BitJoe Protokoll Request Verarbeitung
 		##########


		if ( $service eq 'find' ) {	# Abschnitt Suchanfrage stellen
			
			RequestCounterWrite( 1 );

			my $RunningSearches	= RequestCounterRead();	# eine suchanfrage auf den counter raufsetzen
			# print "FIND Running Searches: $RunningSearches \n"; 

			##	# result:              result##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
			##	# find:                find##SEARCH##b001000100##UP_MD5##SEC_MD5##VERSION
			##	# coupon:              coupon##COUPONCODE##FIRSTINSTALL##UP_MD5##SEC_MD5##VERSION
			##	# payment:			   payment##Tarif##leer##UP_MD5##SEC_MD5##VERSION
			##	# paymentenhanced:	   paymentenhanced##Tarif##leer##UP_MD5##SEC_MD5##VERSION
			##	# paymentdetails:	   paymentdetails##leer##leer##UP_MD5##SEC_MD5##VERSION
			##  # agb				   agb##email##leer##UP_MD5##SEC_MD5##VERSION
			##	# createaccount:       createaccount##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
			##	# my ( $service, $search, $ClientID, $UP_MD5, $SEC_MD5 )	= split("##", $stuff );  
			##	# my ( $service, $search, $FileStats, $UP_MD5, $SEC_MD5 )	= split("##", $stuff ); 

			my $SearchString					= $search;
			$SearchString						= deleteSpecialChars($SearchString);	# searchstring wird hier abgeschnitten und sonderzeichen und sql commandos entfernt
			my ( $SearchFileString, $Filetyp )	= $FILETYPES->getSearchFiles( $FileStats );	
		
			my $hc_userType						= $ResultHashRef->{'hc_userType'};
			my $hc_contingent_volume_success	= $ResultHashRef->{'hc_contingent_volume_success'};
			my $HelloMessage					= "";
			my $ClientID						= "";
			my $ConnectionString				= "";

			printf STDOUT "[ Connect from $HandyClientHostname at $CurTime ] - Submitting Search [$RunningSearches] '$SearchString $SearchFileString' for [V $version] to Phex on " . join(", ", keys(%ParisHosts)) . " \n";
			

			# wenn schon mehr als 15 suchanfragen im phex sind, bekommt der client eine fehlermeldung
			if ( $RunningSearches <= $SearchCountBeforeBusy ) {

				# Es sind weniger als $SearchCountBeforeBusy (=15) Suchanfragen aktuell im Phex 
				# und darum stoßen wir hiermit eine neue suchanfrage an

				# normale message vorbereiten
				$HelloMessage	= $MESSAGES->WelcomeMessageHandler( $ResultHashRef, $language );
				
				# Erstelle die CheckSumme für einen eingehenden Request - zusammengesetzt aus entsprechenden Werten
				$ClientID		= md5_hex( $HandyClientHostname . time() . $CRYPTO->URandom(512) . $#IOReadFromClient . $$ . rand(8096) ); 
			
				#### Verteile die Anfragen an alle Phex Proxys
				for ( my $COUNT=0; $COUNT<=$COUNT_READ_ONLY; $COUNT++ ){	

					my $ParisHost	= $ParisSocketsHashRef->{$COUNT}->{'HOST'};	# ACCESS A HASHREF	
					my $ParisPort	= $ParisSocketsHashRef->{$COUNT}->{'PORT'};
				
					# überspringe invalide einträge
					next if ( length($ParisHost) <= 0 );
					next if ( length($ParisPort) <= 0 );

					###	print "Find Connection to $ParisHost | $ParisPort \n ";
					$PHEX->find( $ParisHost, $ParisPort, "$SearchString $SearchFileString", $Filetyp, $ClientID, $Token );

				}; # for ( my $COUNT=0; $COUNT<=$COUNT_READ_ONLY; $COUNT++ ){	

			} elsif ( $RunningSearches > $SearchCountBeforeBusy ) {
				
				# Es mehr als $SearchCountBeforeBusy (=15) Suchanfragen aktuell im Phex 
				# und darum stoßen wir auch keine neue suchanfrage an!

				# service busy meldung vorbereiten
				$HelloMessage	= $MESSAGES->{'MessageHandlerEN'}{'5'};
				$ClientID		= 0;	# client id resetten


			}; # if ( $RunningSearches <= $SearchCountBeforeBusy ) {



			
			if ( $version eq "1.0.0.proxy" ) {
				
				$IO->writeSocket( $HandyClientSocket , "$ClientID##FC MSG=$HelloMessage##" . CRLF );	# immer Gültig, da MD5ToHEX immer 32 Zeichen zurückliefert

			# $ServerListVersion server list version aus der server config # $srvlstversion server list version vom handy 
			} elsif ( $ServerListVersion > $srvlstversion ) { 	# handyversion ist älter als serverlist.cfg
				
				my $GzipString = $GZIP->gzip_compress_string( "$ClientID##FC MSG=$HelloMessage##$ServerListSendString" );
				$IO->writeSocket( $HandyClientSocket , $GzipString . CRLF );
				
			} else {

				# bestehender user mit der normalen bitjoe version 
				my $GzipString = $GZIP->gzip_compress_string( "$ClientID##FC MSG=$HelloMessage##" );
				$IO->writeSocket( $HandyClientSocket , $GzipString . CRLF );	# immer Gültig, da MD5ToHEX immer 32 Zeichen zurückliefert
			
			}; # if ( $srvlstversion	< $ServerListVersion ) { 

			# schließe handysocket verbindung
			close $HandyClientSocket;

			unlink "$FILE/$ClientID";
			$IO->WriteFile( "$FILE/$ClientID", "$SearchString $SearchFileString" );	# merke die den suchbegriff für die HandyID $ClientID

			# Logge die Suchanfragen mit
			open(SEARCH,"+>>$SearchLogFile");
				binmode(SEARCH);
				print SEARCH "[$CurTime] [V $version] '$SearchString' $SearchFileString\n";
			close SEARCH;

		} elsif ( $service eq 'result' ){	# Abschnitt Ergebiss abholen
			
			my $RunningSearches	= RequestCounterRead();	# eine suchanfrage auf den counter raufsetzen
			### print "RESULT Running Searches: $RunningSearches \n"; 


			##	# result:              result##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
			##	# find:                find##SEARCH##b001000100##UP_MD5##SEC_MD5##VERSION
			##	# coupon:              coupon##COUPONCODE##FIRSTINSTALL##UP_MD5##SEC_MD5##VERSION
			##	# payment:			   payment##Tarif##leer##UP_MD5##SEC_MD5##VERSION
			##	# paymentenhanced:	   paymentenhanced##Tarif##leer##UP_MD5##SEC_MD5##VERSION
			##	# paymentdetails:	   paymentdetails##leer##leer##UP_MD5##SEC_MD5##VERSION
			##  # agb				   agb##email##leer##UP_MD5##SEC_MD5##VERSION
			##	# createaccount:       createaccount##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
			##	# my ( $service, $search, $ClientID, $UP_MD5, $SEC_MD5 )	= split("##", $stuff );  
			##	# my ( $service, $search, $FileStats, $UP_MD5, $SEC_MD5 )	= split("##", $stuff ); 

			# todo: wenn ein host schon ergebnisse geliefert hat, der andere noch nicht, dann nochmal so lange ca 4 mal den anderen zum abholen bewegen!!!
			my $StartExecutionTime		= $CurTime;

			my $ClientID				= $FileStats; chomp($ClientID);
			my $tmpSearch				= $IO->ReadFileIntoScalar( "$FILE/$ClientID" );
			my $SEARCH					= ${$tmpSearch};
			my $CurTime					= $TIME->MySQLDateTime();
		
			my $UnparsedResultsFromAllServer	= "";
			my $UnparsedResultsFromFastestServ	= "";

			printf STDOUT "[ Connect from $HandyClientHostname at $CurTime ] - Serving Request [$RunningSearches] for Query: '$SEARCH' for [V $version] from all Servers " . join(", ", keys(%ParisHosts)) . " \n";
			my $PhexInstancesToUse	= $BalancingConfigHashRef->{"suche1"};

			foreach my $entry (@ParisHosts) {
			
				my ( $ParisHost,$ParisPort )	= split(":", $entry );
				my $ParisHostName				= $ParisHostsDesc{$ParisHost};
			
				# überspringe invalide einträge
				next if ( length($ParisHost) <= 0 );
				next if ( length($ParisPort) <= 0 );
			
				my $DownloadResults		= $PHEX->result( $ParisHost, $ParisPort, $ClientID, $Token);	
				my $TempStringLength	= length($DownloadResults);
								
				###	$SMS->SendCustomSMS("Phex on $ParisHostName $ParisHost|$ParisPort down") if ( $TempStringLength <= 0 );
				### print "Result Connection to $ParisHost | $ParisPort failed \n " if ( $TempStringLength <= 0 );
				### print "Result Connection to $ParisHost | $ParisPort \n ";

				if ( $TempStringLength >= 71 ) {	# Hier wurde erfolgreich die result() Funktion aufgerufen und sie hat gültigen Content zurückgeliefert 
					
					# Vorbereitung - Ergebnisse vom schnellsten Host sollen zuerst bearbeitet werden 
					if ( $ParisHost ne $FastestDistributedServer ){
						$UnparsedResultsFromAllServer .= $DownloadResults;

					} elsif ( $ParisHost eq $FastestDistributedServer ){
						$UnparsedResultsFromFastestServ .= $DownloadResults;
					
					}; # if ( $ParisHost ne $FastestDistributedServer ){

					my $TempResultKbytes	= sprintf("%.2f", ( $TempStringLength / 1024 ));
				###	printf STDOUT "[ Connect from $HandyClientHostname at $CurTime ] - Successfully Served '$TempResultKbytes' Kbytes from $ParisHost [$ParisPort] | $ParisHostName \n";
																
				}; # if ( length($TempString) >= 10) {
					
				$TempStringLength = 0;	# resette String Länge
			
			}; # for ( my $COUNT=0; $COUNT<=$COUNT_READ_ONLY; $COUNT++ ){	
			# Stelle die Result-Anfrage an jeden Paris Server: Ende


			RequestCounterWrite( -1 );	# eine suchanfrage aus dem counter löschen


			# Ergebnisse vom Schnellsten Server sollen zuerst ausgewertet werden
			if ( length($UnparsedResultsFromFastestServ) >= 71 ) {
				
				my $TmpResultString				= $UnparsedResultsFromAllServer;
				$UnparsedResultsFromAllServer	= "";
				$UnparsedResultsFromAllServer	.= $UnparsedResultsFromFastestServ . $TmpResultString;
			
			}; # if ( length($UnparsedResultsFromFastestServ) >= 71 ) {

			


			#####
			### result cutter: intelligent cut of results to $MaxRawDataToProcess Kbytes
				my $UnparsedResultsFromAllServer	= IntelligentRawDataCut( \$UnparsedResultsFromAllServer, $MaxRawDataToProcess);
				my $SortedResultsArrayRef			= $SORTRANK->PhexSortRank( $UnparsedResultsFromAllServer, $search );	# unparsed content - suchbegriff - filetyp
			#####

			# die anweisung nur ausführen, wenn intelligent data cut NICHT verwendet wird
			# my $SortedResultsArrayRef	= $SORTRANK->PhexSortRank( \$UnparsedResultsFromAllServer, $IOReadFromClient[5], $FileTypeHashRef );	# unparsed content - suchbegriff - filetyp
		

			my $Quellen							= "";
			my $SendString						= "";							# Dies ist der String mit den finalen Ergebnissen für das Handy	
			my $RC								= 1;							# Anzahl der ausgelieferten Ergebnisse
			my $FinalResultCount				= @{$SortedResultsArrayRef};	# Anzahl aller Ergebnisse
		
			# folgende foreach schleife setzt die ergebnisse für das handy zusammen
			foreach my $entry ( @{$SortedResultsArrayRef} ) {
				
				last if ( $SortedResultsArrayRef->[0] eq "-3333###-3333###-3333###-3333\n" );	# dieser String bedeutet keine Ergebnisse
				my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $entry );
				
				chop($SHA1) if ( length($SHA1) == 33 );	# fix für PhexProxy::SortArray->Sort_Table();
				next if ( length($RANK) <= 0 || length($SIZE) <= 0 || length($SHA1) != 32 || length($PEERHOST) <= 0); 
				next if ( $PEERHOST =~ /#/g || $RANK =~ /#/g || $SIZE =~ /#/g || $SHA1 =~ /#/g );
				last if ( $RC > $NUMBEROFRESULTS );
	
				my $SizeKB		= ( $SIZE / 1024 );
				my $SizeMB		= ( $SizeKB / 1024 );
				$SizeKB			= sprintf("%.2f", $SizeKB);
				$SizeMB			= sprintf("%.2f", $SizeMB);
				my (@SOURCES)	= split("\r\n", $PEERHOST );
				$Quellen		= @SOURCES;
				my $RANK		= sprintf("%.0f", $RANK );	# bei Ergebnissauslieferung --> truncated Points to int # $RANK = ceil($RANK);
					
				# Normale Results
				$SendString .= $RANK .SEPARATOR. $SIZE .SEPARATOR. $SHA1 .SEPARATOR. $PEERHOST .SEPARATOR. "\r";
						
				# Ergebniszähler eins hochsetzen
				$RC++;	
	
			};	# foreach my $entry ( @{$SortedResultsArrayRef} ) {}
	
	
			open(W,">out.txt");
			print W "$SendString\n";
			close W;


			# Öffne die ResultCache DB
			tie(%ParisResultCache, 'DB_File', $ResultCacheFile, O_RDWR|O_CREAT ) || warn "can't open $ResultCacheFile: $!";
		
			my $SendStringLength							= length($SendString); 
			my $CacheEntry									= lc($SEARCH);					# dies ist unser cache hash key, zb. "paris .b0"
			my $CacheEntryCreateTime						= $CacheEntry . "-created";		# dies ist unser cache timestamp hash key

			# wenn der inhalt von sendstring größer ist als die länge des cache eintrages oder sendsting größer als 300 zeichen ist			
			# if ( $SendStringLength >= length($ParisResultCache{$CacheEntry}) && exists($ParisResultCache{$CacheEntry}) || $SendStringLength >= 70 ) {	
			
			### print "Cache existiert" if (exists($ParisResultCache{$CacheEntry}));
			
			if ( $SendStringLength >= 1024 ) {	
				
				open(FLOCKCACHE,"<$ResultCacheFile");
				flock(FLOCKCACHE,LOCK_EX);

				$ParisResultCache{$CacheEntry}				= $SendString;
				$ParisResultCache{$CacheEntryCreateTime}	= time();
				
				flock(FLOCKCACHE, LOCK_UN);
				close(FLOCKCACHE);

				my $SendStringLengthKbytes					= sprintf("%.2f", ( $SendStringLength / 1024 ) );
			#	print "Successfully wrote '$SendStringLength' Bytes || '$SendStringLengthKbytes' Kbytes of Cache Data for Entry \n";		#'$CacheEntry' \n";

			} else {	# speichere, wie oft schon erfolglos ergebnisse ausgeliefert wurden
				
			#	print "Failed writing '$SendStringLength' Bytes of NON Cache Data for Entry '$CacheEntry' \n";
		
			}; # if ( length($SendString) >= length($ParisResultCache{$CacheEntry}) || length($SendString) >= 300 ) {	

			#### END: Setze die Ergebnisse zusammen, nimm dazu von jedem Paris Ergebnishost die Liste 


			############################################
			### Caching Related Debug Messages: Start

		#	my $NoResultCounter			= NoResultDatabaseManager( "r", $SEARCH );
			my $CacheCreateTime			= $ParisResultCache{$CacheEntryCreateTime} || 0;	# wann wurde cache erstellt oder 0 setzen - dh cache existiert nicht
			my $CacheDifferTime			= time() - $CacheCreateTime;						# differenz zwischen aktuellem zeitpunkt und dem punkt der erstellung des caches

			my $UnparsedContentLength	= length($UnparsedResultsFromAllServer);
			my $UnparsedContentKbytes	= sprintf("%.2f", ( $UnparsedContentLength / 1024 ) );
						
		#	print "############### DEBUG CACHING START: ########### \n";
		#	print "CacheCreateTime	 : $CacheCreateTime \n";
		#	print "CacheDifferTime	 : $CacheDifferTime\n";
		#	print "HandyResultStr   : $SendStringLength Bytes\n";
		#	print "UnparsedContLeng : $UnparsedContentLength Bytes | $UnparsedContentKbytes Kbytes\n";
		#	print "Start Exec Time  : $StartExecutionTime\n";
		#	print "End Exec Time    : $CurTime\n";
		#	print "############### DEBUG CACHING END ########### \n";
		
			# wenn mehr als $MaxNoResultTries erfolglos versucht wurde ein ergebniss auszuliefern und der Cacheeintrag $ParisResultCache{$CacheEntry} existiert 
			# der cache zeittechnisch noch gültig ist, dh unter $MaxCacheValidTime sek liegt und die länge des Cache Eintrages $ParisResultCache{$CacheEntry} ok ist dann versuche einen cache hit
		
			if ( $CacheDifferTime <= $MaxCacheValidTime && $SendStringLength < 70 ) {	
				
				$SendString			= $ParisResultCache{$CacheEntry};
				$SendStringLength	= length($SendString);
			###	print "[ Connect from $HandyClientHostname at $CurTime ] - End Of Transmission: Successful Serve Cache hit for Query: '$CacheEntry' \n\n";

			} else {
				
				my $CurTime	= $TIME->MySQLDateTime();
			###	print "[ Connect from $HandyClientHostname at $CurTime ] - End Of Transmission: Served Normal Phex Result for Query: '$CacheEntry' \n\n";

			}; # if ( $NoResultCounter >= MaxNoResultTries && $CacheDifferTime <= $MaxCacheValidTime && length($SendString) <= 50 ) {

			### Caching Related Debug Messages: End
			############################################


			# schreibe dem handyclient den gezippten Ergebnis string!!!!
			if ( $SendStringLength >= 70 ) {
				
				if ( $version eq "1.0.0.proxy" ) {
					$IO->writeSocket( $HandyClientSocket , $SendString . CRLF );	# immer Gültig, da MD5ToHEX immer 32 Zeichen zurückliefert
				} else {
					# Sende dem Handy den gezippten Result String
					$IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string($SendString) . CRLF );
				};

				$ResultHashRef->{'SendStringLength'} = $SendStringLength;
				
			} else {	# keine Treffer

				# Sende dem Handy, dass noch keine Ergebnisse vorhanden sind
				# $IO->writeSocket($HandyClientSocket, $GZIP->gzip_compress_string("FC 808") . CRLF );
				
				my $NoResultMessage = $MESSAGES->{'MessageHandlerEN'}{'7'};
				
				if ( $version eq "1.0.0.proxy" ) {
					$IO->writeSocket( $HandyClientSocket , "0##FC MSG=$NoResultMessage" . CRLF );
				} else {
					# Sende dem Handy den gezippten Result String
					$IO->writeSocket( $HandyClientSocket , $GZIP->gzip_compress_string( "0##FC MSG=$NoResultMessage" ) . CRLF );
				};

				$ResultHashRef->{'SendStringLength'} = 0;
				
			}; # if ( length($SendString) >= 30 ) {

			# lösche die cliendID
			unlink "$FILE/$ClientID";

			# schließe handysocket verbindung
			close $HandyClientSocket;

			# Hier werden dann die BJParis Tabellen angepasst und die Volumeneinträge der Searches verringert
			$LICENCE->UpdateSearchContingent( $ResultHashRef );
			
			# Logge die Suchanfragen mit
			my $tmpcount	= $FinalResultCount;
			$tmpcount		-=1;

		#	open(SEARCH,"+>>$SearchLogFile");
		#		binmode(SEARCH);
		#		print SEARCH "[$CurTime] [V $version] '$SEARCH' [$tmpcount Results] [$SendStringLength Bytes] \n";
		#	close SEARCH;



		} elsif ( $service eq 'coupon' ){	# Abschnitt Coupon einlösen

			##	# result:              result##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
			##	# find:                find##SEARCH##b001000100##UP_MD5##SEC_MD5##VERSION
			##	# coupon:              coupon##COUPONCODE##FIRSTINSTALL##UP_MD5##SEC_MD5##VERSION
			##	# payment:			   payment##Tarif##leer##UP_MD5##SEC_MD5##VERSION
			##	# paymentenhanced:	   paymentenhanced##Tarif##leer##UP_MD5##SEC_MD5##VERSION
			##	# paymentdetails:	   paymentdetails##leer##leer##UP_MD5##SEC_MD5##VERSION
			##  # agb				   agb##email##leer##UP_MD5##SEC_MD5##VERSION
			##	# createaccount:       createaccount##SEARCH##ID##UP_MD5##SEC_MD5##VERSION
			##	# my ( $service, $search, $ClientID, $UP_MD5, $SEC_MD5 )	= split("##", $stuff );  
			##	# my ( $service, $search, $FileStats, $UP_MD5, $SEC_MD5 )	= split("##", $stuff ); 

			printf STDOUT "[ Connect from $HandyClientHostname at $CurTime ] - Serving Coupon Request for [V $version] for Code: '$search' \n";

			# #### http://bitjoe.com/api/installvoucher.php?vouchercode=d4ee9e6a28&accesscode=35a75e3c5f958834650db467357f2633&web_up_md5=1461a6d4b95fe2dd1a76375f79e4bdcf
			my $couponcode		= $search;
			my $BJCOUPONAPIURI	= COUPONAPIURI . "?vouchercode=$couponcode&web_up_md5=$UP_MD5&accesscode=" . BJPARISAPIAUTH;
			
			$ua->timeout(15); 
			$ua->agent( VERSION ); 
	
			my $html = get($BJCOUPONAPIURI);

			if ( $html && length($html) >= 10 ) {
				my $StatusMessage	= $html;
				print "SUCCESS: '$StatusMessage' \n";
				$IO->writeSocket( $HandyClientSocket , $GZIP->gzip_compress_string( "0##FC MSG=$StatusMessage" ) . CRLF );
			} else {
				my $ErrorMessage	= $MESSAGES->{'MessageHandlerEN'}{'6'};
				print "ERROR: $ErrorMessage\n";
				$IO->writeSocket( $HandyClientSocket , $GZIP->gzip_compress_string( "0##FC MSG=$ErrorMessage" ) . CRLF );
			}; # if ( $res->is_success ) {
	
			# schließe handysocket verbindung
			close $HandyClientSocket;
			
			
		}; # if ( $ReadFromClient[0] eq 'find' ) { # } elsif ( $IOReadFromClient[0] eq 'result' ){

	
		###### Lösche bestehenden Einträge
		for ( my $COUNT=0; $COUNT<=$COUNT_READ_ONLY; $COUNT++ ){	
			delete $ParisSocketsHashRef->{$COUNT.$MD5};		# hashref eintrag löschen
		}; # for ( my $COUNT=0; $COUNT<=$COUNT_READ_ONLY; $COUNT++ ){	

		
		# schließe die ResultCache DB, lösche NoResultFile und beended das Programm
		untie(%ParisResultCache);
		exit(0);



	}; #  unless ($child) {}


	# schließe HandySocket und die Connections Datenbank
	close $HandyClientSocket;
	untie(%ParisSocketsHash);
	#exit(0);



}; # while (!$DONE) {}

########################
##### while accept loop
########################


die "$0 - Normal termination\n";
exit(0);


### my $ParisSocket = $ParisSocketsHashRef->{$COUNT}->{'SOCKET'};			# ACCESS A HASHREF
### DOESNT WORK! my $ParisSocket = $ParisSocketsHash{'SOCKET'.$COUNT};		# Access a HASH


####################
#################### DistributedParis Funktionen
####################



sub RequestCounterWrite(){

#	first: $r = readentrys()
#	write 1;
#	$r2 = readentrys()
#
#	if $r == $r2
#		-> manuel write: $r+$value;

	# Schreibe/ Lösche Einträge für Anzeige wieviele aktuelle Suchrequests schon vorhanden sind
	my $ValuetoAdd		= shift;							# postive werte zum addieren | negative werte zum subtrahiern
	my $HashName		= "BJPARISCURRENTSEARCHREQUESTS";
	my $CurrentSearches	= RequestCounterRead();
	my $WriteValue		= $CurrentSearches + $ValuetoAdd;	# zu schreibende daten
	
	if ( $WriteValue < 0 ) {
		$WriteValue =~ s/-//ig;
	};

	tie(%CurrentSearchRequests, 'DB_File', $CurrentSearchesDatabase, O_RDWR|O_CREAT ) || warn "can't open $CurrentSearchesDatabase: $!";
	flock(%CurrentSearchRequests,LOCK_EX);

		if ( !defined($CurrentSearchRequests{'LASTACCESS'}) || length($CurrentSearchRequests{'LASTACCESS'}) <= 0 ) {
			$CurrentSearchRequests{'LASTACCESS'} = time();
		}

		my $zeit		= time();
		my $lastaccess	= $CurrentSearchRequests{'LASTACCESS'};
		my $zeitminus	= $zeit - $lastaccess;

		if ( $zeit > ($lastaccess + $MaxSearchTime) ) {	# wenn $MaxSearchTime sec kein zugriff
			$WriteValue	= 0;
		};
		
	#	my $read = RequestCounterRead();
	#	print "[$read] vor schreibzugriff - write:'$WriteValue'='$CurrentSearches + $ValuetoAdd' \n";

		$CurrentSearchRequests{$HashName}		= $WriteValue;
		$CurrentSearchRequests{'LASTACCESS'}	= time();
	
	#	my $read = RequestCounterRead();
	#	print "[$read] nach schreibzugriff - write:'$WriteValue'='$CurrentSearches + $ValuetoAdd' \n";


	flock(%CurrentSearchRequests, LOCK_UN);
	untie(%CurrentSearchRequests);

	return $WriteValue;
	
};	# sub NoResultDatabaseManager(){



sub RequestCounterRead(){

	# Lese Einträge für Anzeige wieviele aktuelle Suchrequests schon vorhanden sind
	my $HashName	= "BJPARISCURRENTSEARCHREQUESTS";
	my $WriteValue;

	tie(%CurrentSearchRequests, 'DB_File', $CurrentSearchesDatabase, O_RDWR|O_CREAT ) || warn "can't open $CurrentSearchesDatabase: $!";
	flock(%CurrentSearchRequests,LOCK_EX);

		if ( !defined($CurrentSearchRequests{'LASTACCESS'}) || length($CurrentSearchRequests{'LASTACCESS'}) <= 0 ) {
			$CurrentSearchRequests{'LASTACCESS'} = time();
		}

		my $zeit		= time();
		my $lastaccess	= $CurrentSearchRequests{'LASTACCESS'};
		my $zeitminus	= $zeit - $lastaccess;

		if ( $zeit > ($lastaccess + $MaxSearchTime) ) {	# wenn $MaxSearchTime sec kein zugriff
			$WriteValue								= 0;
			$CurrentSearchRequests{$HashName}		= $WriteValue;
			$CurrentSearchRequests{'LASTACCESS'}	= time();
		};

		if ( length($CurrentSearchRequests{$HashName}) <= 0 ) {
			return 0;
		} else {
			return $CurrentSearchRequests{$HashName};
		}

	flock(%CurrentSearchRequests, LOCK_UN);
	untie(%CurrentSearchRequests);
		
};	# sub NoResultDatabaseManager(){





sub ConnectionWritePhexCount(){

	# Schreibe/ Lösche Einträge für Anzeige wieviele aktuelle Suchrequests schon vorhanden sind
	my $HashName		= shift;
	my $ValuetoAdd		= shift;	# postive werte zum addieren | negative werte zum subtrahiern

	tie(%ConnectionsDB, 'DB_File', $ConnectionsDBFile, O_RDWR|O_CREAT ) || warn "can't open $ConnectionsDBFile: $!";
	flock(%ConnectionsDB,LOCK_EX);

		$ConnectionsDB{$HashName}		= $ValuetoAdd;
		$ConnectionsDB{'LASTACCESS'}	= time();

	flock(%ConnectionsDB, LOCK_UN);
	untie(%ConnectionsDB);
	
};	# sub ConnectionWritePhexCount(){


sub ConnectionReadPhexCount(){

	# Lese Einträge für Anzeige wieviele aktuelle Suchrequests schon vorhanden sind im phex
	my $HashName	= shift; # $SEC_MD5
	
	tie(%ConnectionsDB, 'DB_File', $ConnectionsDBFile, O_RDWR|O_CREAT ) || warn "can't open $ConnectionsDB: $!";
		
		if ( $ConnectionsDB{$HashName} > 0 ) {
			return $ConnectionsDB{$HashName};
		} else {
			return 0;
		};

	untie(%ConnectionsDB);
		
};# sub ConnectionReadPhexCount(){



sub ReadBalancingConfig(){

	my $BalancingConfigFile = shift;
	my $User_Preferences	= {};
	my %User_Preferences	= ();

	open(RH,"<$BalancingConfigFile") or die "ReadBalancingConfig() cannot read balancing.cfg\n";
	while (<RH>) {
		chomp;                  # no newline
		s/#.*//;                # no comments
		s/^\s+//;               # no leading white
		s/\s+$//;               # no trailing white
		next unless length;     # anything left?
		my ($var, $value) = split("=", $_);
		$User_Preferences->{$var} = $value;
	};
	close RH;

	return $User_Preferences;

}; # sub ReadBalancingConfig(){


sub IntelligentRawDataCut(){

	####
	## Intelligentes Beschneiden des Phex Contents - es wird so abgeschnitten, dass ein Ergebnis intakt bleibt an der zu cuttenen Stelle
	####

	my $FileContentRef		= shift;						# string Scalar ref
	my $MaxRawDataToProcess	= shift;						# long int
	
	my $FileContent			= ${$FileContentRef};			# greife mittels zeiger auf den inhalt hinter der referenz $FileContentRef zurück
	my $FileContentLength	= 0;							# long int
	my $FileContentLength	= length($FileContent);			# long  int
	my @SplittedContent		= ();							# array prototyp
	my $SplittedContent		= "";							# string

	if ( $MaxRawDataToProcess >= $FileContentLength ) {		# MaxDataToProcess ist größer als PhexContent - wir brauchen den datenstrom nicht abschneiden
		
		# print "DEBUG: No need to cut\n";
		return \$FileContent;								# Referenz auf String zurückgeben

	} elsif ( $FileContentLength > $MaxRawDataToProcess ) { # MaxDataToProcess ist kleiner als PhexContent - wir sollen den datenstrom abschneiden 
	
		@SplittedContent	= split("", $FileContent);		# Ein Array mit allen Zeihen des FileContent füllen

		for (my $i=$MaxRawDataToProcess; $i<=$FileContentLength; $i++ ) {
			
			my $SingleString		= $SplittedContent[$i];
			my $SingleStringNext	= $SplittedContent[$i+1];
			
			if ( $SingleString eq "\\" && $SingleStringNext eq "n" ) {
				
				my $IntelligentCutAtBytePosition = $i + 2;	# aktuelle position plus 2 zeichen '\n'
				$FileContent = substr($FileContent, 0, $IntelligentCutAtBytePosition);	# Intelligent Cut

				# print "DEBUG: I cutted at $IntelligentCutAtBytePosition instead of $MaxRawDataToProcess \n"; 
				return \$FileContent;

			}; # if ( $SingleString eq "\\" && $SingleStringNext eq "n" ) {

		}; # for (my $i=$MaxRawDataToProcess; $i<=$FileContentLength; $i++ ) {
	
	}; # if ( $FileContentLength <= $MaxRawDataToProcess ) {

	return \$FileContent;	# never reached

}; # sub IntelligentRawDataCut(){


sub deleteSpecialChars() {

	my $del_badchar	= shift;
	$del_badchar = substr($del_badchar, 0, $MaxSearchStringLength);		

	# sql 
	$del_badchar =~ s/drop//ig;
	$del_badchar =~ s/insert//ig;
	$del_badchar =~ s/alter//ig;
	$del_badchar =~ s/flush//ig;
	$del_badchar =~ s/distinct//ig;
	$del_badchar =~ s/empty//ig;
	$del_badchar =~ s/select//ig;
	$del_badchar =~ s/truncate//ig;
	$del_badchar =~ s/update//ig;
	$del_badchar =~ s/tables//ig;
	$del_badchar =~ s/exec//ig;
	$del_badchar =~ s/system//ig;
	$del_badchar =~ s/cmd//ig;
			 
	$del_badchar =~ s/\"//ig;
	$del_badchar =~ s/`//ig;
	$del_badchar =~ s/\'//ig;
	$del_badchar =~ s/\?//ig;
	$del_badchar =~ s/\%//ig;
	$del_badchar =~ s/\$//ig;
	$del_badchar =~ s/\!//ig;
	$del_badchar =~ s/\"//ig;
	$del_badchar =~ s/\#//ig;
	$del_badchar =~ s/&//ig;
	$del_badchar =~ s/,//ig;
	$del_badchar =~ s/;//ig;
	$del_badchar =~ s/|//ig;
	$del_badchar =~ s/\\//ig;
	$del_badchar =~ s/\///ig;

	# $del_badchar =~ s///ig;

	return $del_badchar;
	
}; # function deleteSpecialChars() {


sub iRandom(){

	# hole ein zufallselement herraus, dieses eleement darf jedoch bis jetzt noch nicht verwendet
	# worden sein $NotAllowedArray und hole zufallszahlen von X bis Y

	my $randToNumber		= shift;	# bis maximal diese zahl eine zufällige zahl aussuchen
	my $NotAllowedNumbers	= shift;	# array ref das werte enthält, die nicht genommen werden sollen
	my $rand				= int(rand($randToNumber))+1;
	my $good				= 1;

	foreach my $notallowed ( @{$NotAllowedNumbers} ) {
	
		if ( $rand == $notallowed ){
			$good = 0;
		}; # if ( $rand == $var ){

	}; # 	foreach my $notallowed ( @{$NotAllowedNumbers} ) {

	if ( $good != 1 ) {
		return iRandom($randToNumber, $NotAllowedNumbers);
	} else {
		return $rand;
	}; #if ( $good != 1 ) {

}; # sub iRandom(){
