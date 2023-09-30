#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	4.08.2006
##### Function:		Lösche zu alte Suchanfragen aus dem Mutella
##### Todo:			
########################################


use MutellaProxy::ResultCleaner;

MutellaProxy::ResultCleaner->DeleteEntryRange();
# MutellaProxy::ResultCleaner->DeleteOldEntries();
