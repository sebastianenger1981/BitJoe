#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	14.07.2006
##### Function:		LicenceTransfer
##### Todo:			
########################################

use MutellaProxy::LicenceTransfer;

MutellaProxy::LicenceTransfer->TransferEncryptedContent();
MutellaProxy::LicenceTransfer->CheckIfEncryptedFileExists( );
MutellaProxy::LicenceTransfer->DecryptLicence();
MutellaProxy::LicenceTransfer->SendCheckSumOfFiles();
MutellaProxy::LicenceTransfer->InstallLicenceToDataBase();
MutellaProxy::LicenceTransfer->TestInstalledLicence();

