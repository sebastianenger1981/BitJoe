#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		SQL Verbindungen aufbauen
##### Todo:			
########################################

package PhexProxy::SQL;

use DBI;
use strict;

my $VERSION = '0.17';

### later: alles aus config lesen  
#my $HOST	= "87.106.63.182";	# bitjoe.de
#my $DB		= "bitjoe";
#my $USER	= "bitjoe7724717820";
#my $PASS	= "bj236xw23571sdGdhS4522dSfH2";

my $HOST	= "77.247.178.21";	# bitjoe.de
my $DB		= "bitjoe";
my $USER	= "root";
my $PASS	= "rouTer99";



sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub SQLConnect(){

	my $self	= shift;
	# my $drh		= DBI->install_driver("mysql");
	my $dbh		= DBI->connect("DBI:mysql:database=$DB;host=$HOST", "$USER", "$PASS", {'RaiseError' => 0});
	return $dbh;

};	# sub SQLConnect(){}


return 1;