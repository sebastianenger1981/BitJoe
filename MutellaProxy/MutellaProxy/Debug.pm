#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Debuggin Infomationen sammeln		
##### Todo:			
########################################

package MutellaProxy::Debug;

my $VERSION = '0.17';

use MutellaProxy::Time;
use Data::Dumper;
use strict;


my $DEBUGFILE	= '/server/mutella/DEBUG/DebugMessages.txt';


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub Debugging(){

	my $self				= shift;
	my $RefObj				= shift || 'MutellaProxy::Object';
	my $Dumper				= shift;
	my $ManualEditedText	= shift || '';
	my $Typ					= shift;

	if ( $Typ ne 'SCREEN' ) {
	
		my $MySQLDateTime = MutellaProxy::Time->MySQLDateTime();
		open(DEBUG,"+>>$DEBUGFILE") or sub { warn "MutellaProxy::Debug->Debugging(): IO ERROR: $!\n"; return -1; };
			flock (DEBUG, 2);
				print DEBUG "########## Entry from $MySQLDateTime ### RefObj $RefObj ##########\n";
				print DEBUG "########## Manual Text: $ManualEditedText ########################\n";
				print DEBUG Dumper( $Dumper );
				print DEBUG "##################################################################\n";
		close DEBUG;

	}; 

	return Dumper( $Dumper );

}; # sub Debugging(){}


return 1;