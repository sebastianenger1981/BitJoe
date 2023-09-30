#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		IO spezifisches Modul
##### Todo:			
########################################

package PhexProxy::IOSSL;

my $VERSION = '0.19.1';

use IO::Socket::SSL;
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

	if ( ref($refContent) eq 'ARRAY' ) {
		for ( my $i=0; $i<=$#{$refContent}; $i++ ) {
			syswrite($socket, $refContent->[$i], length($refContent->[$i]) );	
		}; # for ( my $i=0; ... 
		return 1;
	} elsif ( ref($refContent) eq 'HASH' ) {
		my $keys = keys( %{$refContent} );
		for ( my $i=0; $i<=$keys; $i++ ) {
			syswrite($socket, $refContent->{$i}, length($refContent->{$i}) );
		}; # for ( my $i=0; ...	
		return 1;
	} elsif ( ref($refContent) eq 'SCALAR' ) {
		syswrite($socket, ${$refContent}, length(${$refContent}) );
		return 1;
	} elsif ( ref($refContent) eq '' ) {	# normaler scalar senden
		syswrite($socket, $refContent, length($refContent) );
		return 1;	
	} else {
		# code oder glob ref
		warn "PhexProxy::IO->writeSocket(): CODE or GLOB Ref - not supported\n";
		return -1;
	}; # if
	
	return -1;	# always false

}; # sub sub writeSocket(){}


sub CreatePhexConnection(){
	
	my $self	= shift;
	my $TIMEOUT = shift || 150;

	my $PhexConnection = IO::Socket::INET->new( 
			PeerAddr	=> "84.178.222.230",	# ip vom alpha
			PeerPort	=> 3381,			# port vom phex serverproxy->todo: change
			Proto		=> 'tcp',
			Timeout		=> $TIMEOUT ) or warn "PhexProxy::IO->CreatePhexConnection(): Can't connect to TCP Socket for CLIENT SOCKET->Phex: Phex DOWN? $!\n";

	$PhexConnection->autoflush(1) if (defined($PhexConnection));
	$PhexConnection->blocking(0) if (defined($PhexConnection));

	$self->readSocket($PhexConnection);

	return $PhexConnection;

}; # sub CreateMutellaSocket(){}


sub CreateProxySocket(){

	my $socket;

	# $socket	= IO::Socket::INET->new(
	$socket	= IO::Socket::SSL->new(

	LocalPort				=> 3382,
	Proto					=> 'tcp',
	Listen					=> SOMAXCONN,
	Reuse					=> 1,
	SSL_cipher_list			=> 'ALL:HIGH:MEDIUM:IDEA:3DES:LOW:DES:MD5',
	SSL_key_file			=> '/server/mutella/certs/ca.key',
	SSL_cert_file			=> '/server/mutella/certs/ca.crt',	# server.csr
	# SSL_key					=> 'WELTMEISTER',
	SSL_use_cert			=> 0,
	SSL_verify_mode			=> 0x00,
	SSL_passwd_cb			=> sub {return "test"},
	SSL_ca_path				=> '/server/mutella/certs',
	SSL_session_cache_size	=> '238096',
#		certificate.pem
	) or die "PhexProxy::IO->CreateProxySocket(): Can't create listen socket: $!";

#	The default (0x00) does no authentication. You may combine 0x01 (verify peer), 0x02 (fail verification if no peer certificate exists; ignored for clients), and 0x04 (verify client once) to change the default.

	my ($subject_name, $issuer_name, $cipher);
	if( ref($socket) eq "IO::Socket::SSL") {
		$subject_name = $socket->peer_certificate("subject");
		$issuer_name = $socket->peer_certificate("issuer");
		$cipher = $socket->get_cipher();
	};

	warn "cipher: $cipher.\n", "server cert:\n", 
		"\t '$subject_name' \n\t '$issuer_name'.\n\n";

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
	my $File = shift || warn "PhexProxy::IO->ReadFileIntoArray(): Error Nof File given for reading: $!\n";

	my $FileContent;
	open(TOCRYPT, "<$File" ) or sub { warn "PhexProxy::IO->ReadFileIntoScalar(): IO ERROR: $!\n"; return -1; };
		flock(TOCRYPT, 2);
		{ 	local $/ = undef;			# Read entire file at once
			$FileContent = <TOCRYPT>;   # Return file as one single `line'
        };  
	close TOCRYPT;

	return \$FileContent;

}; # sub ReadFileIntoScalar(){}


sub WriteFile(){

	my $self		= shift;
	my $File		= shift || warn "PhexProxy::IO->WriteFile(): NO FILE FOR WRITING\n";
	my $refContent	= shift;

	srand();
	my $Random	= int(rand(10000))+1;
	rename "$File" => "$File.old.$Random.txt";

	open(FILE, ">$File") or warn "PhexProxy::IO->WriteFile(): Open Error: $!\n";
		flock(FILE, 2);
		if ( ref($refContent) eq 'ARRAY' ) {
			for ( my $i=0; $i<=$#{$refContent}; $i++ ) {
				print FILE $refContent->[$i];
			}; # for ( my $i=0; ... 
			close FILE;
			return 1;
		} elsif ( ref($refContent) eq 'HASH' ) {
			my $keys = keys( %{$refContent} );
			for ( my $i=0; $i<=$keys; $i++ ) {
				print FILE $refContent->{$i};
			}; # for ( my $i=0; ...	
			close FILE;
			return 1;
		} elsif ( ref($refContent) eq 'SCALAR' ) {
			print FILE ${$refContent};
			close FILE;
			return 1;
		} elsif ( ref($refContent) eq '' ) {	# normaler scalar senden
			print FILE $refContent;
			close FILE;
			return 1;	
		} else {
			# code oder glob ref
			warn "PhexProxy::IO->WriteFile(): CODE or GLOB Ref - not supported\n";
			close FILE;
			return -1;
		}; # if

	close FILE;

	return 1;

}; # sub WriteFile(){}


return 1;