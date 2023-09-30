#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	26.07.2006
##### Function:		Installiere automatisch ultrapeers zum Mutella
##### Todo:			
########################################


use MutellaProxy::Ultrapeers;

 MutellaProxy::Ultrapeers->GetAndInstallUltraPeerHostList();
 MutellaProxy::Ultrapeers->GetAndInstallUltraPeerHostListFromGwebCache();
