#!/usr/bin/perl -I/server/phexproxy/PhexProxy

use strict;

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	26.1.2008
##### Function:		Hauptdatei für PhexProxy
##### Todo:			for statt foreach: ist schneller
##### Hint:			minimum StringLength of one Result is about 70 Chars long
########################################

# root: -20 <> 20 | normal: 0 <> 20
my $ServicePriority = "7";				

system("renice $ServicePriority $$");
system("clear");

# signal handler installieren
$SIG{'TERM'} = $SIG{'INT'} = $SIG{'QUIT'} = $SIG{'HUP'} = sub { die "Signal Handler: $0 has been killed \n";  };

### TODO: Encoding unicode  / zeile 499
use Encode;
use Socket;
use DB_File;
use IO::Select;
use IO::Socket;
use Fcntl ':flock';
use Time::HiRes;
use Data::Dumper;
use PhexProxy::IO;
use PhexProxy::SMS;
use PhexProxy::Mail;
use PhexProxy::Gzip;
use PhexProxy::Time;
use PhexProxy::Phex;
use PhexProxy::Daemon;
use PhexProxy::Logging;
use PhexProxy::CheckSum;
use PhexProxy::PhexSortRank;
use PhexProxy::CryptoLibrary;
use PhexProxy::LicenceManagement;
# use Math::BigFloat;			# perl -MCPAN -e 'force install "Math::BigFloat"'


my $IO						= PhexProxy::IO->new();
my $SMS						= PhexProxy::SMS->new();
my $GZIP					= PhexProxy::Gzip->new();
my $MAIL					= PhexProxy::Mail->new();
my $TIME					= PhexProxy::Time->new();
my $PHEX					= PhexProxy::Phex->new();
my $LOGGING					= PhexProxy::Logging->new();
my $CHECK					= PhexProxy::CheckSum->new();
my $SORTRANK				= PhexProxy::PhexSortRank->new();
my $CRYPTO					= PhexProxy::CryptoLibrary->new();
my $LICENCE					= PhexProxy::LicenceManagement->new();


use constant VERSION		=> "DistributedPhexProxyBenchmark 0.2.b -Beta- 11.3.2008 @ 1.30 Uhr";
use constant CRLF			=> "\r\n";

print "[$0 Version " . VERSION . " running with Service Priority '$ServicePriority']\n\n";

my @BenchmarkSearch	= (
	"",			# leerer eintrag hier korrekt
#	"Möse",
	"Paris",
	"suck",
	"big",
	"huge",
	"breast",
	"little",
	"teen",
	"young",
	"spears",
	"small",
	"spiderman",
	"love",
	"tiny",
	"blow",
	"sex",
	"xxx",
	"fat",
	"top",
	"slut",
	"dirty",
	"tits",
	"girlfriend",
	"bitch",
	"sister",
	"jamba",
	"job",
	"anderson",
	"kylie",
	"britney",
	"shakira",
);



my $ServerToBenchmark		= "87.106.63.182";
my $IsDistributedServer		= "87.106.63.182";


# definiere die paris host server hier, die angefragt werden sollen
my %ParisHosts				= (
	"87.106.63.182"			=> 3383,	# bitjoe.at
#	"81.169.141.129"		=> 3383,	# phexproxy celeron
#	"81.169.137.179"		=> 3383,	# Dual Core
#	"85.214.39.76"			=> 3383,	# bitjoe.de / alpha64.info
#	"85.214.77.110"			=> 3383,	# alleonleinshops.com
#	"85.214.122.130"		=> 3383,	# usenext mirror zoozle
);


my %BenchmarkConnectionHandler		= ();
my %LoadbeimAbholen					= ();
my %MittelWerteTreffer				= ();
my %MittelWerteQuellen				= ();
my %CurrentLoad						= ();
my %CurrentLoadAdvanced				= ();
my %CSVDataKeeper					= ();


