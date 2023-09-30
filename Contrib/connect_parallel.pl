#!/usr/bin/perl


use strict;
use IO::Socket;

my $socket;

# $SIG{'CHLD'} = sub { wait();  $socket->close; };
$SIG{'CHLD'} = 'IGNORE';



my @array = (
"www.bitjoe.de",
"www.spiegel.de",
"www.heise.de",
"www.golem.de",
"www.ebay.de",
"www.ebay2324asdfasasdfasdf.de"
);

for my $i (@array) { 
#	print "Connect To $i\n";
	my $return = doWork($i);
	print "Connect To $i done: '$return'\n";
};

exit;

sub doWork(){

	my $host	= shift;
	my $port	= shift || 80;

	warn "Kindsprozess nicht moeglich" unless defined( my $pid = fork());

	if ( !$pid ) { # execute this if this is the child process ($pid=0 in child process)
		my $socket = IO::Socket::INET->new(PeerAddr => $host,
					   PeerPort => $port,
					   Type     => SOCK_STREAM,
					   Timeout  => 0.5 )
		or return -1;
		exit(0);

	 } else { # execute this if this is the parent process
	 #	print "Parten process (PID:$$) is starting a child (pseudo PID:$pid).\n";
	
	#	return 1;
	};

	return 1;

}; # sub doWork(){

exit;

