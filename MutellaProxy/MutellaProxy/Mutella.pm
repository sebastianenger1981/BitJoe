#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		Mutella spezifische Funktionen
##### Todo:			
########################################

package MutellaProxy::Mutella;

use MutellaProxy::Parser;
use MutellaProxy::IO;
use strict;

my $VERSION = '0.19.5';

use constant FIND_COMMAND	=> "find ";	
use constant LIST_COMMAND	=> "list \n"; 
use constant DELETE_COMMAND	=> "delete ";	
use constant OPEN_COMMAND	=> "open ";
use constant INFO_COMMAND	=> "info \n";

use constant CRLF			=> "\r\n";
my $ULTRAPEERLIST			= "http://www.zoozle.net/projekt24-testXASDQasdfqwe42/ultrapeers.txt";


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub getResultID(){

	my $self			= shift;
	my $MutellaSocket	= shift || MutellaProxy::IO->CreateMutellaSocket();
	my $SEARCH			= shift;

	my $listHashRef		= MutellaProxy::Parser->ListCommandParser( $MutellaSocket );

	for my $value ( keys %{$listHashRef} ) {
		my $ListSearch = $listHashRef->{ $value }->{ 'SEARCH' };
		# wenn suchanfrage gleich dem eintrag in der mutella liste, dann gib die result id zurück
		if ( lc($SEARCH) eq lc($ListSearch) ) {
			return $value;
		};
	}; # for my $value ( keys %{$listHashRef} ) {}

	for my $value ( keys %{$listHashRef} ) {
		my $ListSearch = $listHashRef->{ $value }->{ 'SEARCH' };
		if ( $SEARCH =~ /$ListSearch/ ) {
			return $value;
		};
	}; # for my $value ( keys %{$listHashRef} ) {}
		
	for my $value ( keys %{$listHashRef} ) {
		my $ListSearch = $listHashRef->{ $value }->{ 'SEARCH' };
		if ( $SEARCH =~ /$ListSearch/ig ) {
			return $value;
		};
	}; # for my $value ( keys %{$listHashRef} ) {}

	return 'NORESULTS';

}; # sub getResultID(){}


sub find(){

	my $self			= shift;
	my $MutellaSocket	= shift || MutellaProxy::IO->CreateMutellaSocket();
	my $SearchQuery		= shift; 

#	MutellaProxy::IO->writeSocket( $MutellaSocket, FIND_COMMAND . " size:200K " . $SearchQuery . "\n" );
	
	MutellaProxy::IO->writeSocket( $MutellaSocket, FIND_COMMAND . $SearchQuery . "\n" );
	my $id = $self->getResultID( $MutellaSocket, $SearchQuery );

	if ( $id eq 'NORESULTS' ) {
		select(undef, undef, undef, 0.1 );
		$self->find($MutellaSocket, $SearchQuery);
	};

	return 1;

}; # sub find(){}


sub del(){

	my $self			= shift;
	my $MutellaSocket	= shift || MutellaProxy::IO->CreateMutellaSocket();
	my $QueryNumber		= shift;

	MutellaProxy::IO->writeSocket( $MutellaSocket, DELETE_COMMAND . $QueryNumber . "\n" );
	return 1;

}; # sub del(){}


return 1;