my $socket;
my $socketLoad;
my $status							= "_optimalSettings[PhexProxy][OneResult]_";

my $PublicKey						= "0123456789abcdef0123456789abcdef";	# für handy crypto
my $SecurityToken					= "%6ASdgdfAERGHA7845338w4eFW44325fwer"; # für PhexRemoteControl
my $BenchmarkConnectionHandlerFile	= "/tmp/BenchmarkConnections.db"; unlink $BenchmarkConnectionHandlerFile;	# reset file on every start
my $PhexRemoteControlPort			= 9977;	# port für service loadcheck
my $StartBenchmarkAtLoad			= 2.05;	# benchmark starten bei diesem load


my $DoHowmayBenchmarks				= $ARGV[0] || 5;	# zero means do n, n=1+n
my $WaitTimeoutForResultRequest		= 30;	# nach x sekunden sollen ergebnisse abgeholt werden


while( my ($host,undef) = each(%ParisHosts)){
	$CurrentLoadAdvanced{$host} = 0;
}; # while( my ($string,$load) = each(%CurrentLoad)){

###########
####### MAIN
##############

####
## Erst bei geringem Load: Start
####

LOADBEGIN:
#my $phexproxyLoad_pre	= VerySimpleLoadCecker("81.169.141.129");
my $shopsLoad_pre		= VerySimpleLoadCecker($ServerToBenchmark);
#my $quadLoad_pre		= VerySimpleLoadCecker("87.106.63.182");

# if ( $phexproxyLoad_pre > $StartBenchmarkAtLoad || $shopsLoad_pre > $StartBenchmarkAtLoad || $quadLoad_pre > $StartBenchmarkAtLoad ) {
if ( $shopsLoad_pre > $StartBenchmarkAtLoad ) {	
	my $RandSleepTime	= rand(30)+1;

	# print "Start [ Load @ $StartBenchmarkAtLoad ] - Quad $quadLoad_pre | Dual Core $shopsLoad_pre | PhexProxy $phexproxyLoad_pre \n";
	 print "Start [ Load @ $StartBenchmarkAtLoad ] - Dual Core $shopsLoad_pre \n";
	# print "Sleeping for $RandSleepTime sec \n";
	
	select (undef, undef, undef, $RandSleepTime );
	goto LOADBEGIN;

}; # if ( ( ...


#$phexproxyLoad_pre	= VerySimpleLoadCecker("81.169.141.129");
$shopsLoad_pre		= VerySimpleLoadCecker($ServerToBenchmark);
#$quadLoad_pre		= VerySimpleLoadCecker("87.106.63.182");

#print "Load bei Start Quad $quadLoad_pre | Dual Core $shopsLoad_pre | PhexProxy $phexproxyLoad_pre\n";
print "Load bei Start Dual Core $shopsLoad_pre \n";

####
## Erst bei geringem Load: End
####




tie(%BenchmarkConnectionHandler, 'DB_File', $BenchmarkConnectionHandlerFile, O_RDWR|O_CREAT ) || die "can't open $BenchmarkConnectionHandlerFile: $!";

# my ($seconds, $microseconds)		= Time::HiRes::gettimeofday();

$CSVDataKeeper{"starttime"}			= time();
$CSVDataKeeper{"noresultquerys"}	= 0;

