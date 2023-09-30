#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	12.07.2006
##### Function:		LicenceManagement
##### Todo:			
########################################

package PhexProxy::LicenceManagement;

use PhexProxy::FileTypes;
use PhexProxy::SQL;
use strict;

use Data::Dumper;

my $VERSION = '0.27.1';

sub new() {
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub CheckLicence(){
	
	my $self				= shift;
	my $ArrayRef			= shift;
		
	my $WishedFileType		= $ArrayRef->[1];
	my $Licence				= $ArrayRef->[3];
	my $ClientVersion		= $ArrayRef->[4];
	
	my $AllowedLicenceFlag	= 0;
	my $AllowedClientFlag	= 0;
	my $AllowedFileTypeFlag = 0;

	my $CurrentFileType		= {};
	my $FileTypeHashRef		= {};
	my $ResultHashRef;		# wird beim sql query dann mit werten gefüllt
	my $DBHandle;
	my $FileType;
	my $sth;

	RESTARTONE:
	$@ ='';
	undef $@;

	# hole die lizenzinformationen aus der datenbank
	eval {
		$DBHandle = PhexProxy::SQL->SQLConnect();
		$sth = $DBHandle->prepare( qq { SELECT * FROM `Licence` WHERE `LICENCE` = "$Licence" AND `VALIDUNTIL` >= CURDATE() LIMIT 1; } );
		$sth->execute;
		$ResultHashRef = $sth->fetchrow_hashref;
		$sth->finish;
	};
	
	if ( $@ ) {
		print "ERROR: $@ - Restarting $self->CheckLicence( ArrayRef ) \n";
		select(undef, undef, undef, 0.1 );
		goto RESTARTONE;
	};

	RESTARTTWO:
	$@ ='';
	undef $@;

	eval {
		# update den hits counter, der den zugriff auf den jeweiligen lizenzschlüssel zählt
		my $NEWHITS = $ResultHashRef->{'HITS'} + 1;
		my $sth2	= $DBHandle->prepare( qq { UPDATE `Licence` SET `HITS` = "$NEWHITS" WHERE `LICENCE` = "$Licence" LIMIT 1; } );
		$sth2->execute;
		$sth2->finish;
	};

	if ( $@ ) {
		print "ERROR: $@ - Restarting $self->CheckLicence( ArrayRef ) \n";
		select(undef, undef, undef, 0.1 );
		goto RESTARTTWO;
	};

	my ( @WantedFileTypes ) = split(',', $WishedFileType );
	my $WantedFileTypes;

	# debug
	print "CheckLicence() DEBUG: $WishedFileType und L: $Licence - " . $WantedFileTypes[0] . "  \n";

	# Stelle sicher, dass zu dem "gewollten" Format auch die Lizenz passt -> sonst error meldung
	if ( ( $WantedFileTypes[0] eq 'b') && ( $ResultHashRef->{'FORMATBILD'} == 1 ) ) {
		
		$CurrentFileType = PhexProxy::FileTypes->BilderFileTypes();	
		$AllowedFileTypeFlag = 1;
		$FileType = 'FORMATBILD';

	} elsif ( ( $WantedFileTypes[0] eq 'm' ) && ( $ResultHashRef->{'FORMATMP3'} == 1 ) ) {

		$CurrentFileType = PhexProxy::FileTypes->MP3FileTypes();
		$AllowedFileTypeFlag = 1;
		$FileType = 'FORMATMP3';

	} elsif ( ( $WantedFileTypes[0] eq 'k' ) && ( $ResultHashRef->{'FORMATRING'} == 1 ) ) {

		$CurrentFileType = PhexProxy::FileTypes->RingtonesFileTypes();
		$AllowedFileTypeFlag = 1;
		$FileType = 'FORMATRING';

	} elsif ( ( $WantedFileTypes[0] eq 'v' ) && ( $ResultHashRef->{'FORMATVIDEO'} == 1 ) ) {

		$CurrentFileType = PhexProxy::FileTypes->VideoFileTypes();
		$AllowedFileTypeFlag = 1;
		$FileType = 'FORMATVIDEO';

	} elsif ( ( $WantedFileTypes[0] eq 'j' ) && ( $ResultHashRef->{'FORMATJAVA'} == 1 ) ) {

		$CurrentFileType = PhexProxy::FileTypes->JavaFileTypes();
		$AllowedFileTypeFlag = 1;
		$FileType = 'FORMATJAVA';

	} elsif ( ( $WantedFileTypes[0] eq 'd' ) && ( $ResultHashRef->{'FORMATDOC'} == 1 ) ) {

		$CurrentFileType = PhexProxy::FileTypes->DocFileTypes();
		$AllowedFileTypeFlag = 1;
		$FileType = 'FORMATDOC';

	} else {

		$AllowedFileTypeFlag = -3;
		
	};


############
#### Achtung: nur ausgelegt für einen filetyp pro anfrage
############

	foreach my $entry ( @WantedFileTypes ) {
		if ( $entry =~ /(\d)/i ) { # ignoriere b,m,k,v,j,d

			# mache auf jeden fall kleinbuchstaben drauss
			# ($entry + 1) funktioniert solange, wie micha mit dem zählen bei den Dateitypen bei 0 anfängt
			# ($entry ) funktioniert nur dann, wenn micha mit dem zählen bei den Dateitypen bei 1 anfängt

			# $FileTypeHashRef->{ 1 } = lc($CurrentFileType->{ ($entry + 1) });	
			#last: $FileTypeHashRef->{ 1 } = lc($CurrentFileType->{ $entry });	
			
			if ( lc($CurrentFileType->{ $entry }) eq "null" ) {
				$FileTypeHashRef->{ 1 } = lc($CurrentFileType->{ ($entry + 1) });	
			} else {
				$FileTypeHashRef->{ 1 } = lc($CurrentFileType->{ $entry });	
			};

		}; # if ( $entry 
	}; # foreach my $entry ( @WantedFileTypes ) {

	$FileTypeHashRef->{ 0 } = $FileType;	# FORMATDOC|FORMATBILD usw

############
#### Achtung Ende: nur ausgelegt für einen filetyp pro anfrage
############

	# FINAL: if ( ($Licence eq $ResultHashRef->{'LICENCE'}) AND (length($ResultHashRef->{'LICENCE'}) == 32) AND (length($Licence) == 32) ) {
	if ( $Licence eq $ResultHashRef->{'LICENCE'} ) {
		$AllowedLicenceFlag = 1;
	} else {
		$AllowedLicenceFlag = -3;
	};
	
	# Lizenzkey zu Clientversion passt (FC 305)
	if ( ( $ClientVersion >= $ResultHashRef->{'CMIN'} ) && ( $ClientVersion <= $ResultHashRef->{'CMAX'} ) ) {	
		$AllowedClientFlag	= 1;
 	} else { 
		$AllowedClientFlag	= -3;
	};

#
#	use Data::Dumper;
#
#	print "###################################\n";
#	print "DUMP SORTRANK FILETYP:";
#	print Dumper( $FileTypeHashRef );
#	print "###################################\n";
#

	if ( ( $AllowedClientFlag == 1 ) && ( $AllowedLicenceFlag == 1 ) && ( $AllowedFileTypeFlag == 1 ) ) {
		return ( 1, $FileTypeHashRef );
	} elsif ( $AllowedClientFlag == -3 ) {
		return ( "FC 305", {} ) ;
	} elsif ( $AllowedLicenceFlag == -3 ) {
		return ( "FC 205", {} );		
	} elsif ( $AllowedFileTypeFlag == -3 ) {
		return ( "FC 405", {} );
	} else {
		return ( "FC 105 B", {} );
	};

	# default gebe falsch zurück
	return ( "FC 105 B", {} );

};  # sub CheckLicence(){}

return 1;