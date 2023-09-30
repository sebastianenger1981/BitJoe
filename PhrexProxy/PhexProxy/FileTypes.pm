#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian | modified 27.07.06 Torsten
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.06
##### Function:		Dateitypen definieren
##### Todo:			
########################################

package PhexProxy::FileTypes;


use Data::Dumper;
use strict;

my $VERSION = '0.18';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()
  

sub getSearchFiles(){

	my $self				= shift;
	my $RawString			= shift;	# b001000100
	my ( @content )			= split('', $RawString);
	
	my $FileReturnString	= "-filetype:"; #v2
	my $FileType			= $content[0];
	$FileType				= lc($FileType);
	my $CurrentFileType;

	# Stelle sicher, dass zu dem "gewollten" Format auch die Lizenz passt -> sonst error meldung
	if ( $FileType eq 'b' ) {
		$CurrentFileType = $self->BilderFileTypes();	
	} elsif ( $FileType eq 'm' ) {
		$CurrentFileType = $self->MP3FileTypes();
	} elsif ( $FileType eq 'k' ) {
		$CurrentFileType = $self->RingtonesFileTypes();
	} elsif ( $FileType eq 'v' ) {
		$CurrentFileType = $self->VideoFileTypes();
	} elsif ( $FileType eq 'j' ) {
		$CurrentFileType = $self->JavaFileTypes();
	} elsif ($FileType eq 'd' ) {
		$CurrentFileType = $self->DocFileTypes();
	} else {
		$CurrentFileType = $self->BilderFileTypes();	
	}; # if ( $FileType eq 'b' ) {
	

	for ( my $j=1; $j<=scalar(@content); $j++ ) {		# binarzahl durchgehen - bei 1 anfangen zu zählen, weil das erste zeichen ein buchstaben ist
		my $number = $content[$j];
		if ( $number == 1 ) {							# nur wenn 1 dann sollen wir auch danach suchen, sprich wenn 1 dann ist dieser Filetyp für diese Suchanfrage aktiviert
			#	print "RAW=$RawString\n";
			#	print "Stelle [$j] Zahl [$number] Type:" . $CurrentFileType->{$j} . " \n";
			$FileReturnString .= " ." . $CurrentFileType->{$j};
		};
	}; # for ( my $j=1;$j<=scalar(@content); $j++ ) {
	

	return ( $FileReturnString, $FileType );

}; # sub getSearchFiles(){


sub BilderFileTypes(){

	my %BilderFileTypes = (
		0 => 'null',
		1 => 'jpg', # first is default
		2 => 'jpeg',
		3 => 'png',
		4 => 'gif',
		5 => 'bmp',
		6 => 'tiff',
		7 => 'svg',
		8 => 'jpa',
		9 => 'tif',
		10 => 'thm',
	);

	return \%BilderFileTypes;

};	# sub BilderFileTypes(){}


sub MP3FileTypes(){

	my %MP3FileTypes = (
		0 => 'null',
		1 => 'mp3', # first is default
		2 => 'wma',
		3 => 'mp2',
		4 => 'midi', # first is default
		5 => 'mid',
		6 => 'wav', 
		7 => 'aac',
		8 => 'amr',
		9 => 'wave',
		10 => 'flac',
		11 => 'smaf',
		12 => 'mld',
		13 => 'ogg',
		14 => 'mmf',
		15 => 'aiff',
		16 => 'rma',
		17 => 'ape',
		18 => 'mpc',
	);

	return \%MP3FileTypes;

};	# sub MP3FileTypes(){}


sub RingtonesFileTypes(){

	my %RingtonesFileTypes = (
		0 => 'null',
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
		11 => 'mmf',
		12 => 'aiff',
		13 => 'rma',
		14 => 'ape',
		15 => 'mpc',
	);

	return \%RingtonesFileTypes;

};	# sub RingtonesFileTypes(){}


sub VideoFileTypes(){

	my %VideoFileTypes = (
		0 => 'null',
		1 => '3gp', # first is default
		2 => 'mpg', 
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
		15 => 'flv',
		16 => 'fla',
		17 => 'swf',
		18 => 'f4v',
	);
	
	return \%VideoFileTypes;

};	# sub VideoFileTypes(){}


sub JavaFileTypes(){

	my %JavaFileTypes = (
		0 => 'null',
		1 => 'jar', # first is default
		2 => 'class',
		3 => 'jad',
		4 => 'sis',
		5 => 'sisx',
	);

	return \%JavaFileTypes;

};	# sub JavaFileTypes(){}


sub DocFileTypes(){

	my %DocFileTypes = (
		0 => 'null',
		1 => 'txt', # first is default
		2 => 'pdf',
		3 => 'rtf',
		4 => 'xls',
		5 => 'xlsx',
		6 => 'doc',
		7 => 'docx',
		8 => 'ppt',
		9 => 'pptx',
		10 => 'xml',
		11 => 'html',
		12 => 'htm',
		13 => 'xhtml',
		14 => 'odt',
		15 => 'sxw',
		16 => 'ods',
		17 => 'sxc',
		18 => 'odp',
		19 => 'sxi',
	);

	return \%DocFileTypes;

};	# sub DocFileTypes(){}


return 1;