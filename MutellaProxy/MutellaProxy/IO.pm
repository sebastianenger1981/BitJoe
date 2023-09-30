#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		IO spezifisches Modul
##### Todo:			
########################################

package MutellaProxy::IO;

my $VERSION = '0.19.1';

# use IO::Socket::SSL qw(debug4);

use MutellaProxy::CryptoLibrary;
use MutellaProxy::CheckSum;
use IO::Socket;
use strict;


use constant UNIXSOCKET		=> '/server/mutella/socket';
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

	while (sysread($socket , $IO, 1) == 1) {
		
		if ( $StreamCount == MAXINCBYTES ) {
			# breche ab, wenn mehr als MAXINCBYTES Bytes in einer Session an den Server gesendet wurden
			print "WARNING: Possible Denial of Service Attack - more than " .MAXINCBYTES. " Bytes of incoming Traffic!\n";
			$STREAM = '';
			exit(0);
		};
		
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
		warn "MutellaProxy::IO->writeSocket(): CODE or GLOB Ref - not supported\n";
		return -1;

	}; # if
	
	return 1;	# always false

}; # sub sub writeSocket(){}


sub CreateMutellaSocket(){
	
	my $self	= shift;
	my $TIMEOUT = shift || 150;

	my $MutellaSocket;

	RESTART:

	$@ ='';
	undef $@;

	eval {
		$MutellaSocket = IO::Socket::UNIX->new( 
			Peer => UNIXSOCKET,
			Type => SOCK_STREAM,
			Timeout => $TIMEOUT ) or warn "MutellaProxy::IO->CreateMutellaSocket(): Can't connect to Unix Socket for CLIENT SOCKET->MUTELLA: MUTELLA DOWN? $!\n";
	};

	if ( $@ ) {
		select(undef, undef, undef, 0.1 );
		goto RESTART;
	};

	$MutellaSocket->autoflush(1) if (defined($MutellaSocket));
	$MutellaSocket->blocking(0) if (defined($MutellaSocket));

	return $MutellaSocket;

}; # sub CreateMutellaSocket(){}


sub CreateProxySocket(){

	my $self	= shift;
	my $port	= shift || 3381;
	my $socket;

#	RESTART:
#
#	$@ ='';
#	undef $@;
#
	eval {
		$socket	= IO::Socket::INET->new(
			LocalPort				=> $port,
			Proto					=> 'tcp',
			Listen					=> SOMAXCONN,
			Reuse					=> 1,
		) or die "MutellaProxy::IO->CreateProxySocket(): Can't create listen socket: $!";
	};

	if ( $@ ) {
	#	select(undef, undef, undef, 0.1 );
	#	goto RESTART;
		print "ERROR: $@\n";
		exit;
	};

	return $socket;

}; # sub CreateProxySocket(){}


sub readRandomBytes() {
	
	srand();

	my $self   = shift;
	my $length = shift || int(rand(8096))+1;
	my $result;

	if (-r RANDOM_DEVICE && open(RAND,RANDOM_DEVICE)) {
		read(RAND,$result,$length);
		close RAND;
	} else {
		use MutellaProxy::CryptoLibrary;
		return MutellaProxy::CryptoLibrary->SimpleURandom( $length );	# $length ist die länge des seeds
	};
	
	return $result;

}; # sub readRandomBytes {}


sub ReadFileIntoArray(){

	my $self = shift;
	my $File = shift || warn "MutellaProxy::IO->ReadFileIntoArray(): Error Nof File given for reading: $!\n";

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
	open(FILE, "<$File" ) or sub { warn "MutellaProxy::IO->ReadFileIntoScalar(): IO ERROR: $!\n"; return -1; };
		flock(FILE, 2);
		{ 	local $/ = undef;			# Read entire file at once
			$FileContent = <FILE>;   # Return file as one single `line'
        };  
	close FILE;

	return \$FileContent;

}; # sub ReadFileIntoScalar(){}


sub WriteFile(){

	my $URandom			= MutellaProxy::CryptoLibrary->URandom( rand(100) );
	my $URandomMD5		= MutellaProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandStringPart	= time() . $URandomMD5;

	my $self		= shift;
	my $File		= shift || warn "MutellaProxy::IO->WriteFile(): NO FILE FOR WRITING\n";
	my $refContent	= shift;

	rename "$File" => "$File.$RandStringPart.txt";

	open(FILE, ">$File") or warn "MutellaProxy::IO->WriteFile(): Open Error: $!\n";
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
			warn "MutellaProxy::IO->WriteFile(): CODE or GLOB Ref - not supported\n";
			close FILE;
			return -1;

		}; # if ( ref($refContent) eq 'ARRAY' ) {

	close FILE;

	rename "$File.$RandStringPart.txt" => $File;
	return $File;

}; # sub WriteFile(){}


return 1;