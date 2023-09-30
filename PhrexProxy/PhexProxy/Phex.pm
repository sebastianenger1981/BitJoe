#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		Mutella spezifische Funktionen
##### Todo:			
########################################

package PhexProxy::Phex;

use PhexProxy::Time;
use Fcntl ':flock';
#use PhexProxy::SMS;
use PhexProxy::IO;
use strict;

# use Data::Dumper;

my $VERSION							= '0.7 - 3.55 Uhr - 14.2.2008';

my $AlarmTimeout					= 6;
my $PhexServerTimeout				= 4;		# Timeout für einen Socket-open Request zum Phex Server Socket

# my $FLOCKINGFILE					= "/server/phexproxy/tmp/flocking_$$.flock";			# eventuell später mehrere flock dateien für 
# my $FLOCKINGFILE_DEL				= "/server/phexproxy/tmp/flocking_DEL_$$.flock";			# eventuell später mehrere flock dateien für - 20.2.2008: diese datei nicht verwenden
my $SIZEFILTER						= "/server/phexproxy/filter/sizefilter.dat";			# dieser String steht auch nochtmal in Filter.pm und muss dort auch angepasst werden
my $SizeFilerContentArrayRef		= PhexProxy::IO->ReadFileIntoArray( $SIZEFILTER );

use constant TOKENPATH				=> "/server/phexproxy/PhexProxy/token.conf";
use constant CRLF					=> "\r\n";

my $TIME							= PhexProxy::Time->new();
#my $SMS								= PhexProxy::SMS->new();


################
### Flocking Algorithmus
###
### 1. öffne $FLOCKINGFILE als WH
### 2. flocke exclusive WH
### 3. Socket öffnen
### 4. Befehl über Socket schreiben
### 5. Socket schließen
### 6. X MS warten mittels  select (undef, undef, undef, rand(0.2) );	
### 7.) flock lösen
### 8. Datei schließen
###
################


sub new(){
	
	my $self							= bless {}, shift;
	$self->{'FileTypMaxLengthBytes'}	= $self->GetMaxFileSizeInBytes();
	return $self;
		
}; # new()



sub readToken(){
	
	my $self				= shift;

	my $FileContent			= PhexProxy::IO->ReadFileIntoScalar( TOKENPATH );
	my ( undef, $Token )	= split('token=', ${$FileContent} );
	
	chomp($Token);
	$Token =~ s/\s+$//;	# rtrim

	die "PhexProxy::Phex->readToken(): no token given!" if ( length($Token) <= 0 ); 
	return $Token;

}; # sub readToken(){


sub find(){

	my $self					= shift;
	my $PhexServerIP			= shift;
	my $ParisPort				= shift;
	my $SearchQuery				= shift; 
	my $Filetyp					= shift;
	my $ClientID				= shift;
	my $Token					= shift || $self->readToken();
	my $PhexStatus				= "";

	# gib die Dateigröße in Bytes zurück oder im Fehlerfall gib 1024 * 1024 * 5=5MB als Standartgröße für Dateisuche zurück
	my $FileSizeHashRef			= $self->{'FileTypMaxLengthBytes'};	
	my $FileSizeLimitInBytes	= $FileSizeHashRef->{$Filetyp} || "5242880";	
	
	eval {

		local $SIG{'ALRM'} = sub { die "TIMEOUT"; };
		alarm $AlarmTimeout;
		
		my $PhexSocket	= PhexProxy::IO->CreatePhexConnectionWithPort( $PhexServerIP, $ParisPort, $PhexServerTimeout );
		return -1 if ( ref($PhexSocket) ne "IO::Socket::INET");

		PhexProxy::IO->writeSocket( $PhexSocket, "find $ClientID 0 $FileSizeLimitInBytes Any $Token $SearchQuery" );

#		
#
#		# PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
#		# $PhexStatus = PhexProxy::IO->readSocket( $PhexSocket );
#		# print "[$PhexStatus] \n";

		close($PhexSocket);	
		alarm 0;

	}; # eval {

	return;

}; # sub find(){}


sub result(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $ParisPort		= shift;
	my $ClientID		= shift;
	my $Token			= shift || $self->readToken();

	my $PhexSocket;
	my $Results;
	#	$@					= "";	# Reset Error Keeping Var 

	eval {

		local $SIG{'ALRM'} = sub { die "ERROR"; };
		alarm $AlarmTimeout;

		$PhexSocket	= PhexProxy::IO->CreatePhexConnectionWithPort( $PhexServerIP, $ParisPort, $PhexServerTimeout );
		return if ( ref($PhexSocket) ne "IO::Socket::INET");
		PhexProxy::IO->writeSocket( $PhexSocket, "result $ClientID $Token" );
		PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
		$Results = PhexProxy::IO->readSocket( $PhexSocket );
		close($PhexSocket);
		
		alarm 0;

	}; # eval {

#	return if ( length($@) > 0 );
	return $Results;
	
}; # sub result(){


# $PHEX->del( $ParisHost, $ClientID, $Token );


