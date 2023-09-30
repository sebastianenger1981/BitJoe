#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		Mutella spezifische Funktionen
##### Todo:			
########################################

package PhexProxy::Ultrapeers;

use PhexProxy::Parser;
use PhexProxy::Time;
use PhexProxy::IO;
use Net::Nslookup;
use LWP::Simple;
use strict;

my $VERSION = '0.19.5';

use constant FIND_COMMAND	=> "find ";	
use constant LIST_COMMAND	=> "list \n"; 
use constant DELETE_COMMAND	=> "delete ";	
use constant OPEN_COMMAND	=> "open ";
use constant INFO_COMMAND	=> "info \n";

use constant CRLF			=> "\r\n";


my $ULTRAPEERLIST			= "http://www.alpha64.info/cachelist.txt";
my $ULTRAPEERS				= "/var/www/gwebcache/data/hosts_gnutella.dat";
my $HOSTPATH				= "/server/mutella/hosts.save";

$Net::Nslookup::MX_IS_NUMERIC = 1;
$Net::Nslookup::TIMEOUT		  = 1;

sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub GetAndInstallUltraPeerHostList(){

	my $self				= shift;
	my $UltraPeerInstallTry = shift || 0;
	
	my $List				= get($ULTRAPEERLIST);	# LWP::Simple;
	
	my $UltraPeerHashRef	= $self->getUltrapeersFromMemory($List);
	my $MutellaSocket		= PhexProxy::IO->CreateMutellaSocket();

	my $UltraPeerCount_Pre	= PhexProxy::Parser->InfoCommandParser( $MutellaSocket );	# zähle ultrapeers vor dem adden

	# lese HashRef und füge mittels PhexProxy::IO hinzu
	while( my($key, $peerhost) = each( %{$UltraPeerHashRef} )) {
		
	#	my ( $IP, $PORT ) = split(':', $peerhost );
	#	my $Nslookup = nslookup( host => "$IP", type => "PTR" );
	#	if ( length($Nslookup) > 0 ) {	# host ist erreichbar
			print "Adding $peerhost\n";
			PhexProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n" );		
	#	}; # if ( length($Nslookup) > 0 ) {}
	
	}; # while( my($key, $peerhost) = each( %{$UltraPeerHashRef} )) {}

	my $UltraPeerCount_Aft	= PhexProxy::Parser->InfoCommandParser( $MutellaSocket );	# # zähle ultrapeers nach dem adden

	# sollten die ultrapeers nicht korrekt installiert worden sein, beginne neu
	if ( $UltraPeerCount_Pre >= $UltraPeerCount_Aft ) {
		   	   
		# nach 3 erfolglosen Versuchen breche mit Fehlermeldung ab:
		# todo: later email benachrichtung

		if ( $UltraPeerInstallTry >= 3 ) {
			
			print "ERROR: GetAndInstallUltraPeerHostList() - UltraPeer Reinstall failed after 3 Times\n";
			# Mailto:
			close $MutellaSocket;
			return 0;

		} else { 

			$UltraPeerInstallTry++;

			# rufe die funktion rekusiv wieder auf
			$self->GetAndInstallUltraPeerHostList( $UltraPeerInstallTry );

		};	# if ( $UltraPeerInstallTry >= 3 ) {}
		
	};	# if ( $UltraPeerCount_Pre >= $UltraPeerCount_Aft ) {}

	close $MutellaSocket;
	return 1;

}; # sub GetAndInstallUltraPeerHostList(){}


