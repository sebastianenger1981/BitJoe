#!/usr/bin/perl	-I/root/.mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Anzahl der übertragenen Daten loggen
##### Todo:			auswertungstool für die bytes schreiben	
########################################

package MutellaProxy::IOTransfer;

my $VERSION = '0.17';

use MutellaProxy::Time;
use strict;

my $TRANSFERPATH	= '/root/.mutella/TRANSFER';


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub LogBytes(){
	
	my $self	= shift;
	my $BytesIn	= shift || 0;

	my $OldBytes;
	my $OldAccess;

	my $CurrentDay = MutellaProxy::Time->SimpleMySQLDateTime();
	
	open(IO,"<$TRANSFERPATH/$CurrentDay.txt") or sub { warn "MutellaProxy::IOTransfer->LogBytes(): IO ERROR: $!\n"; return -1; };
		flock (IO, 2);
		$OldBytes = <IO>;
	close IO;

	my $m1 = $OldBytes+$BytesIn;
	open(IO,"+>>$TRANSFERPATH/$CurrentDay.txt") or sub { warn "MutellaProxy::IOTransfer->LogBytes(): IO ERROR: $!\n"; return -1; };
		flock (IO, 2);
		print IO $m1; 
	close IO;

	open(IO,"<$TRANSFERPATH/$CurrentDay.access.txt") or sub { warn "MutellaProxy::IOTransfer->LogBytes(): IO ERROR: $!\n"; return -1; };
		flock (IO, 2);
		$OldAccess = <IO>;
	close IO;

	my $n1 = $OldAccess+1;
	open(IO,"+>>$TRANSFERPATH/$CurrentDay.access.txt") or sub { warn "MutellaProxy::IOTransfer->LogBytes(): IO ERROR: $!\n"; return -1; };
		flock (IO, 2);
		print IO $n1;
	close IO;

	return 1;

}; # sub LogBytes(){}


return 1;