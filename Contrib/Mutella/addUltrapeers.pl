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
use IO::Socket;
use Getopt::Std;
use Data::Dumper;
use Net::hostent;
use MutellaProxy::IO;
use MutellaProxy::Parser;
use MutellaProxy::IOParser;
#use POE::Component::Server::TCP;
#use POE::Component::Client::TCP;
# use IO::Handle;
# STDERR->autoflush(1);

# modules: end

use constant CRLF => '\015\012';

##########################################################

# objects: generate

my $IO			= MutellaProxy::IO->new();
my $PARSER		= MutellaProxy::Parser->new();
my $IOPARSER	= MutellaProxy::IOParser->new();

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
my $socket;
my $listHashRef = {};
my %options;

############################################################

getopts( 'u:hlf:', \%options ) or &usage();

############################################################

# find min:/size: $query

######### CLIENT SOCKET->MUTELLA ############

$socket = IO::Socket::UNIX->new( 
	Peer => UNIXSOCKET,
    Type => SOCK_STREAM,
    Timeout => 60 ) or warn "can't connect to Unix Socket for CLIENT SOCKET->MUTELLA IO: $!\n";

$socket->autoflush(1) if (defined($socket));
$socket->blocking(0) if (defined($socket));

############## HANDY->SERVER SOCKET ###########


########## uninteressant für heute 5.6.06

if ( $options{l} ) {

	$IO->writeSocket( $socket, LIST_COMMAND );
	$list = $IO->readSocket( $socket );

	if ( length($list) == 0 ) {
		print "ERROR:\n";
	} else {
		print "SUCCESS: \n";
	};

	# hole den geparsten content vom LIST_COMMAND
	$listHashRef = $PARSER->ListCommandParser( \$list );

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

	print "ok" if (defined($socket) );

#	$IO->writeSocket( $socket, FIND_COMMAND . " " . $options{f} . "\n" );
	$IO->writeSocket( $socket, FIND_COMMAND . $options{f} . "\n" );
	print "ok query mutella for $options{f}\n";
	exit(0);

} elsif ( $options{h} ){
	
	&usage();

} elsif ( $options{u} ) {

	my $UltraPeerHashRef = $IOPARSER->getUltrapeersFromFile( $options{u}  );

	while( my($key, $peerhost) = each( %{$UltraPeerHashRef} )) {
	#	print "$peerhost\n";
 		$IO->writeSocket( $socket, OPEN_COMMAND . $peerhost . "\n", 0.25 );
		print "Connection to $peerhost\n";
	}; # while(){}

} else {

	&usage();

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
