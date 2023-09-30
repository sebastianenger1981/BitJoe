#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		SMS
##### Todo:			
########################################

package PhexProxy::SMS;
use LWP::Simple;
use strict;

my @Admins	= ("01607979247");	# Admins to Inform


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()



sub SendCustomSMS(){

	my $self					= shift;
	my $SmsMessage				= shift;

	foreach my $PhoneNumber ( @Admins ) {

		my $Absender			= "BJParis";
		my $HiddenGateWayKey	= "0efe39e0c019fd11f32044749dbb1ab2";
		$SmsMessage				=~ s/([^A-Za-z0-9ß])/sprintf("%%%02X", ord($1))/seg;	# perl urlencode()
		my $QueryUri			= "http://gateway.mobilant.net/?key=" . $HiddenGateWayKey . "&handynr=" . $PhoneNumber . "&text=" . $SmsMessage . "&kennung=". $Absender;
		my $get					= get($QueryUri);

	}; # foreach my $entry ( @Admins ) {

	return 1;

}; # sub SendParisDownSMS(){


sub SendHandyClientSocketDownSMS(){

	my $self					= shift;
	my $ServerDownIPAdresse		= shift;
	my $SmsMessage				= "BJ Paris Distributed Client Socket - Warning\n $ServerDownIPAdresse \n is down!";

	foreach my $PhoneNumber ( @Admins ) {

		my $Absender			= "BJParis";
		my $HiddenGateWayKey	= "0efe39e0c019fd11f32044749dbb1ab2";
		$SmsMessage				=~ s/([^A-Za-z0-9ß])/sprintf("%%%02X", ord($1))/seg;	# perl urlencode()
		my $QueryUri			= "http://gateway.mobilant.net/?key=" . $HiddenGateWayKey . "&handynr=" . $PhoneNumber . "&text=" . $SmsMessage . "&kennung=". $Absender;
		my $get					= get($QueryUri);

	}; # foreach my $entry ( @Admins ) {

	return 1;

}; # sub SendHandyClientSocketDownSMS(){


sub SendParisDownSMS(){

	my $self					= shift;
	my $ServerDownIPAdresse		= shift;
	my $SmsMessage				= "BJ Paris Distributed - Warning\n $ServerDownIPAdresse \n is down!";

	foreach my $PhoneNumber ( @Admins ) {

		my $Absender			= "BJParis";
		my $HiddenGateWayKey	= "0efe39e0c019fd11f32044749dbb1ab2";
		$SmsMessage				=~ s/([^A-Za-z0-9ß])/sprintf("%%%02X", ord($1))/seg;	# perl urlencode()
		my $QueryUri			= "http://gateway.mobilant.net/?key=" . $HiddenGateWayKey . "&handynr=" . $PhoneNumber . "&text=" . $SmsMessage . "&kennung=". $Absender;
		my $get					= get($QueryUri);

	}; # foreach my $entry ( @Admins ) {

	return 1;

}; # sub SendParisDownSMS(){


return 1;