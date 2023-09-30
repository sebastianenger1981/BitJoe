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
use constant CRLF => '\r\n';

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
use constant DELETE_COMMAND	=> "delete";	# +++
use constant ERASE_COMMAND	=> "erase";
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
  
	$c->autoflush(1);
	$c->blocking(0);

	close $socket;

    # handle_connection($c);
	my $CIN			= $IO->readSocket( $c );
	
	my $bytes_in	+= length($CIN);
	
	# entferne \r\n aus dem String
	eval {
		substr($CIN, length($CIN) - 4, length($CIN) ) = "";
	};

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

		open(WH,">/root/.mutella/$ClientID") or die;
			print WH "$query";
		close WH;

		exit(0);
		

	} elsif ( $CIN =~/RESULTS/i ) {

		$QueryClientID = $CIN;
		$QueryClientID =~ s/RESULTS //i; 
		my $SEARCH;

		chomp($QueryClientID);
		printf "[Connect from %s] - Searving Request for ID '$QueryClientID' \n", $hostinfo->name;

		open(RH,"</root/.mutella/$QueryClientID");
			$SEARCH	= <RH>;	
		close RH;

		my $QueryNumber = _getResultIDfromSearchQuery( $SEARCH );
		if ( $QueryNumber == 0 ) {
			print "ResultQuery Mismatch\n";
			# sendto Client: ResultQuery Mismatch
		};
		
		# my $DownloadHashRef		= $PARSER->ResultCommandParser( $IO, $MutellaSocket, $QueryNumber );
		
		my $DownloadHashRef			= $PARSER->ResultCommandParser( $IO, $MutellaSocket, 1 );
		my $SortedResultsHashRef	= $SORTRANK->SortRank( $DownloadHashRef, "queens" );
		
		%{$DownloadHashRef}	= ();	# hash löschen

		foreach my $ResultCount ( 0..5 ) {
			
		#	print "######################################################\n";
		#	print "DEBUG: -$ResultCount- Filename: "	. %{$SortedResultsHashRef}->{ $ResultCount }{'FN'} . "\n";
		#	print "DEBUG: -$ResultCount- PeerHost: "	. %{$SortedResultsHashRef}->{ $ResultCount }->{ 'PH' } . "\n";
		#	print "DEBUG: -$ResultCount- Size: "		. %{$SortedResultsHashRef}->{ $ResultCount }->{ 'SZ' } . "\n";
		#	print "DEBUG: -$ResultCount- SHA: "			. %{$SortedResultsHashRef}->{ $ResultCount }->{ 'SH' } . "\n";
		#	print "DEBUG: -$ResultCount- Rank: "		. %{$SortedResultsHashRef}->{ $ResultCount }->{ 'RK' } . "\n";
			
			$SendString .= %{$SortedResultsHashRef}->{ $ResultCount }{'RK'} . '\r\n' . %{$SortedResultsHashRef}->{ $ResultCount }{'FN'} . '\r\n' . %{$SortedResultsHashRef}->{ $ResultCount }{'SZ'} . '\r\n' . %{$SortedResultsHashRef}->{ $ResultCount }{'SH'} . '\r\n' . %{$SortedResultsHashRef}->{ $ResultCount }{'PH'};
	
		};
		
		$SendString .= '\r\n';
		
		print "SENDE: $SendString\n";
	#	$IO->writeSocket( $c, $SendString . "\015\012" , 0.50 ) if (defined($client));

		$IO->writeSocket( $c, "HIER KOMMEN DIE RESULTS" . CRLF , 0.50 );

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
