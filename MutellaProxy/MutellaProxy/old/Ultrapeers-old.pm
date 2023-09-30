#!/usr/bin/perl	-I/root/.mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		Mutella spezifische Funktionen
##### Todo:			
########################################

package MutellaProxy::Ultrapeers;

use MutellaProxy::Parser;
use MutellaProxy::Time;
use MutellaProxy::IO;
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


my $GWEBCACHEVALIDFOR		= "3600";	#sec
my $ULTRAPEERLIST			= "http://www.zoozle.net/projekt24-testXASDQasdfqwe42/ultrapeers.txt";
my $ULTRAPEERLIST2			= "http://www.zoozle.net/projekt24-testXASDQasdfqwe42/Ultrapeers.txt";
my $ULTRAPEERSTOREPATH		= "/root/.mutella/ULTRAPEERS";
my $HOSTPATH				= "/root/.mutella/hosts.save";

$Net::Nslookup::MX_IS_NUMERIC = 1;
$Net::Nslookup::TIMEOUT		  = 1;

sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub InstallKnowHostsFromFile(){

	my $self			= shift;
	my $MutellaSocket	= MutellaProxy::IO->CreateMutellaSocket();

	open(HOSTS,"<$HOSTPATH") or sub { warn "MutellaProxy::ResultPEERS->writeResultFile(): IO ERROR: $!\n"; return -1; };
	flock (HOSTS, 2);
		while ( my $peerhost = <HOSTS> ) {
			next if ( $peerhost =~ /^#/ );
			
			my ( $IP, $PORT ) = split(':', $peerhost );
			my $Nslookup = nslookup( host => "$IP", type => "PTR" );
			if ( length($Nslookup) > 0 ) {	# host ist erreichbar
				MutellaProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n", 0.1 );	
			}; # if ( length($Nslookup) > 0 ) {}

		}; # while ( my $peerhost = <HOSTS> ) {}
	close HOSTS;
	close $MutellaSocket;

	return 1;

}; # sub InstallKnowHostsFromFile(){}


sub GetAndInstallUltraPeerHostListFromGwebCache(){

	#http://gcachescan.jonatkins.com/
	#http://www.zoozle.net/cc/cc.php?data=1
	#http://dvtci.com/gwcii.php?data=1
	#http://www.sexymobile.co.za/cache.asp
	#http://mcache.firstlight.dk/mcache.php?data=1 &nbsp;
	# "hosts"

	my $self			= shift;
	# my $type			= shift || 'FULL'; # 'FROMFILE', 'RESCAN', 'FULL'
	my $MutellaSocket	= MutellaProxy::IO->CreateMutellaSocket();

	my $FILERESULTSTORE = $ULTRAPEERSTOREPATH . '/' . MutellaProxy::Time->SimpleMySQLDateTime() . '.txt';

	my %GwebCache = (
		"1" => 	"http://www.zoozle.net/cc/cc.php?data=1",
		"2" => 	"http://dvtci.com/gwcii.php?data=1",
		"4" => 	"http://mcache.firstlight.dk/mcache.php?data=1",
		"5" => "http://gwc2.nonexiste.net:8080/",
	);

	if ( $type eq 'FROMFILE' ) {
	
		open(PEERS,"<$FILERESULTSTORE") or sub { warn "MutellaProxy::ResultPEERS->writeResultFile(): IO ERROR: $!\n"; return -1; };
		flock (PEERS, 2);
			while ( my $peerhost = <PEERS> ) {
				
				my ( $IP, $PORT ) = split(':', $peerhost );
				my $Nslookup = nslookup( host => "$IP", type => "PTR" );
				if ( length($Nslookup) > 0 ) {	# host ist erreichbar
					MutellaProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n", 0.1 );	
				}; # if ( length($Nslookup) > 0 ) {}

			}; #  while ( my $peerhost = <PEERS> ) {}
		close PEERS;
	
	} elsif ( $type eq 'RESCAN' ) {
		
		while ( my ($key,$url) = each(%GwebCache) ) {
			_GetExtractInstall($url);
		};

	} elsif ( $type eq 'FULL' ) {
	
		open(PEERS,"+>>$FILERESULTSTORE") or sub { warn "MutellaProxy::ResultPEERS->writeResultFile(): IO ERROR: $!\n"; return -1; };
		flock (PEERS, 2);
			while ( my ($key,$url) = each(%GwebCache) ) {
				_GetExtractStore($url);
			};
		close PEERS;

		open(PEERS,"<$FILERESULTSTORE") or sub { warn "MutellaProxy::ResultPEERS->writeResultFile(): IO ERROR: $!\n"; return -1; };
		flock (PEERS, 2);
			while ( my $peerhost = <PEERS> ) {
				
				my ( $IP, $PORT ) = split(':', $peerhost );
				my $Nslookup = nslookup( host => "$IP", type => "PTR" );
				if ( length($Nslookup) > 0 ) {	# host ist erreichbar
					MutellaProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n", 0.1 );	
				}; # if ( length($Nslookup) > 0 ) {}

			}; #  while ( my $peerhost = <PEERS> ) {}
		close PEERS;

	}; # } elsif ( $type eq 'FULL' ) {}


	sub _GetExtractStore(){
		
		my $url		= shift || "http://www.zoozle.net/cc/cc.php?data=1";
		
		my $doc		= get($url);
		my @content = split(">", $doc);
		my $content;
		#my $time	= time();
		
		for ( my $i=0; $i<=$#content; $i++ ) {
			
			if ( $content[$i] =~ /^([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)+[\:]+[\d{1,5}]/ ) {
				
				#IP:PORT</A
				$content[$i] =~ s/<\/a//ig;
				$content[$i] =~ s/<\/td//ig;

				my ( $IP, $PORT ) = split(':', $content[$i] );
				my $Nslookup = nslookup( host => "$IP", type => "PTR" );
				if ( length($Nslookup) > 0 ) {	# host ist erreichbar
					print PEERS "$content[$i]\n";
				}; # if ( length($Nslookup) > 0 ) {}

			}; # if ( $content[$i] =~ ...

		}; # for ( my $i=0; $i<=$#content; $i++ ) {}
			
	}; # sub _GetExtractStoreInstall()){}


	sub _GetExtractInstall(){
		
		my $url		= shift || "http://www.zoozle.net/cc/cc.php?data=1";
		
		my $doc		= get($url);
		my @content = split(">", $doc);
		
		if ( $#content =~ /\d/ ) {
			$doc	 = get($ULTRAPEERLIST2);
			@content = split(">", $doc);
		};

		my $content;
		#my $time	= time();
		
		for ( my $i=0; $i<=$#content; $i++ ) {
			
			if ( $content[$i] =~ /^([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)+[\:]+[\d{1,5}]/ ) {
				#IP:PORT</A
				$content[$i] =~ s/<\/a//ig;
				$content[$i] =~ s/<\/td//ig;
				
				# my ( $IP, $PORT ) = split(':', $content[$i] );
				# my $Nslookup = nslookup( host => "$IP", type => "PTR" );
				# if ( length($Nslookup) > 0 ) {	# host ist erreichbar
					MutellaProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $content[$i] . "\n" );		
				# }; # if ( length($Nslookup) > 0 ) {}

			}; # if ( $content[$i] =~ ...

		}; # for ( my $i=0; $i<=$#content; $i++ ) {}
			
	}; # sub _GetExtractStoreInstall()){}

	close $MutellaSocket;
	return 1;

}; # sub GetAndInstallUltraPeerHostListFromGwebCache(){}


sub GetAndInstallUltraPeerHostList(){

	my $self				= shift;
	my $UltraPeerInstallTry = shift || 0;
	
	my $List				= get($ULTRAPEERLIST);	# LWP::Simple;
	
	my $UltraPeerHashRef	= $self->getUltrapeersFromMemory($List);
	my $MutellaSocket		= MutellaProxy::IO->CreateMutellaSocket();

	my $UltraPeerCount_Pre	= MutellaProxy::Parser->InfoCommandParser( $MutellaSocket );	# zähle ultrapeers vor dem adden

	# lese HashRef und füge mittels MutellaProxy::IO hinzu
	while( my($key, $peerhost) = each( %{$UltraPeerHashRef} )) {
		
		my ( $IP, $PORT ) = split(':', $peerhost );
		my $Nslookup = nslookup( host => "$IP", type => "PTR" );
		if ( length($Nslookup) > 0 ) {	# host ist erreichbar
			MutellaProxy::IO->writeSocket( $MutellaSocket, OPEN_COMMAND . $peerhost . "\n" );		
		}; # if ( length($Nslookup) > 0 ) {}
	
	}; # while( my($key, $peerhost) = each( %{$UltraPeerHashRef} )) {}

	my $UltraPeerCount_Aft	= MutellaProxy::Parser->InfoCommandParser( $MutellaSocket );	# # zähle ultrapeers nach dem adden

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

	my ( @unordered_content ) = split(' ', $memory );

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
			
		};
	};

	@unordered_content = ();

	return $ULTRAPEERS;

}; # sub getUltrapeersFromMemory(){}


sub getUltrapeersFromFile(){
	
	my $self = shift;
	my $file = shift;	


	my $count		= 0;
	my $contents;
	my $ULTRAPEERS	= {};	

	open(RH, "<$file" ) or sub { warn "MutellaProxy::Mutella->getUltrapeersFromFile(): IO ERROR: $!\n"; return -1; };
		flock (RH, 2);	
		# todos: if stat $filesize >= $SIZE MB then while RH parse LINE $_
		# else: slurp everything into one file
		{ 	local $/ = undef;     # Read entire file at once
			$contents = <RH>;     # Return file as one single `line'
        }  
	close RH;

	my ( @unordered_content ) = split(' ', $contents );

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

		};
	};

	@unordered_content = ();

	return $ULTRAPEERS;

}; # sub getUltrapeersFromFile(){}


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


return 1;