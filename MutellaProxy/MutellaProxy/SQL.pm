#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		SQL Verbindungen aufbauen
##### Todo:			
########################################

package MutellaProxy::SQL;

use DBI;
use strict;

my $VERSION = '0.17';

### later: alles aus config lesen  
my $HOST	= "localhost";
my $DB		= "GnutellaProxy";
my $USER	= "root";
my $PASS	= "xfZYKWuu";


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub SQLConnect(){

	my $self	= shift;
	my $drh		= DBI->install_driver("mysql");
	my $dbh		= DBI->connect("DBI:mysql:database=$DB;host=$HOST", "$USER", "$PASS", {'RaiseError' => 0});
	return $dbh;

};	# sub SQLConnect(){}


return 1;