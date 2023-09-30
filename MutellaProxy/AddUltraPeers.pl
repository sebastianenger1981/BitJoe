#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	26.07.2006
##### Function:		Installiere automatisch ultrapeers zum Mutella
##### Todo:			
########################################


use MutellaProxy::Ultrapeers;
use MutellaProxy::Parser;
use MutellaProxy::IO;

while(1){
	eval {

		# MutellaProxy::Ultrapeers->GetAndInstallUltraPeerHostListFromGwebCache();
		MutellaProxy::Ultrapeers->GetAndInstallUltraPeerHostList();
		# MutellaProxy::Ultrapeers->InstallKnowHostsFromFile();
		# my $MutellaSocket = MutellaProxy::IO->CreateMutellaSocket();
		# MutellaProxy::Parser->CheckSharingRatio($MutellaSocket);
		close $MutellaSocket;
	};

	sleep 100;
};