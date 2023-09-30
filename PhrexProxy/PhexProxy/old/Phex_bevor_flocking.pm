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
use PhexProxy::IO;
use strict;

use Data::Dumper;
# use warnings;

my $VERSION							= '0.6 - 3.55 Uhr - 26.1.2008';

my $MaxRetryOnFailedIORead			= 2;		# maximal sooft nochmal versuchen den Server neu anzufragen nach ergebnissen
my $MaxRetryOnFailedIOSleep			= 1;		# zwischen den abholvorgaengen von einem server zufällig bis zu X sec schlafen
my $PhexServerTimeout				= 10;		# Timeout für einen Socket-open Request zum Phex Server Socket
my $PhexServerResultMinStringLength = 30;		# Minimal Länge eines ungeparsten Ergebnis Stringes vom Phex

my $SIZEFILTER						= '/server/phexproxy/filter/sizefilter.dat';			# dieser String steht auch nochtmal in Filter.pm und muss dort auch angepasst werden
my $SizeFilerContentArrayRef		= PhexProxy::IO->ReadFileIntoArray( $SIZEFILTER );

use constant TOKENPATH				=> "/server/phexproxy/PhexSources/phex_3.0.2.100_20071909/lib/token.conf";
use constant CRLF					=> "\r\n";

my $TIME							= PhexProxy::Time->new();

# für result() = 5 == 

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

	return $Token;

}; # sub readToken(){



sub GetMaxFileSizeInBytes(){

	###############
	#### GetMaxFileSizeInBytes(): Bestimme zu einem übergebenen String bestehend aus z.B "b,0" die maximale Dateigröße mit Hilfe der sizefilter.dat
	###############

	my $self			= shift;
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


sub find(){

	my $self					= shift;
	my $PhexServerIP			= shift;
	my $SearchQuery				= shift; 
	my $FileTyp					= shift;
	my $ClientID				= shift;
	my $Token					= shift || $self->readToken();
 
	my ( @WantedFileTypes )		= split(',', $FileTyp );
	my $WantedFileTypes;

	# warte maximal 2 sekunde bevor anfrage gesendet wird
	# select (undef, undef, undef, rand(2) );	

	# gib die Dateigröße in Bytes zurück oder im Fehlerfall gib 1024 * 1024 * 5=5MB als Standartgröße für Dateisuche zurück
	my $FileSizeLimitInBytes	= $self->{'FileTypMaxLengthBytes'}->{$WantedFileTypes[0]} || "5242880";	
	my $PhexSocket				= PhexProxy::IO->CreatePhexConnection( $PhexServerIP, $PhexServerTimeout );
	
	# todo: später hier gleich die passenden Werte für die dateigröße des entsprechenden types eingeben: 1024 * 1024 * 3 = 3145728
	PhexProxy::IO->writeSocket( $PhexSocket, "find $ClientID 0 $FileSizeLimitInBytes Any $Token $SearchQuery" );		# 1MB max filesize
	# PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );

	close($PhexSocket);
	
	return 1;

}; # sub find(){}


sub result(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $ClientID		= shift;
	my $Token			= shift || $self->readToken();

	my $PhexSocket		= PhexProxy::IO->CreatePhexConnection( $PhexServerIP, $PhexServerTimeout );
	my $Results;

	eval {
					
		local $SIG{'ALRM'} = sub { my $CurTime	= $TIME->MySQLDateTime(); printf STDOUT "[ $self -> readSocket() ] - WARNING: '$PhexServerIP' not serving results in $PhexServerTimeout seconds \n"; goto ALARMLABEL; };

		alarm ( $MaxRetryOnFailedIORead * $MaxRetryOnFailedIOSleep) + $PhexServerTimeout+2;	# alarm setzen für maximale anzahl an versuchen neu ergebnisse abzuholen mal der zeit die max zufällig ausgewürfelt werden kann plus Timeout+2
		
	#	my $al = ($MaxRetryOnFailedIORead * $MaxRetryOnFailedIOSleep) + ($PhexServerTimeout+2);
	#	print "Alarm Timeout is $al \n";

		for ( my $x=0; $x<=$MaxRetryOnFailedIORead; $x++) {
			
			last if ( length($Results) > $PhexServerResultMinStringLength );

			# warte maximal 0.6 sekunde bevor anfrage gesendet wird
			# select (undef, undef, undef, rand(0.6) );	

			PhexProxy::IO->writeSocket( $PhexSocket, "result $ClientID $Token" );
			PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
			
			$Results = PhexProxy::IO->readSocket( $PhexSocket );
			close($PhexSocket);
				
			if ( length($Results) > $PhexServerResultMinStringLength ) {
	
			#	print "result($PhexServerIP) : " . length($Results);
			#	print "\n";
				return $Results;

			} else {
		
				my $RandSleepTime	= rand($MaxRetryOnFailedIOSleep);
				select (undef, undef, undef, $RandSleepTime );	# warte bis max X sec bis die for schleife greift und nochmal der gleiche server nach ergebnissen angefragt werden soll

			}; # if ( length($Results) > $PhexServerResultMinStringLength ) {
	
			ALARMLABEL:

		}; # for ( my $x=0; $x<=5; $x++) {

		alarm 0;

	}; # eval {

	close($PhexSocket);
	return $Results;
	
}; # sub result(){


sub del(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $ClientID		= shift;
	my $Token			= shift || $self->readToken();
	
	my $PhexSocket		= PhexProxy::IO->CreatePhexConnection( $PhexServerIP, $PhexServerTimeout );
	PhexProxy::IO->writeSocket( $PhexSocket, "del $ClientID $Token" );
	PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
	
	close($PhexSocket);
	return 1;

}; # sub del(){}


sub status(){

	my $self			= shift;
	my $PhexServerIP	= shift;
	my $Token			= shift || $self->readToken();

	my $PhexSocket		= PhexProxy::IO->CreatePhexConnection( $PhexServerIP, $PhexServerTimeout );
	my $Results;

	eval {
					
		local $SIG{'ALRM'} = sub { my $CurTime	= $TIME->MySQLDateTime(); printf STDOUT "[ $self -> readSocket() ] - WARNING: '$PhexServerIP' not serving results in $PhexServerTimeout seconds \n"; goto ALARMLABEL; };

		alarm ( $MaxRetryOnFailedIORead * $MaxRetryOnFailedIOSleep) + ($PhexServerTimeout + 2) ;	# alarm setzen für maximale anzahl an versuchen neu ergebnisse abzuholen mal der zeit die max zufällig ausgewürfelt werden kann plus Timeout+2
		
		for ( my $x=0; $x<=$MaxRetryOnFailedIORead; $x++) {
			
			last if ( length($Results) > 6 );
			PhexProxy::IO->writeSocket( $PhexSocket, "status $Token" );
			PhexProxy::IO->writeSocket( $PhexSocket, "\r\n" );
			$Results	= PhexProxy::IO->readSocket( $PhexSocket );
			close($PhexSocket);
			
			if ( length($Results) > 6 ) {
				
				return $Results;

			}; # if ( length($Results) > $PhexServerResultMinStringLength ) {

			my $RandSleepTime	= rand($MaxRetryOnFailedIOSleep);
			select (undef, undef, undef, $RandSleepTime );	# warte bis max X sec bis die for schleife greift und nochmal der gleiche server nach ergebnissen angefragt werden soll

			ALARMLABEL:

		}; # for ( my $x=0; $x<=5; $x++) {

		alarm 0;

	}; # eval {

	close($PhexSocket);
	return $Results;
	
}; # sub status(){

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