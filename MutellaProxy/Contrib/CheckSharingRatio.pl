#!/usr/bin/perl	-I/root/.mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		Parsing von Daten
##### Todo:			
########################################

use MutellaProxy::Parser;
use MutellaProxy::IO;

my $MutellaSocket = MutellaProxy::IO->CreateMutellaSocket();
MutellaProxy::Parser->CheckSharingRatio($MutellaSocket);
