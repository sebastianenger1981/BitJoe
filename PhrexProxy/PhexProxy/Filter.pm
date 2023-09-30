#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		verschiede Filter für die Results
##### Todo:			eventuell die filter datei schon als Array mit in diese Datei einbauen, damit nicht soviele IO zugriffe gemacht werden müssen
########################################

package PhexProxy::Filter;

use PhexProxy::IO;
use strict;


#	FORMATBILD=200K
#	FORMATMP3=6M
#	FORMATRING=200K
#	FORMATVIDEO=15M
#	FORMATJAVA=350K
#	FORMATDOC=500K


my $SIZEFILTER						= '/server/phexproxy/filter/sizefilter.dat';
my $SizeFilerContentArrayRef		= PhexProxy::IO->ReadFileIntoArray( $SIZEFILTER );	# later: read it into memory on Module compile
my $StringLengthIndicateSpamResult	= 2999;		# 3000% - wenn ein result $StringLengthIndicateSpamReasult % länger ist als der suchbegriff, dann ist es ein spam result und bekommt 0 punkte im ranking


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # sub new(){}


sub SpamFilter(){

	my $self		= shift;
	my $FileName	= shift;
	my $SearchQuery	= shift;
	$SearchQuery	= lc($SearchQuery);
	
	my $IsSpamFlag	= $self->ClassifySpamResult($SearchQuery,$FileName);	#1=spam | 0=kein spam

	if ( $FileName =~ /[(\w)|(\d)|(\s)]+\.(com|net|org|biz|de|info|tv|vu|eu|at|ch)/i) {
		return -1;	# sind equal
	} elsif ( $FileName =~ /[(\w)|(\d)|(\s)]+\.(zip|arj|rar|exe|com)/i) {
		return -1;	# sind equal
	} elsif ( $FileName eq "$SearchQuery-xxx.wmv" || $FileName =~ /$SearchQuery-xxx\.wmv/i ) {
		return -1;	# sind equal
	} elsif ( $FileName eq "$SearchQuery.wmv" || $FileName =~ /$SearchQuery\.wmv/i ) {
		return -1;	# sind equal
	} elsif ( $IsSpamFlag == 1 ) {
		return -1;
	}; # if ( ${$FileName} =~

	return 1;
	
};  # sub UrlFilter(){}


sub ClassifySpamResult(){
	
	my $self				= shift;
	my $SearchString		= shift;
	my $ResultString		= shift;

	my $SearchStringLength	= length($SearchString);
	my $ResultStringLength	= length($ResultString);
	
	# wenn ein result ($StringLengthIndicateSpamReasult/100)% länger ist als der suchbegriff, dann ist es ein spam result und bekommt 0 punkte im ranking
	if (  $ResultStringLength >= ( $SearchStringLength * ($StringLengthIndicateSpamResult / 100) ) ) {
		return 1; # es ist ein spam result
	};
	
	return 0;	  # es ist kein spam result
		
}; # sub ClassifySpamResult(){


sub SizeFilter(){

	my $self				= shift;
	my $type				= shift;
	my $GivenSizeInBytes	= shift;

	my $multiply;

	foreach my $entry ( @{$SizeFilerContentArrayRef} ) {
		
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
		
			my $FinalSize = sprintf("%.0f", $Size * $multiply );

		#	my $FinalSize;
		#	my $SizeMulti = ($Size * $multiply);
		#	
		#	if ( $SizeMulti =~ /\./ ) {
		#		( $FinalSize, undef ) = split('\.', $SizeMulti );
		#	} else {
		#		$FinalSize = $SizeMulti;
		#	};
			
			# print "Final= $FinalSize ---- Given?= $GivenSizeInBytes\n";
			
			if ( $GivenSizeInBytes > $FinalSize ){
			#	print "Size Overflow: SizeFilter: '$Size' $FinalSize >= $GivenSizeInBytes\n";
				return -1;	# sind equal
			} elsif ( $GivenSizeInBytes <= $FinalSize ){
				return 1;
			}; # if ( $GivenSizeI ...

		}; # if ( $desc eq $type ) {}

	}; # foreach my $entry ( @{$ContentArrayRef} ) {}
	
	return 1;
	
}; # sub SizeFilter(){}

return 1;