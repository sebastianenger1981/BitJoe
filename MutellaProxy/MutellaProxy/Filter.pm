#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		verschiede Filter für die Results
##### Todo:			
########################################

package MutellaProxy::Filter;

# use String::Approx 'amatch';
use MutellaProxy::IO;
use strict;


#	FORMATBILD=200K
#	FORMATMP3=6M
#	FORMATRING=200K
#	FORMATVIDEO=15M
#	FORMATJAVA=350K
#	FORMATDOC=500K


my $SIZEFILTER	= '/server/mutella/FILTER/sizefilter.dat';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # sub new(){}


sub SizeFilter(){

	my $self				= shift;
	my $type				= shift;
	my $GivenSizeInBytes	= shift;

	my $ContentArrayRef		= MutellaProxy::IO->ReadFileIntoArray( $SIZEFILTER );

	my $multiply;

	foreach my $entry ( @{$ContentArrayRef} ) {
		
		next if ( $entry =~ /^#/ );

		my ( $desc, $sizetmp )	= split('=', $entry );
		my ( $Size, $prefix )	= split(/(B|K|M|G)/i, $sizetmp );
		
		if ( $desc eq $type ) {
			
			if ( $prefix eq 'B' ){
				$multiply = 1;
			} elsif ( $prefix eq 'K' ){
				$multiply = 1024;
			} elsif ( $prefix eq 'M' ){
				$multiply = 1024 * 1024;
			} elsif ( $prefix eq 'G' ){
				$multiply = 1024 * 1024 * 1024;
			} elsif ( $prefix eq 'T' ){
				$multiply = 1024 * 1024 * 1024 * 1024;
			}; # if ( $prefix eq 'B' ){}
			
			my $FinalSize;
			my $SizeMulti = ($Size * $multiply);
			
			if ( $SizeMulti =~ /\./ ) {
				( $FinalSize, undef ) = split('\.', $SizeMulti );
			} else {
				$FinalSize = $SizeMulti;
			};
			
			# print "Final= $FinalSize ---- Given?= $GivenSizeInBytes\n";
			# select(undef, undef, undef, 0.005 );

			if ( $GivenSizeInBytes > $FinalSize ){
			#	print "Size Overflow: SizeFilter: '$Size' $FinalSize >= $GivenSizeInBytes\n";
			#	select(undef, undef, undef, 0.02 );
				return -1;	# sind equal
			} elsif ( $GivenSizeInBytes < $FinalSize ){
				return 0;
			}; # if ( $GivenSizeI ...

		}; # if ( $desc eq $type ) {}

	}; # foreach my $entry ( @{$ContentArrayRef} ) {}
	
	return 0;
	
}; # sub SizeFilter(){}

return 1;