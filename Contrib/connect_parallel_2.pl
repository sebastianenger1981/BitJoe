#!/usr/bin/perl

system("cls");

use strict;
use IO::Socket;
#use Data::Dumper;
use Time::HiRes;

my $t0 = Time::HiRes::time;

my $DeadPeerHosts	= {};
$SIG{'CHLD'} = 'IGNORE';



open(RH,"<sources.txt") or die;
my @array = <RH>;
close RH;



for my $i (@array) { 

#	print "Connect To $i\n";
	if ( &doWork( $i ) == -1 ){
		$DeadPeerHosts->{ $i } = "";
	};
#	doWork("$i:80");
#	print "Connect To $i done: '$return'\n";

};

print "Failed: ";
my $key= keys %{$DeadPeerHosts};
#print Dumper $DeadPeerHosts;
print " $key\n";

my $t1	= Time::HiRes::time;
my $fin = $t1 - $t0;

print "'$t0 - $t1' :: $fin time\n";
exit;


sub doWork(){

#	my $host	= shift;
#	my $port	= shift;
	my $pid;

	my $PeerHost		= shift;
	warn "Kindsprozess nicht moeglich" unless defined( $pid = fork());

	if ( !$pid ) { # execute this if this is the child process ($pid=0 in child process)
		my ( $host, $port ) = split(":", $PeerHost );

		print "PID $pid scanning $host / $port\n";
		my $socket = IO::Socket::INET->new(
						PeerAddr	=> $host,
					   PeerPort		=> $port,
					   Type			=> SOCK_STREAM,
					   Timeout		=> 0.5 )
		or return -1;
		exit(0);

	 } else { # execute this if this is the parent process
	 #	print "Parten process (PID:$$) is starting a child (pseudo PID:$pid).\n";
	
		exit(0);

	};

	return 1;

}; # sub doWork(){




sub doWork_seq(){

#	my $host	= shift;
#	my $port	= shift;
		
	my $PeerHost		= shift;
	my ( $host, $port ) = split(":", $PeerHost );
	
		my $socket = IO::Socket::INET->new(
						PeerAddr => $host,
						PeerPort => $port,
						Type     => SOCK_STREAM,
					    Timeout  => 0.5 )
		#or ( $DeadPeerHosts->{ $PeerHost } = "" );
		or return -1;

	return 1;

}; # sub doWork(){




my @array = (
"18.7.22.83",
"209.85.129.147",
"66.135.200.145",
"216.34.181.60",
"72.167.201.128",
"www.ebay2324asdfasasdfasdf.de",
"18.7.22.83",
"209.85.129.147",
"66.135.200.145",
"216.34.181.60",
"72.167.201.128",
"www.ebay2324asdfasasdfasdf.de",
"18.7.22.83",
"209.85.129.147",
"66.135.200.145",
"216.34.181.60",
"72.167.201.128",
"www.ebay2324asdfasasdfasdf.de",
"18.7.22.83",
"209.85.129.147",
"66.135.200.145",
"216.34.181.60",
"72.167.201.128",
"www.ebay2324asdfasasdfasdf.de",
"18.7.22.83",
"209.85.129.147",
"66.135.200.145",
"216.34.181.60",
"72.167.201.128",
"www.ebay2324asdfasasdfasdf.de",
);

my @array = (
"www.mit.edu",
"www.google.com",
"www.ebay.com",
"www.sourceforge.net",
"www.bitcomet.com",
"www.ebay2324asdfasasdfasdf.de"
);

my @array = (
"www.bitjoe.de",
"www.spiegel.de",
"www.heise.de",
"www.golem.de",
"www.ebay.de",
"www.ebay2324asdfasasdfasdf.de"
);
