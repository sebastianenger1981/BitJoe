#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Logging
##### Todo:			logging ^^
########################################

package MutellaProxy::Logging;

my $VERSION = '0.17';

use MutellaProxy::Time;
use strict;

my $LOGINIT		= '/server/mutella/LOGS/INITLOG.txt';
my $LOGRESULTS	= '/server/mutella/LOGS/GETRESULTSLOG.txt';
my $LOGSTARTDL	= '/server/mutella/LOGS/STARTDOWNLOADLOG.txt';
my $LOGENDDL	= '/server/mutella/LOGS/FINISHDOWNLOADLOG.txt';
my $LOGLICENCE	= '/server/mutella/LOGS/INVALIDLICENCELOG.txt';

#use IO::Handle;

sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new();


sub LogToFileInit(){
	
	my $self			= shift;
	my $LogScalarRef	= shift;
	my $Hostname		= shift;
	my $IpAdress		= shift;

	#	$hostinfo->name || $client->peerhost;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileType , $JavaVersion, $HandyModel , $MobilePhoneProvider, $ResultID ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = MutellaProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGINIT") or sub { warn "MutellaProxy::Logging->LogToFileInit(): IO ERROR: $!\n"; return -1; };
		flock (LOG, 2);
			print LOG "START: ### DateTime: $MySQLDateTime ### UnixTimeStamp: $UnixTimeStamp ###\n";
			print LOG "\t\t LOGTYPE: $type|Init\n";
			print LOG "\t\t LOGFLAG: $flag\n";
			print LOG "\t\t IMEI: $IMEI\n";
			print LOG "\t\t LICENCE: $LicenceKey\n";
			print LOG "\t\t CLIENT: $ClientVersion\n";
			print LOG "\t\t SEARCH: $SearchQuery \n";
			print LOG "\t\t FILETYP: $FileType\n";
			print LOG "\t\t JAVA: $JavaVersion\n";
			print LOG "\t\t HANDY: $HandyModel\n";
			print LOG "\t\t PROVIDER: $MobilePhoneProvider\n";
			print LOG "\t\t HANDYDNS: $Hostname \n";
			print LOG "\t\t HANDYIP $IpAdress\n";
			print LOG "\t\t QUERYDATETIME: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

};	 # sub LogToFileInit(){}


sub LogToFileGetResults(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $Hostname		= shift;
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileType , $Sources, $FileName , $ResultID, $From, $To ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = MutellaProxy::Time->MySQLDateTime();

	open(LOG,"+>>$LOGRESULTS") or sub { warn "MutellaProxy::Logging->LogToFileGetResults(): IO ERROR: $!\n"; return -1; };
		flock (LOG, 2);
			print LOG "START: ### DateTime: $MySQLDateTime ### UnixTimeStamp: $UnixTimeStamp ###\n";
			print LOG "\t\t LOGTYPE: $type|GetResults\n";
			print LOG "\t\t LOGFLAG: $flag\n";
			print LOG "\t\t IMEI: $IMEI\n";
			print LOG "\t\t LICENCE: $LicenceKey\n";
			print LOG "\t\t CLIENT: $ClientVersion\n";
			print LOG "\t\t SEARCH: $SearchQuery \n";
			print LOG "\t\t FILETYP: $FileType\n";
			print LOG "\t\t FILENAME: $FileName\n";
			print LOG "\t\t SOURCES: $Sources\n";
			print LOG "\t\t HANDYIP: $IpAdress | $Hostname\n";
			print LOG "\t\t TIMEOFGETRESULTS: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t RESULTFROM: $From\n";
			print LOG "\t\t RESULTTO: $To\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

}; # sub LogToFileGetResults(){}



