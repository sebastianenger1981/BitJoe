#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		SMS
##### Todo:			
########################################

package PhexProxy::ICQ;

use PhexProxy::Time;
use strict;


my $TIME	= PhexProxy::Time->new();

my @Admins	= ("135846444");			# Admins to Inform
my $uid		= "473836055";				# icq des bots
my $pw		= "123test";				# pwd des bots
my $climm	= "/usr/local/bin/climm";	# climm binary - muss nach installieren erst noch ein account aufgesetzt werden - http://www.climm.org/


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub SendICQMessage(){

	my $self	= shift;
	my $Message	= shift;
	my $time	= $TIME->MySQLDateTime();
	my $tmp		= "[$time] $Message";
	$Message	= $tmp;

	foreach my $ICQNumber ( @Admins ) {
		my $back = system("$climm -u $uid -p $pw -C \"msg $ICQNumber $Message\" \"exit\"");
	}; # foreach my $entry ( @Admins ) {

	system("/usr/bin/killall climm");
	return 1;

}; # sub SendICQMessage(){


sub SendParisDownICQ(){

	my $self				= shift;
	my $ServerDownIPAdresse	= shift;
	my $Message				= "BJ Paris Distributed - Warning\n $ServerDownIPAdresse \n is down!";
	my $time				= $TIME->MySQLDateTime();
	my $tmp					= "[$time] $Message";
	$Message				= $tmp;

	foreach my $ICQNumber ( @Admins ) {
		my $back = system("$climm -u $uid -p $pw -C \"msg $ICQNumber $Message\" \"exit\"");
	}; # foreach my $entry ( @Admins ) {

	system("/usr/bin/killall climm");
	return 1;

}; # sub SendParisDownSMS(){


return 1;