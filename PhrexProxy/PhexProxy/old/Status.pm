#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	17.07.2006
##### Function:		Server Status Flag auswerten
##### Todo:			
########################################

package PhexProxy::Status;

use PhexProxy::IO;
use strict;

my $VERSION		= '0.17';
my $StatusFile	= '/server/mutella/STATUS/StatusFile.txt';

sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()

sub readStatus(){

	# Status=1:		working correctly
	# Status=-1:	bin busy und nehme keine verbindungen mehr an

	my $Status = PhexProxy::IO->ReadFileIntoScalar( $StatusFile );
	$Status = ${$Status};

	if ( $Status eq '-1' || $Status =~ /-1/ ) {
		return -1;
	} elsif ( $Status eq '0' || $Status =~ /0/ ) {
		return -1;
	} elsif ( $Status eq '1' || $Status =~ /1/ ) {
		return 1;
	};	

	# default gebe working correctly zurück
	return 1;

}; # sub readStatus(){}


return 1;