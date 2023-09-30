#!/usr/bin/perl -I/root/.mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Cache die Results
##### Todo:			 readCache(){}
########################################


# cache für cache.bild:mp3:java eine separate datei anlegen und beim cacheRead auch nur aus dieser datei lesen


package MutellaProxy::ResultCache;

use MutellaProxy::IO;

my $VERSION		= '0.18.1';
my $CACHEPATH	= '/root/.mutella/CACHE';

use strict;


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub readCache(){

	my $self		= shift;
	my $from		= shift;
	my $to			= shift;
	my $CacheType	= shift;

	my $SendString;

	my $CONTENT = MutellaProxy::IO->ReadFileIntoArray( "$CACHEPATH/$CacheType" );
	
	for (my $i = $from; $i <= $to ; $i++) {
		$CONTENT->[$i] =~ s/\t\t/\r\n/g;
		my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $CONTENT->[$i] );
		if ( ( length($PEERHOST) != 0 ) && ( length($SIZE) != 0 ) && ( length($SHA1) != 0 ) ) {
			$SendString .= $RANK . "\r\n" . $SIZE . "\r\n" . $SHA1 . "\r\n" . $PEERHOST . "\r\n";
		}; # if ( ( length($PH) != 0 ) &&...
	}; # for (my $i = $from; $i <= $to ; $i++) {}
	
	return $SendString;

}; # sub readCache(){}


sub writeCache(){

	my $self		= shift;
	my $CacheArrRef = shift;
	my $ClientID	= shift;
	my $Search		= shift;

	$Search =~ s/\s/\+/g;
	$Search = lc($Search);	# wir wollen nur kleinbuchstaben beim cachen!!

		
	open(CACHE, ">$CACHEPATH/$ClientID") or sub { warn "MutellaProxy::ResultCache->writeCache(): IO ERROR: $!\n"; return -1; };
	flock (CACHE, 2);
		for ( my $i = 0; $i<=$#{$CacheArrRef}; $i++) {
			$CacheArrRef->[$i] =~ s/\r\n/\t\t/g;
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $CacheArrRef->[$i] );
			chop($SHA1) if ( length($SHA1) == 33 );	# fix für Sort::Array->Sort_Table();
			print CACHE "$RANK###$PEERHOST###$SIZE###$SHA1\n";					
		};
	close CACHE;

	open(CACHE, ">$CACHEPATH/$Search") or sub { warn "MutellaProxy::ResultCache->writeCache(): IO ERROR: $!\n"; return -1; };
	flock (CACHE, 2);
		for ( my $i = 0; $i<=$#{$CacheArrRef}; $i++) {
			$CacheArrRef->[$i] =~ s/\r\n/\t\t/g;
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $CacheArrRef->[$i] );
			chop($SHA1) if ( length($SHA1) == 33 );	# fix für Sort::Array->Sort_Table();
			print CACHE "$RANK###$PEERHOST###$SIZE###$SHA1\n";					
		};
	close CACHE;

		
	return 1;

}; # sub writeCache(){}


return 1;