sub del(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $ClientID		= shift;
	my $Token			= shift || $self->readToken();
	
	my $PhexSocket;
	$@					= "";	# Reset Error Keeping Var 

	eval {

		local $SIG{'ALRM'} = sub { die "ERROR"; };
		alarm $AlarmTimeout;

		$PhexSocket	= PhexProxy::IO->CreatePhexConnection( $PhexServerIP, $PhexServerTimeout );
		return -1 if ( ref($PhexSocket) ne "IO::Socket::INET");
		PhexProxy::IO->writeSocket( $PhexSocket, "del $ClientID $Token" );
	#	PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
		close($PhexSocket);

		alarm 0;

	}; # eval {

	return 1 if ( length($@) == 0 );
	return -1 if ( length($@) > 0 );

}; # sub del(){}


sub status(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $Token			= shift || $self->readToken();
	
	my $Results;
	my $PhexSocket;
	$@					= "";	# Reset Error Keeping Var 
	
	eval {

		local $SIG{'ALRM'} = sub { die "ERROR"; };
		alarm $AlarmTimeout;

		$PhexSocket		= PhexProxy::IO->CreatePhexConnection( $PhexServerIP, $PhexServerTimeout );
		return -1 if ( ref($PhexSocket) ne "IO::Socket::INET");
		PhexProxy::IO->writeSocket( $PhexSocket, "status $Token" );
		# PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
		$Results	= PhexProxy::IO->readSocket( $PhexSocket );
		close($PhexSocket);

		alarm 0;

	}; # eval {

	return if ( length($@) > 0 );
	return $Results;

}; # sub status(){



sub GetMaxFileSizeInBytes(){

	###############
	#### GetMaxFileSizeInBytes(): Bestimme zu einem übergebenen String bestehend aus z.B "b,0" die maximale Dateigröße mit Hilfe der sizefilter.dat
	###############

	my $self			= shift;
	my $Filetyp			= shift;
	my $ArrayCount		= @{$SizeFilerContentArrayRef};
	my $FileTypHashRef	= {};
	my $multiply;

	# foreach my $entry ( @{$SizeFilerContentArrayRef} ) {
	for ( my $i=0; $i<=$ArrayCount; $i++ ) {					# for schleife schneller als foreach !
	
		my $entry = $SizeFilerContentArrayRef->[$i]; 
		$entry =~ s/\s+$//;	# rtrim()

		next if ( $entry =~ /^#/ );
		next if ( length($entry) <= 13 );

		my ( $Desc, $sizetmp )		= split('=', $entry );
		my ( $Size, $SizeSuffix )	= split(/(B|K|M|G)/i, $sizetmp );
		
		if ( $SizeSuffix eq 'B' ){
			$multiply = 1;
		} elsif ( $SizeSuffix eq 'K' ){
			$multiply = 1024;
		} elsif ( $SizeSuffix eq 'M' ){
			$multiply = 1024 * 1024;
		} elsif ( $SizeSuffix eq 'G' ){
			$multiply = 1024 * 1024 * 1024;
		} elsif ( $SizeSuffix eq 'T' ){
			$multiply = 1024 * 1024 * 1024 * 1024;
		}; # if ( $SizeSuffix eq 'B' ){}

		if ( $Desc =~ /FORMATBILD/i ) {
			$FileTypHashRef->{ 'b' } = $Size * $multiply;	
		} elsif ( $Desc =~ /FORMATMP3/i ) {
			$FileTypHashRef->{ 'm' } = $Size * $multiply;	
		} elsif ( $Desc =~ /FORMATRING/i ) {
			$FileTypHashRef->{ 'k' } = $Size * $multiply;	
		} elsif ( $Desc =~ /FORMATVIDEO/i ) {
			$FileTypHashRef->{ 'v' } = $Size * $multiply;	
		} elsif ( $Desc =~ /FORMATJAVA/i ) {
			$FileTypHashRef->{ 'j' } = $Size * $multiply;	
		} elsif ( $Desc =~ /FORMATDOC/i ) {
			$FileTypHashRef->{ 'd' } = $Size * $multiply;	
		}; # if ( $Desc =~ /FORMATBILD/i ) {

	}; # foreach my $entry ( @{$SizeFilerContentArrayRef} ) {

	#	print "FileSizeMax: " . $FileTypHashRef->{ 'b' } . " Bytes\n";

	# gib HashRefWert des Size zum zugehörigen FileTyp zurück oder im Fehlerfall gib 1024 * 1024 * 5=5MB als Standartgröße für Dateisuche zurück
	return $FileTypHashRef;

}; # sub GetMaxFileSizeInBytes(){




	#FORMATBILD=600K
	#FORMATMP3=16M
	#FORMATRING=800K
	#FORMATVIDEO=30M
	#FORMATJAVA=850K
	#FORMATDOC=900K

#	if ( $WantedFileTypes[0] eq 'b' ) {			#	$FileType = 'FORMATBILD';
#	} elsif ( $WantedFileTypes[0] eq 'm' ) {	#	$FileType = 'FORMATMP3';
#	} elsif ( $WantedFileTypes[0] eq 'k' ) {	#	$FileType = 'FORMATRING';
#	} elsif ( $WantedFileTypes[0] eq 'v' ) {	#	$FileType = 'FORMATVIDEO';
#	} elsif ( $WantedFileTypes[0] eq 'j' ) {	#	$FileType = 'FORMATJAVA';
#	} elsif ( $WantedFileTypes[0] eq 'd' ) {	#	$FileType = 'FORMATDOC';
#	};

#	my %disp_table = ( something => \&do_something );
#	$disp_table{'something'}->();


return 1;