sub getUltrapeersFromMemory(){
	
	my $self	= shift;
	my $memory	= shift;	

	my $count		= 0;
	my $ULTRAPEERS	= {};

	# my ( @unordered_content ) = split(' ', $memory );
	my ( @unordered_content ) = split('|', $memory );

	foreach my $line ( @unordered_content ){
		# IP:PORT
		if ( $line =~ /([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)+[\:]+[\d{1,5}]/ ) {
			$count++;
			chomp($line);
			
		#	my ( $IP, $PORT ) = split(':', $line );
		#	my $Nslookup = nslookup( host => "$IP", type => "PTR" );
		#	if ( length($Nslookup) > 0 ) {	# host ist erreichbar
				$ULTRAPEERS->{$count} = $line;	
		#	}; # if ( length($Nslookup) > 0 ) {}
			
		}; # if ( $line =~ /([\d{0, ..

	}; # foreach my $line ( @unordered_content ){ ..

	@unordered_content = ();

	return $ULTRAPEERS;

}; # sub getUltrapeersFromMemory(){}


sub getUltrapeersFromFile(){
	
	my $self = shift;
	my $file = shift;	


	my $count		= 0;
	my $contents;
	my $ULTRAPEERS	= {};	

	open(RH, "<$file" ) or sub { warn "PhexProxy::Mutella->getUltrapeersFromFile(): IO ERROR: $!\n"; return -1; };
		flock (RH, 2);	
		# todos: if stat $filesize >= $SIZE MB then while RH parse LINE $_
		# else: slurp everything into one file
		{ 	local $/ = undef;     # Read entire file at once
			$contents = <RH>;     # Return file as one single `line'
        }  
	close RH;

	my ( @unordered_content ) = split(' ', $contents );
	my ( @unordered_content ) = split('|', $contents );

	foreach my $line ( @unordered_content ){
		# IP:PORT
		if ( $line =~ /([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)+[\:]+[\d{1,5}]/ ) {
			$count++;
			chomp($line);
			
			my ( $IP, $PORT ) = split(':', $line );
			my $Nslookup = nslookup( host => "$IP", type => "PTR" );
			if ( length($Nslookup) > 0 ) {	# host ist erreichbar
				$ULTRAPEERS->{$count} = $line;	
			}; # if ( length($Nslookup) > 0 ) {}

		}; # if
	}; # while

	@unordered_content = ();

	return $ULTRAPEERS;

}; # sub getUltrapeersFromFile(){}


sub InstallKnowHostsFromFile(){

	my $self			= shift;
	my $MutellaSocket	= PhexProxy::IO->CreateMutellaSocket();

	open(HOSTS,"<$HOSTPATH") or sub { warn "PhexProxy::ResultPEERS->writeResultFile(): IO ERROR: $!\n"; return -1; };
	flock (HOSTS, 2);
		while ( my $peerhost = <HOSTS> ) {
			next if ( $peerhost =~ /^#/ );
			
			my ( $IP, $PORT ) = split(':', $peerhost );
			my $Nslookup = nslookup( host => "$IP", type => "PTR" );
			if ( length($Nslookup) > 0 ) {	# host ist erreichbar
				PhexProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n", 0.1 );	
			}; # if ( length($Nslookup) > 0 ) {}

		}; # while ( my $peerhost = <HOSTS> ) {}
	close HOSTS;
	close $MutellaSocket;

	return 1;

}; # sub InstallKnowHostsFromFile(){}



sub GetAndInstallUltraPeerHostListFromGwebCache(){

	my $self			= shift;
	my $MutellaSocket	= PhexProxy::IO->CreateMutellaSocket();

	my $Count = 0;

	_GetExtractInstall($ULTRAPEERLIST);

	sub _GetExtractInstall(){
		
		my $url		= shift;
			
		my $doc		= get($url);
		my @content = split(">", $doc);
		
		my $content;
				
		for ( my $i=0; $i<=$#content; $i++ ) {
			
			if ( $content[$i] =~ /^([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)+[\:]+[\d{1,5}]/ ) {
			
				#IP:PORT</A
				$content[$i] =~ s/<\/a//ig;
				$content[$i] =~ s/<\/td//ig;
				
			#	 my ( $IP, $PORT ) = split(':', $content[$i] );
			#	 my $Nslookup = nslookup( host => "$IP", type => "PTR" );
			#	 if ( length($Nslookup) > 0 ) {	# host ist erreichbar
					
					next if ( $Count > 6000 );
					
					print "Adding $content[$i] \n";
					PhexProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $content[$i] . "\n" );
			#	 }; # if ( length($Nslookup) > 0 ) {}

			}; # if ( $content[$i] =~ ...

		}; # for ( my $i=0; $i<=$#content; $i++ ) {}
			
	}; # sub _GetExtractStoreInstall()){}

	close $MutellaSocket;
	return 1;

}; # sub GetAndInstallUltraPeerHostListFromGwebCache(){}


# use constant HELP_COMMAND			=> "help"	."\n";
# use constant INFO_COMMAND			=> "info"	."\n";
# use constant HOSTS_COMMAND		=> "hosts"	."\n";
# use constant ERASE_COMMAND		=> "erase ";
# use constant CLEAR_COMMAND		=> "clear"	."\n";
# use constant RESULTS_COMMAND		=> "results ";
# use constant STOP_COMMAND			=> "stop"	."\n";
# use constant GET_COMMAND			=> "get"	."\n";
# use constant OPEN_COMMAND			=> "open ";	# done
# use constant SCAN_COMMAND			=> "scan"	."\n";
# use constant LIBRARY_COMMAND		=> "library"	."\n";
# use constant SET_COMMAND			=> "set"	."\n";
# use constant SETADD_COMMAND		=> "set+"	."\n";
# use constant SETDEL_COMMAND		=> "set-"	."\n";
# use constant EXIT_COMMAND			=> "exit"	."\n";

#	my %GwebCache = (
#		"1" => 	"http://www.alpha64.info/alpha64/skulls.php?showhosts=1&net=all&zoozle=1",
#		"2" => 	"http://dvtci.com/gwcii.php?data=1",
#		"4" => 	"http://mcache.firstlight.dk/mcache.php?data=1",
#		
#	);

#	while ( my ($key,$url) = each(%GwebCache) ) {
#		_GetExtractInstall($url);
#	};

return 1;