print "Sende find Requests\n";
for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
	
	######
	### FIND 
	######
	NormalLoadChecker();
	CompleteFindRequest( $i );

}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {

print "Sende load Anfragen\n";
for ( my $i = 1; $i<=$WaitTimeoutForResultRequest; $i++ ) {
	
	######
	### LOAD
	######

	NormalLoadChecker();
	sleep 1;

	# my $RandSleepTime = rand(2);
	# select (undef, undef, undef, $RandSleepTime );	

}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {


print "Send Result Requests\n";
for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
	
	######
	### RESULT
	######

	NormalLoadChecker();
	my $SearchQuery						= $BenchmarkSearch[$i];
	my $Results							= CompleteResultRequest($SearchQuery);
	NormalLoadChecker();

	while( my ($host,undef) = each(%ParisHosts)){
		#	$LoadbeimAbholen{$SearchQuery}	.= "#$host#". SimpleLoadCecker($host);
		$CSVDataKeeper{"loadabholen-$SearchQuery-$host"} = SimpleLoadCecker($host);
	
	}; # while( my ($string,$load) = each(%CurrentLoad)){
	
	if ( length($Results) <= 10 ) {
		
		my $noresults						= $CSVDataKeeper{"noresultquerys"};
		$noresults							+= 1;
		$CSVDataKeeper{"noresultquerys"}	= $noresults;
		$MittelWerteTreffer{$SearchQuery}	= 0;
		$MittelWerteQuellen{$SearchQuery}	= 0;

	} else {
	
		my ($treffer, $quellen )			= ResultAuswertung($Results);
		$MittelWerteTreffer{$SearchQuery}	= $treffer;
		$MittelWerteQuellen{$SearchQuery}	= $quellen;
		
	#	my $MittelWertTreffer				= sprintf ("%.2f", $treffer / $DoHowmayBenchmarks );
	#	my $MittelWertQuellen				= sprintf ("%.2f", $quellen / $DoHowmayBenchmarks );

	#	$MittelWerteTreffer{$SearchQuery}	= $MittelWertTreffer;
	#	$MittelWerteQuellen{$SearchQuery}	= $MittelWertQuellen;

	}; # if ( length($Results) <= 10 ) {

}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {

NormalLoadChecker();
my $ProxyLoadAfter								= SimpleLoadCecker($IsDistributedServer);
$CSVDataKeeper{"loadafterwork"}					= $ProxyLoadAfter;

#my $phexproxyLoad								= LoadMaxPerServer("81.169.141.129");
my $shopsLoad									= LoadMaxPerServer($ServerToBenchmark);
my $quadLoad									= LoadMaxPerServer("87.106.63.182");

$CSVDataKeeper{"loadmax-$IsDistributedServer"}	= $quadLoad;
#$CSVDataKeeper{"loadmax-81.169.141.129"}		= $phexproxyLoad;
$CSVDataKeeper{"loadmax-81.169.137.179"}		= $shopsLoad;

# my ($seconds2, $microseconds2)				= Time::HiRes::gettimeofday();
$CSVDataKeeper{"endtime"}						= time();

CSVWriter();	# cvs ausgeben


#print "MaxLoad Buggy(?) Quad $quadLoad | Dual Core $shopsLoad | PhexProxy $phexproxyLoad\n";

#my $phexproxyLoad	= $CurrentLoadAdvanced{"81.169.141.129"};
my $shopsLoad		= $CurrentLoadAdvanced{$ServerToBenchmark};
#my $quadLoad		= $CurrentLoadAdvanced{"87.106.63.182"};

#print "MaxLoad Quad $quadLoad | Dual Core $shopsLoad | PhexProxy $phexproxyLoad\n";
print "MaxLoad Dual Core $shopsLoad \n";
print "Finished\n";

untie(%BenchmarkConnectionHandler);

exit(0);







sub CSVWriter(){
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon++;
	$year += 1900;
	my $filename = "benchmarks/paris_benchmark_$year".$mon.$mday."-at-$hour-$min-$sec-[$DoHowmayBenchmarks]_$status.csv";
	mkdir "benchmarks";

	open(CSV,">$filename");

	#	print CSV "Anfragen an Phex;Load beim Abholen der Ergebnisse [Celeron];Load beim Abholen der Ergebnisse [Dual Core];Load beim Abholen der Ergebnisse [Quad Core];Load max. [Celeron];Load max. [Dual Core];Load max. [Quad Core];Load Proxy nach dem Ausliefern aller Ergebnisse;Load Proxy max.;Dauer: vom Start des Tests bis alle Ergebnisse vom Proxy ausgeliefert wurden (ms);Anzahl der Suchanfragen ohne Treffer;Mittelwert Quellen (Anzahl Quellen / Anzahl Suchanfragen);Mittelwert Treffer (Anzahl Treffer / Anzahl Suchanfragen);Delay zwischen den Suchanfragen [Celeron | Dual | Quad]\n";

	# print CSV "Anfragen an Phex;Load beim Abholen [Celeron];Load beim Abholen [Dual Core];Load beim Abholen [Quad Core];Load max. [Celeron];Load max. [Dual Core];Load max. [Quad Core];Load Proxy Ende;Load Proxy max.;Dauer (s);Anzahl der Suchanfragen ohne Treffer;Mittelwert Quellen (Anzahl Quellen / Anzahl Suchanfragen);Mittelwert Treffer (Anzahl Treffer / Anzahl Suchanfragen);Delay zwischen den Suchanfragen [Celeron | Dual | Quad]\n";
	
	my $mtreffer;
	my $mquellen;

	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		my $SearchQuery		= $BenchmarkSearch[$i];
		$mtreffer			+= $MittelWerteTreffer{$SearchQuery};
		$mquellen			+= $MittelWerteQuellen{$SearchQuery};
	}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {

		$mtreffer				= sprintf ("%.2f", $mtreffer / $DoHowmayBenchmarks );
		$mquellen				= sprintf ("%.2f", $mquellen / $DoHowmayBenchmarks );
		$mtreffer				=~ s/\./,/g;
		$mquellen				=~ s/\./,/g;


	#	Anfragen an Phex,	x
	print CSV "Anfragen an Phex;";
	my $WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		$WriteString .= "$i;"		
	}; 
	print CSV "$WriteString\n";
	
#	#	Load beim Abholen der Ergebnisse [Celeron]	
#	print CSV "Load beim Abholen [Celeron];";
#	$WriteString = "";
#	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
#		my $SearchQuery			= $BenchmarkSearch[$i];
#		my $loadbeimabholen_1	= $CSVDataKeeper{"loadabholen-$SearchQuery-81.169.141.129"};
#		$loadbeimabholen_1		=~ s/\./,/g;
#		$WriteString			.= "$loadbeimabholen_1;";
#	}; 
#	print CSV "$WriteString\n";

	#	Load beim Abholen [Dual Core]	
	print CSV "Load beim Abholen [Dual Core];";
	$WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		my $SearchQuery			= $BenchmarkSearch[$i];
		my $loadbeimabholen_2	= $CSVDataKeeper{"loadabholen-$SearchQuery-81.169.137.179"};
		$loadbeimabholen_2		=~ s/\./,/g;
		$WriteString			.= "$loadbeimabholen_2;";
	}; 
	print CSV "$WriteString\n";

#	#	Load beim Abholen [Quad Core]
#	print CSV "Load beim Abholen [Quad Core];";
#	$WriteString = "";
#	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
#		my $SearchQuery			= $BenchmarkSearch[$i];
#		my $loadbeimabholen_3	= $CSVDataKeeper{"loadabholen-$SearchQuery-87.106.63.182"};
#		$loadbeimabholen_3		=~ s/\./,/g;
#		$WriteString			.= "$loadbeimabholen_3;";
#	}; 
#	print CSV "$WriteString\n";
	

#	#	Load max. [Celeron]
#	print CSV "Load max. [Celeron];";
#	$WriteString = "";
#	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
#		my $SearchQuery			= $BenchmarkSearch[$i];
#		my $maxload_2			= $CSVDataKeeper{"loadmax-81.169.141.129"};
#		$maxload_2				=~ s/\./,/g;
#		$WriteString			.= "$maxload_2;";
#	}; 
#	print CSV "$WriteString\n";


	#	Load max. [Dual Core]
	print CSV "Load max. [Dual Core];";
	$WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		my $SearchQuery			= $BenchmarkSearch[$i];
		my $maxload_2			= $CSVDataKeeper{"loadmax-81.169.137.179"};
		$maxload_2				=~ s/\./,/g;
		$WriteString			.= "$maxload_2;";
	}; 
	print CSV "$WriteString\n";

