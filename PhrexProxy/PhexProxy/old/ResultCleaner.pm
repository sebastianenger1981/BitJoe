#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	17.07.2006
##### Function:		Daten für das Löschen von veralteten Suchbegriffen
##### Todo:			
########################################

package PhexProxy::ResultCleaner;

use PhexProxy::Mutella;
use PhexProxy::Parser;
use PhexProxy::IO;
use strict;

my $FILERESULTSTORE		= '/server/mutella/RESULTS/ResultCleaner.txt';
my $STOREOLDRESULTS		= '/server/mutella/RESULTS/OldResults.txt';
my $CacheValidForSec	= '200';
my $VERSION				= '0.17';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub writeResultFile(){

	my $self	= shift;
	my $Search	= shift;

	my $time	= time();

	open(CLEANER,"+>>$FILERESULTSTORE") or sub { warn "PhexProxy::ResultCleaner->writeResultFile(): IO ERROR: $!\n"; return -1; };
		flock (CLEANER, 2);
		print CLEANER "$Search#$time\n";
	close CLEANER;

	return 1;

}; # sub writeResultFile(){}


sub DeleteEntryRange(){

	my $self		= shift;
	my $DeleteUntil = shift || 6024;
	
	my $MutellaSocket	= PhexProxy::IO->CreateMutellaSocket();

	for ( my $i=0; $i<=$DeleteUntil; $i++ ) {
		PhexProxy::Mutella->del( $MutellaSocket, $i );	
	}; # for ( my $i=0; $i<=$DeleteUntil; $i++ ) {}

	return 1;

}; # sub DeleteEntryRange(){}



sub DeleteOldEntries(){

	my $self	= shift;
	my $File	= shift || $FILERESULTSTORE; 

	my $MutellaSocket	= PhexProxy::IO->CreateMutellaSocket();
	my $ArrayRef		= PhexProxy::IO->ReadFileIntoArray( $FILERESULTSTORE );
	
	srand();
	my $Random	= int(rand(10000))+1;
	
	open(WH, "+>>$STOREOLDRESULTS") or sub { warn "PhexProxy::ResultCleaner->DeleteOldEntries(): IO ERROR: $!\n"; return -1; };
	flock (WH, 2);
		print WH time() . " - $FILERESULTSTORE.old.$Random.txt\n"; 
	close WH;

	rename "$FILERESULTSTORE" => "$FILERESULTSTORE.old.$Random.txt";
	
	open(CLEANER, "+>>$FILERESULTSTORE") or sub { warn "PhexProxy::ResultCleaner->DeleteOldEntries(): IO ERROR: $!\n"; return -1; };
	flock (CLEANER, 2);

		my $CurTime	= time();
		foreach my $entry ( @{$ArrayRef} ) {
			
			my ( $Search, $Time ) = split('#', $entry);
			
			# wenn die aktuelle zeit größer ist, als der Zeitpunkt des find-Befehls plus TIMESPAM dann, versuche den eintrag zu löschen
			if ( $CurTime >= ($Time+$CacheValidForSec) ) {
				
				# hole die query id, sie muss ein integer wert sein, wenn als
				# return-Wert 'NORESULTS' zurückkommt, dann exisitert der eintrag nicht mehr im mutella
				# sprich er wurde schon gelöscht

				my $QUERYID = PhexProxy::Mutella->getResultID( $MutellaSocket, $Search );
				if ( $QUERYID eq 'NORESULTS' ) {
				} else {
					
					PhexProxy::Mutella->del( $MutellaSocket, $QUERYID );
					my $QID = PhexProxy::Mutella->getResultID( $MutellaSocket, $Search );
					if ( $QID ne 'NORESULTS' ) {
						PhexProxy::Mutella->del( $MutellaSocket, $QID );
					};

				}; # } else {}
			
			} else {
				print CLEANER "$Search#$Time\n";
			};
	
		}; # foreach my $entry ( @CONTENT ) {}

	close CLEANER;

	close $MutellaSocket;
	return 1;

}; # sub DeleteOldEntries(){}


return 1;