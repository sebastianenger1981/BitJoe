#!/usr/bin/perl

use strict;
# /srv/server/mysqld/bin/mysqldump -uroot -prouTer99 bitjoe > bitjoe.sql

my $curtime		= MySQLDateTime();
my $bzip2		= "/usr/bin/bzip2";
my $backuppath	= "/srv/server/cron/sqlbackup/bitjoe_$curtime.sql";
my $mysqldump	= "/srv/server/mysqld/bin/mysqldump";
print "Backup to $backuppath \n ";
system("$mysqldump -uroot -prouTer99 bitjoe > $backuppath");

print "Compressing\n";
system("$bzip2 -9 $backuppath");

exit;










sub MySQLDateTime(){

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
	   
	return $year ."-". $mon ."-". $mday .'_'. $hour .'.'. $min .'.'. $sec;
	
}; # sub MySQLDateTime() {}