#	#	Load max. [Quad Core]
#	print CSV "Load max. [Quad Core];";
#	$WriteString = "";
#	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
#		my $SearchQuery			= $BenchmarkSearch[$i];
#		my $maxload_2			= $CSVDataKeeper{"loadmax-87.106.63.182"};
#		$maxload_2				=~ s/\./,/g;
#		$WriteString			.= "$maxload_2;";
#	}; 
#	print CSV "$WriteString\n";

	#	Load Proxy Ende
	print CSV "Load Proxy Ende;";
	$WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		my $loadafter			= $CSVDataKeeper{"loadafterwork"};
		$loadafter				=~ s/\./,/g;
		$WriteString			.= "$loadafter;";
	}; 
	print CSV "$WriteString\n";

	#	Load Proxy Ende
	print CSV "Load Proxy max.;";
	$WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		my $maxload_1			= $CSVDataKeeper{"loadmax-87.106.63.182"};
		$maxload_1				=~ s/\./,/g;
		$WriteString			.= "$maxload_1;";
	}; 
	print CSV "$WriteString\n";

	# Dauer (s)
	print CSV "Dauer (s);";
	$WriteString = "";
	my $RunningTime			= $CSVDataKeeper{"endtime"} - $CSVDataKeeper{"starttime"};
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		$WriteString .= "$RunningTime;";
	}; 
	print CSV "$WriteString\n";

	# Anzahl der Suchanfragen ohne Treffer	
	print CSV "Anzahl der Suchanfragen ohne Treffer;";
	$WriteString = "";
	my $NullSearch			= $CSVDataKeeper{"noresultquerys"};
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		
		$WriteString .= "$NullSearch;";
	}; 
	print CSV "$WriteString\n";

	# Mittelwert Quellen	
	print CSV "Mittelwert Quellen;";
	$WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		
		$WriteString .= "$mquellen;";
	}; 
	print CSV "$WriteString\n";

	# Mittelwert Treffer
	print CSV "Mittelwert Treffer;";
	$WriteString = "";
	for ( my $i = 1; $i<=$DoHowmayBenchmarks; $i++ ) {
		
		$WriteString .= "$mtreffer;";
	}; 
	print CSV "$WriteString\n";

	close CSV;
	### system("/bin/chmod 755 $filename");
	
	return 1;

