#!/usr/bin/perl -IMutellaProxy

# Todos: 
#	--> Funktion Wrapper: Aufruf/Absetzen eines Commandos; sollte dies nicht erfolgreich sein, 
#			ruft sich die Funktion rekursiv wieder auf -->mit kleinem Timeout zwischendurch: select(undef, undef, undef, 0.25);
#	--> alles in Module und OO-Style packen
#	--> keine Hacks verwenden
#	--> Referenen benutzen und so Speicher sparen!
#   --> Caching von bereits angefragenen Suchergebnisse
#   --> Agrep als Aprox match für caching
##########################################################

# modules: predeclare our used modules

#use strict;
#use MD5;	# client auth ID

# für den server
use IO::Socket;
use IO::File;
use IO::Select;

# für den rest
use Getopt::Std;
use Data::Dumper;
use Net::hostent;
use MutellaProxy::IO;
use MutellaProxy::Parser;
use MutellaProxy::Daemon;
use MutellaProxy::IOParser;
use MutellaProxy::SortRank;
use Digest::MD5 qw(md5 md5_hex md5_base64);

# use IO::Handle;
# STDERR->autoflush(1);

# modules: end

#use constant CRLF => '\015\012';
use constant CRLF => "\r\n";

##########################################################

# objects: generate

my $IO			= MutellaProxy::IO->new();
my $PARSER		= MutellaProxy::Parser->new();
my $IOPARSER	= MutellaProxy::IOParser->new();
my $SORTRANK	= MutellaProxy::SortRank->new();

# objects: end

###########################################################

# mutelle: commands

use constant HELP_COMMAND	=> "help"	."\n";
use constant INFO_COMMAND	=> "info"	."\n";
use constant HOSTS_COMMAND	=> "hosts"	."\n";
use constant FIND_COMMAND	=> "find ";	# done - simple version ohne size filter
use constant LIST_COMMAND	=> "list"	."\n"; # done - simple version
use constant DELETE_COMMAND	=> "delete ";	# +++
use constant ERASE_COMMAND	=> "erase ";
use constant CLEAR_COMMAND	=> "clear"	."\n";
use constant RESULTS_COMMAND	=> "results ";
use constant STOP_COMMAND	=> "stop"	."\n";
use constant GET_COMMAND	=> "get"	."\n";
use constant OPEN_COMMAND	=> "open ";	# done
use constant SCAN_COMMAND	=> "scan"	."\n";
use constant LIBRARY_COMMAND	=> "library"	."\n";
use constant SET_COMMAND	=> "set"	."\n";
use constant SETADD_COMMAND	=> "set+"	."\n";
use constant SETDEL_COMMAND	=> "set-"	."\n";
use constant EXIT_COMMAND	=> "exit"	."\n";
use constant UNIXSOCKET		=> "/root/.mutella/socket";

# mutella: end

############################################################

my $list;
my $MutellaSocket;
my $listHashRef = {};
my %options;
my $searchQuery;
my $ClientHasRequested = {};
my $SendString;

############################################################

getopts( 'u:hlf:', \%options ) or &usage();

############################################################

# find min:/size: $query

######### CLIENT SOCKET->MUTELLA ############

$MutellaSocket = IO::Socket::UNIX->new( 
	Peer => UNIXSOCKET,
    Type => SOCK_STREAM,
    Timeout => 60 ) or warn "can't connect to Unix Socket for CLIENT SOCKET->MUTELLA IO: $!\n";

$MutellaSocket->autoflush(1) if (defined($MutellaSocket));
$MutellaSocket->blocking(0) if (defined($MutellaSocket));

############## HANDY->SERVER SOCKET ###########

use constant PIDFILE => '/tmp/web_fork.pid';

my $DONE = 0;
$SIG{INT}  = $SIG{TERM} = sub { $DONE++ };

my $port = shift || 3381;
my $socket = IO::Socket::INET->new( LocalPort => $port,
                                    Listen    => SOMAXCONN,
                                    Reuse     => 1 ) or die "Can't create listen socket: $!";
#$socket->setsockopt(SO_ERROR,SO_LINGER,SO_KEEPALIVE);
#$socket->autoflush(1);
#$socket->blocking(0);

my $IN = IO::Select->new($socket);

# create PID file, initialize logging, and go into the background
#init_server(PIDFILE);

die "can't setup server" unless $socket;
print "[Server $0 accepting clients on port $port]\n";

