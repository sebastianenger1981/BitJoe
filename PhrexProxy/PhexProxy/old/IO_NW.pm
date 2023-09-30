#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		IO spezifisches Modul
##### Todo:			
########################################

package PhexProxy::IO;

$| = 1;
my $VERSION = '0.23.1';

# use IO::Socket::SSL qw(debug4);

use PhexProxy::CryptoLibrary;
use PhexProxy::CheckSum;
use IO::Socket;
use strict;


use constant RANDOM_DEVICE	=> '/dev/urandom';
use constant MAXINCBYTES	=> 50 * 1024 * 1024;	# 10 mbytes


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub readSocket() {
	
	my $self	= shift;
	my $socket	= shift;
	
	my $IO;
	my $STREAM;
	my $StreamCount = 0;

	binmode($socket);

	my $STREAM = <$socket>;
	return $STREAM;

	##
	##	new test
	##

	while (sysread($socket , $IO, 1) == 1) {
		
		if ( $StreamCount >= MAXINCBYTES ) {
			
			# breche ab, wenn mehr als MAXINCBYTES Bytes in einer Session an den Server gesendet wurden
			print "WARNING: Possible Denial of Service Attack - more than " .MAXINCBYTES. " Bytes of incoming Traffic!\n";
			$STREAM = '';
			exit(0);

		}; # if ( $StreamCount >= MAXINCBYTES ) {
		
		$STREAM = $STREAM . $IO;
		$StreamCount++;

    }; # while (sysread($socket , $IO, 1) == 1) {}

	return $STREAM;

}; # sub readSocket(){}


sub writeSocket(){
	
	my $self		= shift;
	my $socket		= shift;
	my $refContent	= shift;
	my $delay		= shift || 0;
	
	select(undef, undef, undef, $delay );
	binmode($socket);

	if ( ref($refContent) eq 'ARRAY' ) {

		for ( my $i=0; $i<=$#{$refContent}; $i++ ) {
			syswrite($socket, $refContent->[$i], length($refContent->[$i]) );	
		}; # for ( my $i=0; ... 

	} elsif ( ref($refContent) eq 'HASH' ) {

		my $keys = keys( %{$refContent} );
		for ( my $i=0; $i<=$keys; $i++ ) {
			syswrite($socket, $refContent->{$i}, length($refContent->{$i}) );
		}; # for ( my $i=0; ...	

	} elsif ( ref($refContent) eq 'SCALAR' ) {
		syswrite($socket, ${$refContent}, length(${$refContent}) );

	} elsif ( ref($refContent) eq '' ) {	# normaler scalar senden
		syswrite($socket, $refContent, length($refContent) );

	} else {

		# code oder glob ref
		warn "PhexProxy::IO->writeSocket(): CODE or GLOB Ref - not supported\n";
		return -1;

	}; # if
	
	return 1;	# always false

}; # sub sub writeSocket(){}

# zu welchem port soll ich mich auf den phex verbinden?
sub CreatePhexConnection(){
	
	my $self	= shift;
	my $TIMEOUT = shift || 150;

	my $PhexConnection = IO::Socket::INET->new( 
		#	PeerAddr	=> "81.169.141.129",	# ip vom server, auf dem der phex läuft: celeron=81.169.141.129
		#	PeerAddr	=> "85.214.39.76",		# ip aplha64.info
			PeerAddr	=> "127.0.0.1",			# für phex6 und später
		#	PeerPort	=> 3381,				# port vom phex server->org: 3381
			PeerPort	=> 3383,				# phex5.1 benutzt phexserverport 3383
			Proto		=> 'tcp',
			Timeout		=> $TIMEOUT ) or die "PhexProxy::IO->CreatePhexConnection(): Can't connect to TCP Socket for CLIENT SOCKET->Phex: Phex DOWN? $!\n";
# old:	
#	$PhexConnection->autoflush(1) if (defined($PhexConnection));
	$PhexConnection->blocking(0) if (defined($PhexConnection));

	$self->readSocket($PhexConnection);			# empfange die "hi" message; remove diesen eintrag, wenn keine hi message mehr vom server gesendet werden
	return $PhexConnection;

}; # sub CreateMutellaSocket(){}

# an welchem port soll ich auf handy anfragen lauschen ?
sub CreateProxySocket(){

	my $self	= shift;
	my $port	= shift || 3382;
	my $socket	= IO::Socket::INET->new(
					LocalPort	=> $port,
					#LocalPort	=> "localhost",	# 85.214.39.76 = ip vom alpha
					Proto		=> 'tcp',
					Listen		=> SOMAXCONN,
					Reuse		=> 1,
				) or die "PhexProxy::IO->CreateProxySocket($port): Can't create listen socket: $!\n";

# new:	
#	$socket->autoflush(1) if (defined($socket));
#	$socket->blocking(0) if (defined($socket));

	return $socket;

}; # sub CreateProxySocket(){}


