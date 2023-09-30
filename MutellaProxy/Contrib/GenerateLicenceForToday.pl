#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Lizenzen generieren
##### Todo:			
########################################

use MutellaProxy::LicenceGenerator;
use MutellaProxy::LicenceTransfer;


# MutellaProxy::LicenceGenerator->AddLicenceToSQL();
MutellaProxy::LicenceTransfer->TestInstalledLicence();