# accept loop
while (!$DONE) {

  next unless $IN->can_read;
  next unless my $c = $socket->accept;
  my $hostinfo = gethostbyaddr($c->peeraddr);

  my $child = launch_child();

  unless ($child) {
 
# alle beiden sachen NICHT AKTIVIEREN,SONST KLAPPT ES NICHT  
#	$c->autoflush(1);
#	$c->blocking(0);

	close $socket;

    # handle_connection($c);
	#my $READ = $c->recv($buffer,1024);
	#print "I READ: '$buffer' \n"; exit;
	my $CIN	= $IO->readSocket( $c );
	
	my $bytes_in	+= length($CIN);
	
	# entferne \r\n aus dem String
#	eval {
#		substr($CIN, length($CIN) - 4, length($CIN) ) = "";
#	};

	# entferne leerzeichen am ende des strings
	$CIN =~ s/[\s]$//;
	print "SERVER: I read $bytes_in Bytes: '$CIN'\n";

	if ( $CIN =~ /FIND/i ) {

		$query = $CIN;
		$query =~ s/FIND //i;
		chomp($query);

		$IO->writeSocket( $MutellaSocket, FIND_COMMAND . $query . "\n" );
		$ClientID = md5_hex( $hostinfo->name . time() );
		
		printf "[Connect from %s - ID $ClientID ] - Submitted Search '$query' to Mutella\n", $hostinfo->name;
	
		$IO->writeSocket( $c, $ClientID . CRLF );
		$IO->writeSocket( $c, CRLF );

		open(WH,">/root/.mutella/IDS/$ClientID") or die;
			print WH "$query";
		close WH;

	#	close $child;
		exit(0);
		

	} elsif ( $CIN =~/RESULTS/i ) {

		$QueryClientID = $CIN;
		$QueryClientID =~ s/RESULTS //i; 
		my $SEARCH;

		chomp($QueryClientID);
		printf "[Connect from %s] - Searving Request for ID '$QueryClientID' \n", $hostinfo->name;

		open(RH,"</root/.mutella/IDS/$QueryClientID");
			$SEARCH	= <RH>;	
		close RH;

		my $QueryNumber = _getResultIDfromSearchQuery( $SEARCH );
		if ( $QueryNumber == 0 ) {
			print "ResultQuery Mismatch\n";
			$IO->writeSocket($c, "query invalid" . CRLF);
		};
		
		my $DownloadHashRef							= $PARSER->ResultCommandParser( $IO, $MutellaSocket, $QueryNumber );
#		my ($SortedResultsHashRef, $ResultCounter )	= $SORTRANK->SortRank( $DownloadHashRef, $SEARCH );
#		my $DownloadHashRef							= $PARSER->ResultCommandParser( $IO, $MutellaSocket, 1 );
#		my ($SortedResultsHashRef, $ResultCounter )	= $SORTRANK->SortRank( $DownloadHashRef, "star" );
		$ResultCounter = 12;


		print "############# Number of Results: $ResultCounter ############## \n";
			
		# wenn noch kein ergebnis für die suchanfrage vorliegt
		if ( $ResultCounter == 0 ) {

			# wenn öfters als 5 mal kein ergebnis kam, dann lösche den eintrag aus dem mutella
			if ( %{$ClientHasRequested}->{ $QueryClientID } == 5 ) {
				
				# lösche den korrespondierenden $QueryNumber Eintrag
				$IO->writeSocket( $MutellaSocket, DELETE_COMMAND . $QueryNumber . "\n" );

				$IO->writeSocket( $c, "query rerequest needed" , 0.50 );
				$IO->writeSocket( $c, CRLF );

				# lösche den eintrag aus dem hash herraus:
				delete $ClientHasRequested->{ $QueryClientID };

			} else {

				# gib aus, dass der handy client noch etwas warten soll
				$IO->writeSocket( $c, "busy" , 0.50 );
				$IO->writeSocket( $c, CRLF );

				# zähle hoch, wie oft für eine ClientID schon ein ergebnis angefragt wurde 
				$ClientHasRequested->{ $QueryClientID }++;

			};

		} else {
			
			# bereite die ergebnisse vor
			
			# zeige ResultCounter Ergebnisse an aber max 5 
			# Todo: later via result schalter den range der ergebnisse angeben
			# $IO->writeSocket( $c, $ResultCounter . CRLF);

			# hier ist ein bug: es werden immer verschiedene ergebnisse ausgespuckt, aber immer mit gleichem SHA1 :SortRank.pm
			#foreach my $ResultCount ( 0..($ResultCounter-1) ) {
			
			foreach my $ResultCount ( 0..5 ) {

				print "######################################################\n";
				print "DEBUG: -$ResultCount- Filename: "	. %{$DownloadHashRef}->{ $ResultCount }->{'FN'} . "\n";
				print "DEBUG: -$ResultCount- PeerHost: "	. %{$DownloadHashRef}->{ $ResultCount }->{ 'PH' } . "\n";
				print "DEBUG: -$ResultCount- Size: "		. %{$DownloadHashRef}->{ $ResultCount }->{ 'SZ' } . "\n";
				print "DEBUG: -$ResultCount- SHA: "			. %{$DownloadHashRef}->{ $ResultCount }->{ 'SH' } . "\n";
				print "DEBUG: -$ResultCount- Rank: "		. %{$DownloadHashRef}->{ $ResultCount }->{ 'RK' } . "\n";
				
				$SendString .= %{$DownloadHashRef}->{ $ResultCount }{'RK'} . "\r\n" . %{$DownloadHashRef}->{ $ResultCount }{'FN'} . "\r\n" . %{$DownloadHashRef}->{ $ResultCount }{'SZ'} . "\r\n" . %{$DownloadHashRef}->{ $ResultCount }{'SH'} . "\r\n" . %{$DownloadHashRef}->{ $ResultCount }{'PH'} . "\r\n";
			
			};
			
			# gib die ergebnisse aus
			$IO->writeSocket( $c, $SendString , 0.50 );
			$IO->writeSocket( $c, CRLF );

			$IO->writeSocket( $MutellaSocket, DELETE_COMMAND . $QueryNumber . "\n" );

		};

	#	close $child;
		exit(0);

	} else {};	

    exit 0;

  } #  unless ($child) {}

  close $c;

}; # while (!$DONE) {}

