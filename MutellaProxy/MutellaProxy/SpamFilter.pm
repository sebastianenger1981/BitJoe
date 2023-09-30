#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		verschiede Filter für die Results
##### Todo:			
########################################

package MutellaProxy::SpamFilter;

use strict;


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # sub new(){}


sub SpamFilter(){

	my $self		= shift;
	my $ScalarRef	= shift;
	my $SearchQuery	= shift;
	$SearchQuery	= lc($SearchQuery);
	
	if ( ${$ScalarRef} =~ /[(\w)|(\d)|(\s)]+\.(com|net|org|biz|de|info|tv|vu|eu|at|ch)/i) {
		return -1;	# sind equal
	} elsif ( ${$ScalarRef} =~ /[(\w)|(\d)|(\s)]+\.(zip|arj|rar|exe|com)/i) {
		return -1;	# sind equal
	} elsif ( ${$ScalarRef} eq "$SearchQuery-xxx.wmv" || ${$ScalarRef} =~ /$SearchQuery-xxx\.wmv/i ) {
		return -1;	# sind equal
	} elsif ( ${$ScalarRef} eq "$SearchQuery.wmv" || ${$ScalarRef} =~ /$SearchQuery\.wmv/i ) {
		return -1;	# sind equal
	};

	return 0;
	
};  # sub UrlFilter(){}


return 1;