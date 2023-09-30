#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Zeitspezifische Daten
##### Todo:			
########################################

package MutellaProxy::Time;

use MutellaProxy::SQL;
use strict;

my $VERSION			= '0.17.1';
my $LicenceIsValid	= "8";		# SELECT DATE_ADD( CURDATE( ) , INTERVAL 8 DAY ); 
								# SELECT DATE_ADD( CURDATE( ) , INTERVAL $LicenceIsValid DAY )

sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub GetValid8DayDateForLicence(){

	my $self		= shift;
	my $DBHandle	= MutellaProxy::SQL->SQLConnect();
	
	my $sth	= $DBHandle->prepare( qq { SELECT DATE_ADD( CURDATE( ) , INTERVAL $LicenceIsValid DAY ) AS `DATE` LIMIT 1; } );
	$sth->execute;
	my $ResultHashRef = $sth->fetchrow_hashref;
	$sth->finish;

	return $ResultHashRef->{ 'DATE' };
	
}; # sub GetValid8DayDateForLicence(){}

	  
sub GetCurrentTimeStamp(){

	return time();

}; # sub GetCurrentTimeStamp(){}


sub MySQLDateTime() {

	my ( $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst ) = localtime(time);
	$year = $year+1900;
	$mon = $mon + 1;

	if ( length($mon) == 1 ) {
		$mon = "0". $mon;
	};
	if ( length($mday) == 1 ) {
		$mday = "0". $mday;
	};
	if ( length($sec) == 1 ) {
		$sec = "0". $sec;
	};
	if ( length($min) == 1 ) {
		$min = "0". $min;
	};
	if ( length($hour) == 1 ) {
		$hour = "0". $hour;
	};
	   
	return $year ."-". $mon ."-". $mday .' '. $hour .':'. $min .':'. $sec;
	
}; # sub MySQLDateTime() {}


sub SimpleMySQLDateTime() {

	my ( $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst ) = localtime(time);
	$year = $year+1900;
	$mon = $mon + 1;

	if ( length($mon) == 1 ) {
		$mon = "0". $mon;
	};
	if ( length($mday) == 1 ) {
		$mday = "0". $mday;
	};
		   
	return $year ."-". $mon ."-". $mday;
	
}; # sub SimpleMySQLDateTime() {}

return 1;