die "Normal termination\n";


sub _getResultIDfromSearchQuery(){

	my $SearchQuery = shift;
	my $listHashRef = $PARSER->ListCommandParser( $IO, $MutellaSocket );
	for my $value ( keys %{$listHashRef} ) {
		# wenn suchanfrage gleich dem eintrag in der mutella liste, dann gib die result id zurück
		if ( $SearchQuery eq $listHashRef->{ $value }->{ 'SEARCH' } ) {
			return $value;
		};
	};
	return 0;

}; # sub


########## uninteressant für heute 5.6.06

if ( $options{l} ) {

	# hole den geparsten content vom LIST_COMMAND
	my $listHashRef = $PARSER->ListCommandParser( $IO, $MutellaSocket );

	my( $search, $results );

	for my $value ( keys %{$listHashRef} ) {

		$search		= $listHashRef->{ $value }->{ 'SEARCH' }; 
		$results	= $listHashRef->{ $value }->{ 'RESULTS' }; 

		print "Mutella Search Number '$value': Search for '$search' gave '$results' Results\n";
	};

	exit(0);

} elsif ( $options{f} ){

	# todo: nach dem absenden einer query testen, ob der query in mutella angekommen ist 
	#		mit LIST_COMMAND ( QUERY RESULTCOUNT+1) wäre dann unser aktueller query
	# filter für die größe müssen noch eingebaut werden

	print "ok" if (defined($MutellaSocket) );

#	$IO->writeSocket( $MutellaSocket, FIND_COMMAND . " " . $options{f} . "\n" );
	$IO->writeSocket( $MutellaSocket, FIND_COMMAND . $options{f} . "\n" );
	print "ok query mutella for $options{f}\n";
	exit(0);

} elsif ( $options{h} ){
	
	&usage();

} elsif ( $options{u} ) {

	my $UltraPeerHashRef = $IOPARSER->getUltrapeersFromFile( $options{u}  );

	while( my($key, $peerhost) = each( %{$UltraPeerHashRef} )) {
		$IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n", 0.25 );
		# DEBUG: print "Connection to $peerhost\n";
	}; # while(){}

} else {

	# &usage();

};



sub usage() {

print "perl $0 -h : gives help\n"
	."perl $0 -l : lists currently queued search results in mutella\n"
	."perl $0 -f SEARCH QUERY: Search for your query in mutella!\n"
	."perl $0 -u ultrapeerlist.txt : conncect to ultrapeers from file\n";

exit(0);

};


	# ++++++ T3 or better
	# +++++ T1
	# ++++ Cable
	# +++ DSL 
	# ++ ISDN
	# + Modem
