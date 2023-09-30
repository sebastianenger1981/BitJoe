#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian | modified 27.07.06 Torsten
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.06
##### Function:		Dateitypen definieren
##### Todo:			
########################################

package MutellaProxy::FileTypes;

use strict;

my $VERSION = '0.18';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()
  

sub BilderFileTypes(){

	my %BilderFileTypes = (
		1 => 'jpg', # first is default
		2 => 'jpeg',
		3 => 'png',
		4 => 'gif',
		5 => 'bmp',
		6 => 'tiff',
		7 => 'svg',
		8 => 'jpa',
		9 => 'tif',		
	);

	return \%BilderFileTypes;

};	# sub BilderFileTypes(){}


sub MP3FileTypes(){

	my %MP3FileTypes = (
		1 => 'mp3', # first is default
		2 => 'wma',
		3 => 'mp2',
	);

	return \%MP3FileTypes;

};	# sub MP3FileTypes(){}


sub RingtonesFileTypes(){

	my %RingtonesFileTypes = (
		1 => 'midi', # first is default
		2 => 'mid',
		3 => 'wav', 
		4 => 'aac',
		5 => 'amr',
		6 => 'wave',
		7 => 'flac',
		8 => 'smaf',
		9 => 'mld',
		10 => 'ogg',
		10 => 'mmf',
		11 => 'aiff',
		12 => 'rma',
		13 => 'ape',
		14 => 'mpc',
	);

	return \%RingtonesFileTypes;

};	# sub RingtonesFileTypes(){}


sub VideoFileTypes(){

	my %VideoFileTypes = (
		1 => 'mpg', # first is default
		2 => '3gp', 
		3 => 'avi',
		4 => 'wmv',
		5 => 'mp4',
		6 => 'rm',
		7 => 'mpeg',
		8 => 'mov',
		9 => 'wmm',
		10 => 'wmf',
		11 => 'ram',
		12 => 'ogm',
		13 => 'vivo',
		14 => 'asx',
	);
	
	return \%VideoFileTypes;

};	# sub VideoFileTypes(){}


sub JavaFileTypes(){

	my %JavaFileTypes = (
		1 => 'jar', # first is default
		2 => 'class',
		3 => 'jad',
	);

	return \%JavaFileTypes;

};	# sub JavaFileTypes(){}


sub DocFileTypes(){

	my %DocFileTypes = (
		1 => 'txt', # first is default
		2 => 'pdf',
		3 => 'doc',
		4 => 'xls',
	);

	return \%DocFileTypes;

};	# sub DocFileTypes(){}


return 1;