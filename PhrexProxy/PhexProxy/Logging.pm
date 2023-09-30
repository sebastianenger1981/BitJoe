#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Logging
##### Todo:			logging ^^
########################################

package PhexProxy::Logging;

my $VERSION = '0.47';

use PhexProxy::Time;
#use IO::Handle;
use strict;

mkdir '/server/phexproxy/LOGS/';

my $LOGINIT				= '/server/phexproxy/LOGS/INITLOG.txt';
my $LOGRESULTS			= '/server/phexproxy/LOGS/GETRESULTSLOG.txt';
my $LOGSTARTDL			= '/server/phexproxy/LOGS/STARTDOWNLOADLOG.txt';
my $LOGENDDL			= '/server/phexproxy/LOGS/FINISHDOWNLOADLOG.txt';
my $LOGLICENCE			= '/server/phexproxy/LOGS/INVALIDLICENCELOG.txt';

my $LOGINITDISTR		= '/server/phexproxy/LOGS/INITLOG_DISTR.txt';
my $LOGRESULTSDISTR		= '/server/phexproxy/LOGS/GETRESULTSLOG_DISTR.txt';
my $LOGSTARTDLDISTR		= '/server/phexproxy/LOGS/STARTDOWNLOADLOG_DISTR.txt';
my $LOGENDDLDISTR		= '/server/phexproxy/LOGS/FINISHDOWNLOADLOG_DISTR.txt';
my $LOGLICENCEDISTR		= '/server/phexproxy/LOGS/INVALIDLICENCELOG_DISTR.txt';


sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new();




######## Distributed Paris


sub LogToFileInitDistr(){
	
	my $self			= shift;
	my $LogScalarRef	= shift;
	my $IpAdress		= shift;

	#	$hostinfo->name || $client->peerhost;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileType , $JavaVersion, $HandyModel , $MobilePhoneProvider, $ResultID ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGINITDISTR") or sub { warn "PhexProxy::Logging->LogToFileInit(): IO ERROR: $!\n"; return -1; };
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
		#	print LOG "\t\t HANDYDNS: $Hostname\n";
			print LOG "\t\t HANDYIP $IpAdress\n";
			print LOG "\t\t QUERYDATETIME: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

};	 # sub LogToFileInit(){}


sub LogToFileGetResultsDistr(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileType , $Sources, $FileName , $ResultID, $From, $To ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	open(LOG,"+>>$LOGRESULTSDISTR") or sub { warn "PhexProxy::Logging->LogToFileGetResults(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
			print LOG "\t\t TIMEOFGETRESULTS: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t RESULTFROM: $From\n";
			print LOG "\t\t RESULTTO: $To\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

}; # sub LogToFileGetResults(){}



sub LogToFileStartDownloadDistr(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $IpAdress		= shift;

	#	$hostinfo->name || $client->peerhost;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGSTARTDLDISTR") or sub { warn "PhexProxy::Logging->LogToFileStartDownload(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
			print LOG "\t\t TIMEOFDOWNLOADSTARTED: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

}; # sub LogToFileStartDownload(){}



sub LogToFileFinishDownloadDistr(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID, $DownloadStatus ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGENDDLDISTR") or sub { warn "PhexProxy::Logging->LogToFileFinishDownload(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
			print LOG "\t\t TIMEOFDOWNLOADFINISH: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t DOWNLOADSTATUS: $DownloadStatus\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

};	# sub LogToFileFinishDownload(){}


sub LogToFileInvalidLicenceDistr(){

	my $self			= shift;
	my $LogScalarRef	= shift;
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID, $DownloadStatus ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGLICENCEDISTR") or sub { warn "PhexProxy::Logging->LogToFileInvalidLicence(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
			print LOG "\t\t TIMEOFDOWNLOADFINISH: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t DOWNLOADSTATUS: $DownloadStatus\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

}; # sub LogToFileInvalidLicence(){



######### normales paris


sub LogToFileInit(){
	
	my $self			= shift;
	my $LogScalarRef	= shift;
	my $IpAdress		= shift;

	#	$hostinfo->name || $client->peerhost;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileType , $JavaVersion, $HandyModel , $MobilePhoneProvider, $ResultID ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGINIT") or sub { warn "PhexProxy::Logging->LogToFileInit(): IO ERROR: $!\n"; return -1; };
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
		#	print LOG "\t\t HANDYDNS: $Hostname\n";
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
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileType , $Sources, $FileName , $ResultID, $From, $To ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	open(LOG,"+>>$LOGRESULTS") or sub { warn "PhexProxy::Logging->LogToFileGetResults(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
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
	my $IpAdress		= shift;

	#	$hostinfo->name || $client->peerhost;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGSTARTDL") or sub { warn "PhexProxy::Logging->LogToFileStartDownload(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
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
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID, $DownloadStatus ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGENDDL") or sub { warn "PhexProxy::Logging->LogToFileFinishDownload(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
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
	my $IpAdress		= shift;

	my ( $type, $flag, $IMEI, $LicenceKey, $ClientVersion, $SearchQuery , $FileLength , $SHA1 , $Sources, $FileName , $ResultID, $DownloadStatus ) = split("\r\n", ${$LogScalarRef}); 
	my $UnixTimeStamp = time();
	my $MySQLDateTime = PhexProxy::Time->MySQLDateTime();

	# later: open(LOG,"+>>/logs/log") or doSQLLogs()

	open(LOG,"+>>$LOGLICENCE") or sub { warn "PhexProxy::Logging->LogToFileInvalidLicence(): IO ERROR: $!\n"; return -1; };
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
			print LOG "\t\t HANDYIP: $IpAdress\n";
			print LOG "\t\t TIMEOFDOWNLOADFINISH: $MySQLDateTime | $UnixTimeStamp\n";
			print LOG "\t\t RESULTID: $ResultID\n";
			print LOG "\t\t DOWNLOADSTATUS: $DownloadStatus\n";
			print LOG "END: ##########\n";
		# der flock wird mit dem schließen des dateihandels geschlossen
	close LOG;

	return 1;

}; # sub LogToFileInvalidLicence(){




# wir sollten nur flatfile format loggen->sql zuviel overhead
sub LogToSql(){

	my $self = shift;
	my $IO	 = shift;

	#use DB;
	# log to sql server

	return 1;

}; #sub LogToSql(){}


return 1;