#	Anfragen an Phex,												x
#	Load beim Abholen der Ergebnisse [Celeron]						x
#	Load beim Abholen der Ergebnisse [Dual Core]					x
#	Load beim Abholen der Ergebnisse [Quad Core]					x
#	Load max. [Celeron]												x
#	Load max. [Dual Core]											x
#	Load max. [Quad Core]											x
#	Load Proxy nach dem Ausliefern aller Ergebnisse					x
#	Load Proxy max.													x
#	Dauer: vom Start des Tests bis alle Ergebnisse ... (ms)			x
#	Anzahl der Suchanfragen ohne Treffer							x
#	Mittelwert Quellen (Anzahl Quellen / Anzahl Suchanfragen)		x
#	Mittelwert Treffer (Anzahl Treffer / Anzahl Suchanfragen)		x
#	Delay zwischen den Suchanfragen [Celeron | Dual | Quad]			-1
	
}; # sub CSVWriter(){



sub NormalLoadChecker(){
	
	# für kontinuierliches pollen des loads aller server
	my $RequestString	= "load##$SecurityToken\r\n";
	my $Entries			= keys(%CurrentLoad);
	my $CurrentEntry	= $Entries / keys(%ParisHosts);

	while( my ($host,undef) = each(%ParisHosts)){

		my $LoadSocket = openSocketLoad($host);
		$IO->writeSocket($LoadSocket, $RequestString );
		my $ReturnString = $IO->readSocket($LoadSocket);
		close $LoadSocket;
		
		my ( $CurrentLoad, $OldLoad, $VeryOldLoad)	= split(" ", $ReturnString );
		#print " $CurrentLoad, $OldLoad, $VeryOldLoad \n";
		
		my $AdvancedLoad = $CurrentLoadAdvanced{$host};
		if ( $AdvancedLoad <= $CurrentLoad ) {
			$CurrentLoadAdvanced{$host}	= $CurrentLoad;
		}; # if ( $CurrentLoadAdvanced{$host} > $CurrentLoad ) {

		$CurrentLoad{"$host-$CurrentEntry"}			= $CurrentLoad;
		
	}; # while( my ($host,$hostname) = each(%ParisHosts)){

	return 1;

}; # sub NormalLoadChecker(){