# Handy <-> Paris Distributed ?
sub CreateHandyDistributedSocket(){

	my $self	= shift;
	my $port	= shift || die;
	my $socket	= IO::Socket::INET->new(
					LocalPort	=> $port,
					Proto		=> 'tcp',
					Listen		=> SOMAXCONN,
					Reuse		=> 1,
				) or warn "PhexProxy::IO->CreateHandyDistributedSocket($port): Can't create listen socket: $!\n";
		#	PeerAddr	=> "87.106.63.182",		# ip aplha64.info
		#	PeerPort	=> $port,				# phex5.1 benutzt phexserverport 3383
		#	Proto		=> 'tcp',
		#	Timeout		=> 150 ) 
		#	or die "PhexProxy::IO->CreateHandyDistributedSocket(): Can't create listen socket: $!";
	
#	$socket->autoflush(1) if (defined($socket));
#	$socket->blocking(0) if (defined($socket));

	return $socket;

}; # sub CreateHandyDistributedSocket(){


# Paris Distributed <-> Paris Programm ?
sub CreateSocketToParis(){

	my $self	= shift;
	my $host	= shift;
	my $port	= shift || 3385;

	my $socket	= IO::Socket::INET->new(
					PeerAddr	=> $host,			# für phex6 und später
					PeerPort	=> $port,			# phex5.1 benutzt phexserverport 3383
					Proto		=> 'tcp',
					Timeout		=> 3
			) or warn "PhexProxy::IO->CreateSocketToParis($host): Can't create listen socket: $!\n";
						
#	$socket->autoflush(1) if (defined($socket));
	$socket->blocking(0) if (defined($socket));

	return $socket;

}; # sub CreateSocketToParis(){


sub readRandomBytes() {
	
	srand();

	my $self   = shift;
	my $length = shift || int(rand(8096))+1;
	my $result;

	if (-r RANDOM_DEVICE && open(RAND,RANDOM_DEVICE)) {
		read(RAND,$result,$length);
		close RAND;
	} else {
		use PhexProxy::CryptoLibrary;
		return PhexProxy::CryptoLibrary->SimpleURandom( $length );	# $length ist die länge des seeds
	};
	
	return $result;

}; # sub readRandomBytes {}


sub ReadFileIntoArray(){

	my $self = shift;
	my $File = shift || warn "PhexProxy::IO->ReadFileIntoArray(): Error Nof File given for reading: $!\n";

	my @content = ();
	open( RH, "<$File");
		flock(RH, 2);
		@content = <RH>;
	close RH;

	return \@content;

}; # sub ReadFileIntoArray(){}


sub ReadFileIntoScalar(){

	my $self = shift;
	my $File = shift || return -1;

	my $FileContent;
	open(FILE, "<$File" ) or sub { warn "PhexProxy::IO->ReadFileIntoScalar(): IO ERROR: $!\n"; return -1; };
		flock(FILE, 2);
		{ 	local $/ = undef;			# Read entire file at once
			$FileContent = <FILE>;   # Return file as one single `line'
        };  
	close FILE;

	return \$FileContent;

}; # sub ReadFileIntoScalar(){}


sub WriteFile(){

#	my $URandom			= PhexProxy::CryptoLibrary->URandom( rand(100) );
#	my $URandomMD5		= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
#	my $RandStringPart	= time() . $URandomMD5;

	my $self			= shift;
	my $File			= shift || warn "PhexProxy::IO->WriteFile(): NO FILE FOR WRITING\n";
	my $refContent		= shift;

	open(FILE, ">$File") or warn "PhexProxy::IO->WriteFile(): Open Error: $!\n";
		binmode(FILE);
		flock(FILE, 2);
		if ( ref($refContent) eq 'ARRAY' ) {

			for ( my $i=0; $i<=$#{$refContent}; $i++ ) {
				print FILE $refContent->[$i];
			}; # for ( my $i=0; ... 

		} elsif ( ref($refContent) eq 'HASH' ) {

			my $keys = keys( %{$refContent} );
			for ( my $i=0; $i<=$keys; $i++ ) {
				print FILE $refContent->{$i};
			}; # for ( my $i=0; ...	

		} elsif ( ref($refContent) eq 'SCALAR' ) {
			print FILE ${$refContent};

		} elsif ( ref($refContent) eq '' ) {	# normaler scalar senden
			print FILE $refContent;

		} else {

			# code oder glob ref
			warn "PhexProxy::IO->WriteFile(): CODE or GLOB Ref - not supported\n";
			close FILE;
			return -1;

		}; # if ( ref($refContent) eq 'ARRAY' ) {

	close FILE;

	return $File;

}; # sub WriteFile(){}


return 1;