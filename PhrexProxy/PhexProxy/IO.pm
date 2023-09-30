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

# use IO::Socket::SSL qw(debug4);

use PhexProxy::CryptoLibrary;
use PhexProxy::CheckSum;
#use PhexProxy::Mail;
#use PhexProxy::SMS;
#use PhexProxy::ICQ;
use IO::Socket;
use strict;
no strict 'subs';

#my $ICQ							= PhexProxy::ICQ->new();
#my $SMS							= PhexProxy::SMS->new();
my $TIME						= PhexProxy::Time->new();
#my $MAIL						= PhexProxy::Mail->new();

use constant RANDOM_DEVICE		=> '/dev/urandom';
use constant MAXINCBYTES		=> 50 * 1024 * 1024;	# 10 mbytes

my $MaxCreateSocketTry			= 1;	# Anzahl Versuche für Aufbau eines Sockets
my $MaxCreateSocketRandSleep	= 1;	# Anzahl max Sekunden Wartezeit zwischen Aufbau des Sockets


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub readSocket() {
	
	my $self	= shift;
	my $socket	= shift;

	binmode($socket);

	# old working
	my $STREAM = <$socket>;
	return $STREAM;

}; # sub readSocket(){}


sub writeSocket(){
	
	my $self		= shift;
	my $socket		= shift;
	my $refContent	= shift;
	my $delay		= shift || 0;
	
#	eval { 
#
#		# select(undef, undef, undef, $delay );
#		binmode($socket);
#		
#	}; # eval { 
#
#	### print "ERROR : '$@' \n";


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


sub CreatePhexConnectionWithPort(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $ParisPort		= shift;
	my $TIMEOUT			= shift || 5;

	my $PhexConnection	= IO::Socket::INET->new( 
				PeerAddr	=> $PhexServerIP,		# für phex6 und später
				PeerPort	=> $ParisPort,			# seit phex5.1 benutzt phexserverport 3383
				Proto		=> 'tcp',
				Timeout		=> $TIMEOUT,
				Reuse		=> 1 ) or warn "PhexProxy::IO->CreatePhexConnectionWithPort(): Can't connect to TCP Socket $PhexServerIP|$ParisPort for CLIENT SOCKET->Phex: Phex DOWN? $!\n";

	if ( ref($PhexConnection) eq "IO::Socket::INET" ) {

			# empfange die "hi" message; remove diesen eintrag, wenn keine hi message mehr vom server gesendet werden
			$self->readSocket($PhexConnection);	

	} else {

		my $CurTime		= $TIME->MySQLDateTime();
		printf STDOUT "[ $self -> CreatePhexConnectionWithPort() ] - WARNING:  Try to create Socket to $PhexServerIP|$ParisPort - cannot create socket\n";

	###	$ICQ->SendICQMessage("CreatePhexConnectionWithPort() to $PhexServerIP|$ParisPort failed");

	}; # if ( ref($PhexConnection) eq "IO::Socket::INET" ) {

	$PhexConnection->autoflush(0);
	return $PhexConnection;

}; # sub CreatePhexConnectionWithPort(){


# Handy <-> Paris Distributed ?
sub CreateHandyDistributedSocket(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $port			= shift || 7773;

	my $socket			= IO::Socket::INET->new(
				LocalPort	=> $port,
				Proto		=> 'tcp',
				Listen		=> SOMAXCONN,
				Reuse		=> 1 ) or warn "PhexProxy::IO->CreateHandyDistributedSocket($port): Can't create listen socket: $!\n";

	if ( ref($socket) ne "IO::Socket::INET" ) {

	###	$ICQ->SendICQMessage("FrontendSocket for BitJoe Paris is down");
	#	$MAIL->SendNoHandyClientSocketMail( 3383 );
	#	$SMS->SendHandyClientSocketDownSMS($PhexServerIP);

	}; # if ( ref($socket) ne "IO::Socket::INET" ) {

	return $socket;

}; # sub CreateHandyDistributedSocket(){


sub readRandomBytes(){
	
	srand();

	my $self   = shift;
	my $length = shift || int(rand(8096))+1;
	my $result;

	if (-r RANDOM_DEVICE && open(RAND,RANDOM_DEVICE)) {
		read(RAND,$result,$length);
		close RAND;
	} else {
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


sub readSocketBM() {

	my $self	= shift;
	my $socket	= shift;
	
	my $IO;
	my $STREAM;
	my $StreamCount = 0;

	while (sysread($socket , $IO, 1) == 1) {
				
		$STREAM = $STREAM . $IO;
		$StreamCount++;

    }; # while (sysread($socket , $IO, 1) == 1) {}

	return $STREAM;

}; # sub _readSocketBM() {


return 1;