sub ResultAuswertung(){

	my $results			= shift;
	
	my @TmpArray		= ();
	my @Array			= split("\r", $results );
	my $ResultQuellen	= scalar(@Array);
	my @quellen 		= split("\r\n",  $results);
	my $ResultTreffer	= scalar(@quellen);
	
	# print "Treffer $ResultTreffer und Quellen $ResultQuellen \n";
	# my $MittelWert		= sprintf ("%.2f", $ResultQuellen / $ResultTreffer );

	return ($ResultTreffer, $ResultQuellen );

}; # sub ResultAuswertung(){


sub LoadMaxPerServer(){

	# gib den maximalen load eines servers aus
	# $CurrentLoad{"$host-$CurrentEntry"}			= $CurrentLoad;

	my $server	= shift;
	my @LOAD	= ();
	my @SORTED	= ();

	while( my ($string,$load) = each(%CurrentLoad)){
		
		my ($host,undef) = split("-", $string);
		next if ( $host ne $server );
		push(@LOAD, $load);

	}; # while( my ($string,$load) = each(%CurrentLoad)){

	# @SORTED = sort { $a <=> $b } @LOAD;
	@SORTED = sort { $b <=> $a } @LOAD;
	
	# print Dumper @SORTED;
	return $SORTED[0];

}; # sub LoadMaxPerServer(){


sub SimpleLoadCecker(){

	# load checking für einen server, trägt keine daten ein
	my $server			= shift;
	my $RequestString	= "load##$SecurityToken\r\n";

	my $LoadSocket		= openSocketLoad($server);
	$IO->writeSocket($LoadSocket, $RequestString );
	my $ReturnString	= $IO->readSocket($LoadSocket);
	close $LoadSocket;

	my ( $CurrentLoad, $OldLoad, $VeryOldLoad)	= split(" ", $ReturnString );

	# trage den einfach abgeholten load mit in die globale load datei
	my $Entries			= keys(%CurrentLoad);
	my $RandPosition	= $Entries++;
	$CurrentLoad{"$server-$RandPosition"} = $CurrentLoad;

	return $CurrentLoad;

}; # sub SimpleLoadCecker(){


sub VerySimpleLoadCecker(){

	# load checking für einen server
	my $server			= shift;
	my $RequestString	= "load##$SecurityToken\r\n";

	my $LoadSocket		= openSocketLoad($server);
	$IO->writeSocket($LoadSocket, $RequestString );
	my $ReturnString	= $IO->readSocket($LoadSocket);
	close $LoadSocket;

	my ( $CurrentLoad, $OldLoad, $VeryOldLoad)	= split(" ", $ReturnString );

	return $CurrentLoad;

}; # sub VerySimpleLoadCecker(){


