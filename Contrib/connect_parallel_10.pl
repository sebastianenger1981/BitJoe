#!/usr/bin/perl

system("cls");

use strict;
use IO::Socket;
use Data::Dumper;
use Time::HiRes;

$SIG{'CHLD'} = 'IGNORE';



my $t0 = Time::HiRes::time;

my $DeadPeerHosts	= {};
my $MaxProcessCount	= 6;






my @array			= ();
my @array_1			= ();
my @array_2			= ();
my @array_3			= ();
my @array_4			= ();
my @array_5			= ();
my @array_6			= ();
my @array_7			= ();
my @array_8			= ();
my @array_9			= ();
my @array_10		= ();




my $count = 0;
open(RH,"<sources.txt") or die;
	
	my @cnt = <RH>;
	my $cnt	= @cnt;

	my $entryCount	= sprintf("%.0f", $cnt/$MaxProcessCount );

	print "[$cnt] $MaxProcessCount und $entryCount einträge pro prozess\n";

	while(<RH>){

		push(@array_1, "$_\n") if ( $count >= 0 && $count < $entryCount );
		push(@array_2, "$_\n") if ( $count >= $entryCount && $count < ( $entryCount * 2 ) );
		 if ( $count >= ( $entryCount * 2 ) && $count < ( $entryCount * 3 ) ) {
			 push(@array_3, "$_\n");
			 print "array 3\n";
		 };
		push(@array_4, "$_\n") if ( $count >= ( $entryCount * 3 ) && $count < ( $entryCount * 4 ) );
		push(@array_5, "$_\n") if ( $count >= ( $entryCount * 4 ) && $count < ( $entryCount * 5 ) );
		push(@array_6, "$_\n") if ( $count >= ( $entryCount * 5 ) && $count < ( $entryCount * 6 ) );
		push(@array_7, "$_\n") if ( $count >= ( $entryCount * 6 ) && $count < ( $entryCount * 7 ) );
		push(@array_8, "$_\n") if ( $count >= ( $entryCount * 7 ) && $count < ( $entryCount * 8 ) );
		push(@array_9, "$_\n") if ( $count >= ( $entryCount * 8 ) && $count < ( $entryCount * 9 ) );
		push(@array_10, "$_\n") if ( $count >= ( $entryCount * 9 ) && $count < ( $entryCount * 10 ) );


		$count++;

		print "$count\n";

	}; # while(<RH>){


print "asdffffffff";
close RH;




print Dumper @array_1;

print Dumper @array_9;

exit;




for my $i (@array) { 

#	print "Connect To $i\n";
	if ( &doWork_seq("$i:80") == -1 ){
		$DeadPeerHosts->{ "$i:80" } = "";
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

	my $PeerHost	= shift;
	my $pid			= fork();

	if ( !defined($pid) ) {
		
		print "resources not avilable.\n";
	
	} elsif ( $pid == 0 ) {

	#	print "IM THE CHILD\n";
		
		my ( $host, $port ) = split(":", $PeerHost );
		my $socket = IO::Socket::INET->new(PeerAddr => $host,
					   PeerPort => $port,
					   Type     => SOCK_STREAM,
					   Timeout  => 0.5 )
		#or ( $DeadPeerHosts->{ $PeerHost } = "" );
		or return -1;
		
		return 1;
		exit(0);

	} else {
	
	#	print "IM THE PARENT\n";
	#	waitpid($pid,0);
		exit(0);

	}; # if ( !defined($pid) ) {
	
	return 1;

}; # sub doWork(){


sub doWork_seq(){

	my $PeerHost	= shift;
	
		
		my ( $host, $port ) = split(":", $PeerHost );
		my $socket = IO::Socket::INET->new(PeerAddr => $host,
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