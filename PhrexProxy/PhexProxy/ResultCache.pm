#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Cache die Results
##### Todo:			 readCache(){}
########################################


# cache für cache.bild:mp3:java eine separate datei anlegen und beim cacheRead auch nur aus dieser datei lesen


package PhexProxy::ResultCache;

use PhexProxy::IO;
use IO::Handle;
use strict;


my $VERSION			= '0.18.1';
my $CACHEPATH		= '/server/phexproxy/cache';
my $CACHEVALIDTIME	= 168;	# in hours = 7 tage

sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub readCache(){

	my $self			= shift;
	my $ReadCacheFrom	= shift || 0;
	my $ReadCacheTo		= shift || 10;
	my $SearchQuery		= shift;
	my $FileTypeHashRef = shift;

	# my $KeyCount		= keys( %{$FileTypeHashRef} );
	# my $FileTyp		= $FileTypeHashRef->{$KeyCount};

	my $FileTyp			= $FileTypeHashRef->{ 1 };

	$SearchQuery		=~ s/\s/\+/g;
	$SearchQuery		= lc($SearchQuery);

	my $SendString		= '';
	my $CacheFile		= "$CACHEPATH/$SearchQuery.txt";
	
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = stat($CacheFile);	# $mtime ist last modified timestamp
	my $CacheValidTime		= ($mtime + $CACHEVALIDTIME * 3600);
	
	if ( $CacheValidTime >= time() ) {

		my $CONTENT	= PhexProxy::IO->ReadFileIntoArray( $CacheFile );
		

		# 	next if ( $peer !~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ );
		#	next if ( length($index) <= 0 ); next if ( length($filename) <= 0 ); next if ( length($SH) != 32 );  next if ( $PH eq '' || length($PH) <= 0 );
		#	next if (  $RANK == -3333 ); next if ( $PEERHOST == -3333 );  next if ( $SIZE == -3333 ); next if ( $SHA1 == -3333 ); 
		#	next if ( $RANK eq '' || length($RANK) <= 0 ); next if ( $SIZE eq '' || length($SIZE) <= 0 );  next if ( $SHA1 eq '' || length($SHA1) <= 0 ); next if ( $PEERHOST eq '' || length($PEERHOST) <= 0 );

		for ( my $i = $ReadCacheFrom; $i <= $ReadCacheTo ; $i++ ) {
			$CONTENT->[$i] =~ s/\t\t/\r\n/g;
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $CONTENT->[$i] );
			chop($SHA1) if ( length($SHA1) == 33 );	# fix für Sort::Array->Sort_Table();
			if ( $RANK != -3333 && $PEERHOST != -3333 && $SIZE != -3333 && $SHA1 != -3333 ) {
				if ( ( length($PEERHOST) != 0 ) && ( length($SIZE) != 0 ) && ( length($SHA1) != 0 ) ) {
					$SendString .= $RANK . "\r\n" . $SIZE . "\r\n" . $SHA1 . "\r\n" . $PEERHOST . "\r\n";
				}; # if ( ( length($PH) != 0 ) &&...
			}; # if ( $RANK != -3333
		}; # for (my $i = $from; $i <= $to ; $i++) {}

	}; # if ( $CacheValidTime >= time() ) {

	
	
	return $SendString;
 
 #	my $CONTENT			= PhexProxy::IO->ReadFileIntoArray( "$CACHEPATH/$SearchQuery.$FileTyp.txt" );

}; # sub readCache(){}


sub writeCache(){

	# nimm entgegen: $ToCacheResultsArrayRef, $SearchQuery, $FileTypeHashRef

	my $self			= shift;
	my $ToCacheArrRef	= shift;
	my $SearchQuery		= shift;
	my $FileTypeHashRef = shift;

	# my $KeyCount		= keys( %{$FileTypeHashRef} );
	# my $FileTyp			= $FileTypeHashRef->{$KeyCount};
	my $FileTyp			= $FileTypeHashRef->{ 1 };


	$SearchQuery =~ s/\s/\+/g;
	$SearchQuery = lc($SearchQuery);	# wir wollen nur kleinbuchstaben beim cachen!!
		
	#open(CACHE, ">$CACHEPATH/$SearchQuery.$FileTyp.txt") or sub { warn "PhexProxy::ResultCache->writeCache(): IO ERROR: $!\n"; return -1; };
	open(CACHE, ">$CACHEPATH/$SearchQuery.txt") or sub { warn "PhexProxy::ResultCache->writeCache(): IO ERROR: $!\n"; return -1; };
	CACHE->autoflush(1);
	CACHE->blocking(0);
	flock (CACHE, 2);
		for ( my $i = 0; $i<=$#{$ToCacheArrRef}; $i++ ) {
			$ToCacheArrRef->[$i] =~ s/\r\n/\t\t/g;
			my ( $RANK, $PEERHOST, $SIZE, $SHA1 ) = split('###', $ToCacheArrRef->[$i] );
			chop($SHA1) if ( length($SHA1) == 33 );	# fix für Sort::Array->Sort_Table();
			print CACHE "$RANK###$PEERHOST###$SIZE###$SHA1\n";					
		};
	close CACHE;
		
	return 1;

}; # sub writeCache(){}


return 1;