sub CompleteResultRequest(){

	my $SearchQuery		= shift;

	my $client_id		= $BenchmarkConnectionHandler{"$SearchQuery-ID"};
	my $RawResult		= resultRequest($client_id);
	my $CryptResult		= encryptRequest($RawResult);
	my $CryptResultMD5	= $CHECK->MD5ToHEX($CryptResult);
	my $ResultSendString= "$CryptResultMD5##$PublicKey##$CryptResult";

	print "Sending Result Request for '$SearchQuery' with ClientID '$client_id'!\n";

	my $SocketToDistributed = openSocket();
	$IO->writeSocket($SocketToDistributed, "$ResultSendString\r\n" );
	my $ResultsZip	= $IO->readSocketBM($SocketToDistributed);
	my $Results		= $GZIP->gzip_decompress_string($ResultsZip);
	
	$BenchmarkConnectionHandler{"RESULTS"}			= $Results;
	$BenchmarkConnectionHandler{"$SearchQuery-END"} = time();
	
	return $Results;

}; # sub CompleteResultRequest(){


sub CompleteFindRequest(){

	####################### crypto api implementatione #####################
	#	$IOReadFromClient[0] = MD5 Wert der Verschlüsselten Nachricht
	#	$IOReadFromClient[1] = der public schlüssel 
	#	$IOReadFromClient[2] = die verschlüsselte nachricht

	my $i				= shift;
	my $SearchQuery		= $BenchmarkSearch[$i];

	my $RawFind			= findRequest($i, \@BenchmarkSearch );
		
	my $CryptFind		= encryptRequest($RawFind);
	my $CryptFindMD5	= $CHECK->MD5ToHEX($CryptFind);
	my $FindSendString	= "$CryptFindMD5##$PublicKey##$CryptFind";

	print "FindRequest for '$SearchQuery' \n";
	my $SocketToDistributed = openSocket();
	$IO->writeSocket($SocketToDistributed, "$FindSendString\r\n" );

	my $ClientIDZip		= $IO->readSocket($SocketToDistributed);
	my $ClientID		= $GZIP->gzip_decompress_string($ClientIDZip);

	$BenchmarkConnectionHandler{"$SearchQuery-ID"}		= $ClientID;
	$BenchmarkConnectionHandler{"$SearchQuery-START"}	= time();

	return $SearchQuery;

}; # sub CompleteFindRequest(){


sub openSocketLoad(){

	my $server	= shift;

$socketLoad = IO::Socket::INET->new( 
				PeerAddr	=> $server,
				PeerPort	=> $PhexRemoteControlPort,		
				Proto		=> 'tcp',
				Timeout		=> 2 ) or die "socket Error $!\n",

	return $socketLoad;

}; # sub openSocket(){


sub openSocket(){

$socket = IO::Socket::INET->new( 
				PeerAddr	=> $IsDistributedServer,
				PeerPort	=> 7773,		
				Proto		=> 'tcp',
				Timeout		=> 2 ) or die "socket Error $!\n",

	return $socket;

}; # sub openSocket(){


sub encryptRequest(){

	my $PlainText = shift;
	return $CRYPTO->Encrypt( $PublicKey, $PlainText );

}; # sub encryptRequest(){


sub findRequest(){
	
	### find##b,0##IMEI##MILLIONAIRE##1.0##paris##JAVAVERSION##HandyModell##PROVIDER
	my $RequestNumber	= shift;
	my $ArrRef			= shift;

	my $SearchString	= encode("utf8", $ArrRef->[$RequestNumber]);
	# return "find##b,0##IMEI##MILLIONAIRE##1.0##" . $ArrRef->[$RequestNumber]. "##JAVAVERSION##HandyModell##PROVIDER";
	return "find##b,0##IMEI##MILLIONAIRE##1.0##" .$SearchString. "##JAVAVERSION##HandyModell##PROVIDER";

}; # sub findRequest(){