sub LogToFileStartDownload(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $Hostname		= shift;
	my $IpAdress		= shift;

	#	$hostinfo->name || $client->peerhost;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = MutellaProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGSTARTDL") or sub { warn "MutellaProxy::Logging->LogToFileStartDownload(): IO ERROR: $!\n"; return -1; };
		flock (LOG, 2);
			print LOG "START: ### DateTime: $MySQLDateTime ### UnixTimeStamp: $UnixTimeStamp ###\n";
			print LOG "\t\t LOGTYPE: $type|StartDownload\n";
			print LOG "\t\t LOGFLAG: $flag\n";
			print LOG "\t\t IMEI: $IMEI\n";
			print LOG "\t\t LICENCE: $LicenceKey\n";
			print LOG "\t\t CLIENT: $ClientVersion\n";
			print LOG "\t\t SEARCH: $SearchQuery \n";
			print LOG "\t\t FILELENGTH: $FileLength\n";
			print LOG "\t\t FILENAME: $FileName\n";
			print LOG "\t\t FILESHA1: $SHA1\n";
			print LOG "\t\t SOURCES: $Sources\n";
			print LOG "\t\t HANDYIP: $IpAdress | $Hostname\n";
			print LOG "\t\t TIMEOFDOWNLOADSTARTED: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

}; # sub LogToFileStartDownload(){}



sub LogToFileFinishDownload(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $Hostname		= shift;
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID, $DownloadStatus ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = MutellaProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGENDDL") or sub { warn "MutellaProxy::Logging->LogToFileFinishDownload(): IO ERROR: $!\n"; return -1; };
		flock (LOG, 2);
			print LOG "START: ### DateTime: $MySQLDateTime ### UnixTimeStamp: $UnixTimeStamp ###\n";
			print LOG "\t\t LOGTYPE: $type|FinishDownload\n";
			print LOG "\t\t LOGFLAG: $flag\n";
			print LOG "\t\t IMEI: $IMEI\n";
			print LOG "\t\t LICENCE: $LicenceKey\n";
			print LOG "\t\t CLIENT: $ClientVersion\n";
			print LOG "\t\t SEARCH: $SearchQuery \n";
			print LOG "\t\t FILELENGTH: $FileLength\n";
			print LOG "\t\t FILENAME: $FileName\n";
			print LOG "\t\t FILESHA1: $SHA1\n";
			print LOG "\t\t SOURCES: $Sources\n";
			print LOG "\t\t HANDYIP: $IpAdress | $Hostname\n";
			print LOG "\t\t TIMEOFDOWNLOADFINISH: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t DOWNLOADSTATUS: $DownloadStatus\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

};	# sub LogToFileFinishDownload(){}


sub LogToFileInvalidLicence(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $Hostname		= shift;
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID, $DownloadStatus ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = MutellaProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGLICENCE") or sub { warn "MutellaProxy::Logging->LogToFileInvalidLicence(): IO ERROR: $!\n"; return -1; };
		flock (LOG, 2);
			print LOG "START: ### DateTime: $MySQLDateTime ### UnixTimeStamp: $UnixTimeStamp ###\n";
			print LOG "\t\t LOGTYPE: $type|InvalidLicence\n";
			print LOG "\t\t LOGFLAG: $flag\n";
			print LOG "\t\t IMEI: $IMEI\n";
			print LOG "\t\t LICENCE: $LicenceKey\n";
			print LOG "\t\t CLIENT: $ClientVersion\n";
			print LOG "\t\t SEARCH: $SearchQuery \n";
			print LOG "\t\t FILELENGTH: $FileLength\n";
			print LOG "\t\t FILENAME: $FileName\n";
			print LOG "\t\t FILESHA1: $SHA1\n";
			print LOG "\t\t SOURCES: $Sources\n";
			print LOG "\t\t HANDYIP: $IpAdress | $Hostname\n";
			print LOG "\t\t TIMEOFDOWNLOADFINISH: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t DOWNLOADSTATUS: $DownloadStatus\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

};


# wir sollten nur flatfile format loggen->sql zuviel overhead
sub LogToSql(){

	my $self = shift;
	my $IO	 = shift;

	#use DB;
	# log to sql server

	return 1;

}; #sub LogToSql(){}


return 1;