sub resultRequest(){

	### result##b,0##IMEI##MILLIONAIRE##1.0##paris##acd3c8521da682f5ed346c0d20e78970##
	my $ID				= shift;
	# my $Search			= shift;

	return "result##b,0##IMEI##MILLIONAIRE##1.0##Search##" . $ID . "##";

}; # sub resultRequest(){


sub MittelwertFromArray(){

	my $ArrRef		= shift;
	my $ArrCount	= scalar( @{$ArrRef} ); 
	my $tmpR		= 0;

	foreach my $entry ( @{$ArrRef} ) {
		
		$tmpR += $entry;

	}; # foreach my $entry ( @{$ArrRef} ) {

	return sprintf ("%.2f", $tmpR / $ArrCount );

}; # sub MittelwertFromArray(){



#	# my $PreLoad			= SimpleLoadCecker();
#	NormalLoadChecker();
#
#	my $Search				= CompleteFindRequest( int(rand( scalar(@BenchmarkSearch) ) + 1) );
#
#	NormalLoadChecker();
#
#	sleep $WaitTimeoutForResultRequest;
#	my $Results				= CompleteResultRequest( $Search );
#
#	NormalLoadChecker();
##
#	my ($treffer, $quelln ) = ResultAuswertung($Results);
#	my $MittelWert			= sprintf ("%.2f", $quelln / $treffer );
#
#	my $phexproxyLoad		= LoadMaxPerServer("81.169.141.129");
#	my $shopsLoad			= LoadMaxPerServer("81.169.137.179");
#	my $quadLoad			= LoadMaxPerServer("87.106.63.182");
#
#	if ( length($Results) <= 10 ) {
#		print "Kein Treffer für $Search \n";
#	};
#
#	print "i got $treffer Treffer und durchschnittlich $quelln quellen | Mittelwert $MittelWert fuer suchbegriff $Search \n";
#	print "LoadMax $phexproxyLoad   ----    $shopsLoad  ----- $quadLoad \n ";
#
#	open(WH,">bench_debug.txt");
#	print WH $Results;
#	close WH;
#
#	# afterload
#	# cvs schreiben

#while( my ($search, $string) = each(%Mittelwert)){
#	my ($treffer, $quellen) = split("#", $string);
#	my $MittelWertTreffer = $treffer / $i;
#	my $MittelWertQuellen = $quellen / $i;
#
#}; # while( my ($search,$string) = each(%Mittelwert)){



#for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {
	
	######
	### FIND 
	######

#	my $SearchQuery		= $BenchmarkSearch[$i];
#	CompleteFindRequest( $i );

	# $BenchmarkConnectionHandler{"$SearchQuery-ID"} = $ClientID;
	# $BenchmarkConnectionHandler{"$SearchQuery-START"} = time();
	# $BenchmarkConnectionHandler{"RESULTS"}			= $Results;
	# $BenchmarkConnectionHandler{"$SearchQuery-END"} = time();

#	print "ClientID is '$ClientID' \n";
#	print "Sleeping $WaitTimeoutForResultRequest s until ResultRequest\n";
#	sleep $WaitTimeoutForResultRequest;
#	print "I Got '$Results'\n";

#}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {


#for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {
	
	######
	### LOAD
	######

#	NormalLoadChecker();
#	my $RandSleepTime = rand(2);
#	select (undef, undef, undef, $RandSleepTime );	

#}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {


#for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {
	
	######
	### RESULT
	######

#	my $SearchQuery		= $BenchmarkSearch[$i];
#	CompleteResultRequest($SearchQuery);

#}; # for ( my $i = 0; $i<=$DoHowmayBenchmarks; $i++ ) {

	# $BenchmarkConnectionHandler{"$SearchQuery-ID"} = $ClientID;
	# $BenchmarkConnectionHandler{"$SearchQuery-START"} = time();
	# $BenchmarkConnectionHandler{"RESULTS"}			= $Results;
	# $BenchmarkConnectionHandler{"$SearchQuery-END"} = time();