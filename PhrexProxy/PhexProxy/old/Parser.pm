#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		Parsing von Daten
##### Todo:			
########################################

package PhexProxy::Parser;

use PhexProxy::SpamFilter;
use PhexProxy::IPFilter;
use PhexProxy::Filter;
use PhexProxy::IO;
use strict;

use constant LIST_COMMAND		=> "list \n"; 
use constant RESULTS_COMMAND	=> "results "; 
use constant INFO_COMMAND		=> "info \n";
use constant CLOSE_COMMAND		=> "close ";

my $VERSION = '0.22.5';

my $SpeedRankingPointsforModem	= 1;
my $SpeedRankingPointsforISDN	= 2;
my $SpeedRankingPointsforDSL	= 4;
my $SpeedRankingPointsforCable	= 4;
my $SpeedRankingPointsforT1		= 6;
my $SpeedRankingPointsforT3		= 7;


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub CheckSharingRatio(){

	my $self			= shift;
	my $MutellaSocket	= shift || PhexProxy::IO->CreateMutellaSocket();

	my $list;

	while ( length($list) == 0 ) {
		PhexProxy::IO->writeSocket( $MutellaSocket, INFO_COMMAND );
		$list = PhexProxy::IO->readSocket( $MutellaSocket );
		select( undef, undef, undef, 0.2 );
	};

	my @content	= split("\n", $list );
	my @BadIPs  = ();
	my $content;
	my $BadIPs;

	for ( my $i=0; $i<=$#content; $i++ ) {
		my ( @LineContent ) = split(' ', $content[$i]);
		my $LineContent;
		my $IsBadIP = '';
		
		for ( my $j=0; $j<=$#LineContent; $j++ ) {
			if ( $LineContent[$j] =~ /[\d{1,}]+[\)]/i ) {
				# print "Bad Sharing Ratio: $LineContent[$j] \n";
				$IsBadIP = $LineContent[$j];
			}; 
			if ( $LineContent[$j] =~ /[\d]+\/+[\d]+(K|M)/ ) {
				chop($IsBadIP);
				chop($LineContent[$j]);
				# print "$IsBadIP Host sharing $LineContent[$j]\n";
				if ( length($IsBadIP) > 0 ){
					push(@BadIPs, "$IsBadIP#$LineContent[$j]\n" );
				};
				$IsBadIP = '';
			}; # if ( $LineContent[$j] ...
		}; # for ( my $j=0; $j<=$#LineContent; $j++ ) {

	};	# for ( my $i=0; $i<=$#content; $i++ ) {}

	for ( my $a=0; $a<=$#BadIPs; $a++ ) {

		my ($Peer,$Ratio) = split('#', $BadIPs[$a] );
		# print "Bad Sharing Ratio: '$Ratio': $Peer\n";
		PhexProxy::IO->writeSocket( $MutellaSocket, CLOSE_COMMAND . "$Peer\n" );	

	}; # for ( my $a=0; $a<=$#BadIPs; $a++ ) {}

	return 1;

}; # sub CheckSharingRatio(){}


sub InfoCommandParser(){

	# zähle die ultrapeers

	my $self			= shift;
	my $MutellaSocket	= shift;

	my $ResultCount		= 0;
	my $content;
	my $list;

	while ( length($list) == 0 ) {
		PhexProxy::IO->writeSocket( $MutellaSocket, INFO_COMMAND );
		$list = PhexProxy::IO->readSocket( $MutellaSocket );
		select( undef, undef, undef, 0.2 );
	};
		
	my @content	= split("\n", $list );

	for ( my $i=0; $i<=$#content; $i++ ) {
		if ( $content[$i] =~ /[\d{1,}]+[\)]+[\s{1,}]/i ){ 
			$ResultCount++;		
		};
	};	# for ( my $i=0; $i<=$#content; $i++ ) {}

	@content = ();

	return $ResultCount;

}; # sub InfoCommandParser(){}


sub ResultCommandParser(){
	
	# todo: erst in hashref schreiben, wenn die dazugehörigen werte auch definiert sind, sprich keine NULL werte in hashref schreiben
	
	my $self 			= shift;
	my $MutellaSocket	= shift;
	my $ResultNumber	= shift;
	my $FileTypeHashRef	= shift;
	my $SearchQuery		= shift;

	my $list;
	my $content;
	my $ResultCount		= 0;
	my $DownloadHashRef = {};
	
	# solange keine Results über den Unix Socket von Mutella reinkommen 
	# stelle einen requery an mutella
	
	while ( length($list) == 0 ) {
		PhexProxy::IO->writeSocket( $MutellaSocket, RESULTS_COMMAND . $ResultNumber . " \n" );
		$list = PhexProxy::IO->readSocket( $MutellaSocket );
		select( undef, undef, undef, 0.2 );
	};

	my @content	= split("\n", $list );

	NEXTELEMENT:
	for ( my $i=0; $i<=$#content; $i++ ) {
				
		if ( $content[$i] =~ /RSID:+[\s{1}]+[\d{1,}]+[\)]/i ){ 
					
			#	my ( undef, $RESOURCE ) = split('RSID: ', $content[$i] );
			#	$RESOURCE =~ s/\) //;
			#	chomp($RESOURCE);
			#	$DownloadHashRef->{ $ResultCount }->{ 'ID' } = $RESOURCE;
			
		} elsif ( $content[$i] =~ /^[\s{1}]+NAME:+[\s{1}]/i ){	
			
			my ( undef, $FILENAME ) = split('NAME: ', $content[$i] );
			$FILENAME =~ s/[\s{1}]$//;
			chomp($FILENAME);
						
			my $StatusA = PhexProxy::SpamFilter->SpamFilter( \$FILENAME, $SearchQuery );
			if ( $StatusA == -1 ) {
				# print "PARSER.PM: FAKEFILE $FILENAME\n";
				
				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';

				# delete $DownloadHashRef->{ $ResultCount };
				# undef $DownloadHashRef->{ $ResultCount };
				next NEXTELEMENT;
			};
			
			# nur gültige Einträge zulassen
			if ( length($FILENAME) > 0 ) {
				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = $FILENAME;
			} else {
				# $DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				# delete $DownloadHashRef->{ $ResultCount };
				# undef $DownloadHashRef->{ $ResultCount };
				
				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';

			}; # if ( length() > 0 ) {}

		} elsif ( $content[$i] =~ /^[\s{1}]+SIZE:+[\s{1}]+[\d+(B|K|M|G)]/ ){
			
			my ( undef, $SIZE ) = split('SIZE: ', $content[$i] );	
			$SIZE =~ s/[\s{1}]$//;
			chomp($SIZE);
			
			my $multiply = 1;
			my ( $number, $prefix ) = split(/(B|K|M|G)/i, $SIZE ); 

			if ( $prefix eq 'B' ) {
				$multiply = 1;
			} elsif ( $prefix eq 'K' ){
				$multiply = 1024;
			} elsif ( $prefix eq 'M' ){
				$multiply = 1024 * 1024;
			} elsif ( $prefix eq 'G' ){
				$multiply = 1024 * 1024 * 1024;
			} elsif ( $prefix eq 'T' ){
				$multiply = 1024 * 1024 * 1024 * 1024;
			}; # if ( $prefix eq 'B' ) {}

			my ( $SIZE, undef ) = split('\.', ($number * $multiply) );
			my $StatusB = PhexProxy::Filter->SizeFilter( $FileTypeHashRef->{ 1 }, $SIZE );
			if ( $StatusB == -1 ) {
				# print "PARSER.PM: SIZE OVERFLOW\n";
				# $DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				# delete $DownloadHashRef->{ $ResultCount };
				# undef $DownloadHashRef->{ $ResultCount };
				
				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';

				next NEXTELEMENT;
			};

			# nur gültige Einträge zulassen
			if ( length($SIZE) > 0 ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = $SIZE;
			} else {
				#	$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				#	delete $DownloadHashRef->{ $ResultCount };
				#	undef $DownloadHashRef->{ $ResultCount };
			
				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';
			
			}; # if ( length() > 0 ) {}

		} elsif ( $content[$i] =~ /^[\s{1}]+SHA1:+[\s{1}]/ ){
			
			my ( undef, $SHA1 ) = split('SHA1: ', $content[$i] );	
			$SHA1 =~ s/[\s{1}]$//;
			chomp($SHA1);
						
			# nur gültige Einträge zulassen
			if ( length($SHA1) == 32 ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = $SHA1;
			} else {
				#	delete $DownloadHashRef->{ $ResultCount };
				#	undef $DownloadHashRef->{ $ResultCount };

				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';

			}; # if ( length() > 0 ) {}

		} elsif ( $content[$i] =~ /^[\s{1}]+FIDX:+[\s{1}]/ ){
			
			my ( undef, $INDEX ) = split('FIDX: ', $content[$i] );	
			$INDEX =~ s/[\s{1}]$//;
			chomp($INDEX);
						
			# nur gültige Einträge zulassen
			if ( length($INDEX) > 0 ) {
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = $INDEX;
			} else {
				#	delete $DownloadHashRef->{ $ResultCount };
				#	undef $DownloadHashRef->{ $ResultCount };

				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';


			}; # if ( length() > 0 ) {}

		} elsif ( $content[$i] =~ /^[\s{1}]+PEER:+[\s{1}]+(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\:)(\d{1,})/ ){
		
			my ( undef, $PEER ) = split('PEER: ', $content[$i] );		
			$PEER =~ s/[\s{1}]$//;
			chomp($PEER);

			# checke, ob $PEER eine gebannte IP ist: Start
			my $StatusC = PhexProxy::IPFilter->SimpleFilter( $PEER );
			if ( $StatusC == -1 ) {
				#	$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				#	delete $DownloadHashRef->{ $ResultCount };
				#	undef $DownloadHashRef->{ $ResultCount };

				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';

				next NEXTELEMENT;
			};
			# checke, ob $PEER eine gebannte IP ist: Ende

			# nur gültige Einträge zulassen
			if ( length($PEER) > 0 ) {
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = $PEER;
			} else {
				#	$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				#	delete $DownloadHashRef->{ $ResultCount };
				#	undef $DownloadHashRef->{ $ResultCount };

				$DownloadHashRef->{ $ResultCount }->{ 'FN' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SZ' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'FI' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'PH' } = '';
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = '';


			}; # if ( length() > 0 ) {}
				
		} elsif ( $content[$i] =~ /^[\s{1}]+FAST:+[\s{1}]/ ){ 
	
			my ( undef, $SPEED ) = split('FAST: ', $content[$i] );	
			$SPEED =~ s/[\s{1}]$//;
			chomp($SPEED);

			if ( $SPEED eq 'T1' ){
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforT3;
			} elsif ( $SPEED eq 'T3' ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforT1;
			} elsif ( $SPEED eq 'Cable' ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforCable;
			} elsif ( $SPEED eq 'DSL' ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforDSL;
			} elsif ( $SPEED eq 'ISDN' ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforISDN;
			} elsif( $SPEED =~ /Modem/i ) {
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforModem;
			} else {
				$DownloadHashRef->{ $ResultCount }->{ 'SP' } = $SpeedRankingPointsforModem;
			};

			$DownloadHashRef->{ $ResultCount }->{ 'RK' } = '0';	# overall Ranking points
			
		} elsif ( $content[$i] =~ /^[\s{1}]+FLAG:+[\s{1}]/ ){ 
			
		#	my ( undef, my $VERSION ) = split('FLAG: ', $content[$i] );
		#	my $VERSION =~ s/[\s{1}]$//;
		#	chomp($VERSION);
		
			$ResultCount++;
			
		}; # if ( $content[$i] =~ /RSID:+[\s{1}]+[\d{1,}]+[\)]/i ){ }

	}; # foreach my $content[$i] ( @content ) {}	

	# use Data::Dumper;
	# print Dumper($DownloadHashRef);
	
	return $DownloadHashRef;
	

}; # sub ResultCommandParser(){}


sub ListCommandParser(){
		
	my $self 			= shift;
	my $MutellaSocket	= shift;

	my $list;
	my $content;
	my $tmp_entry_count;
	my $tmp_entry_search;
	my $tmp_result_count;
	my $listHashRef = {};
	
	while ( length($list) == 0 ) {
		PhexProxy::IO->writeSocket( $MutellaSocket, LIST_COMMAND );
		$list = PhexProxy::IO->readSocket( $MutellaSocket );
		select( undef, undef, undef, 0.2 );
	};

	my @content = split("\n", $list );

	for ( my $i=0; $i<=$#content; $i++ ) {
		
		if ( $content[$i] =~ /[\d{1,}][\)]/ ) {	# wenn ein Eintrag lautet '  4)' dann ...
			
			# extrahiere die Zahl zu der ein Ergebnis gehört
			( $tmp_entry_count, $tmp_entry_search ) = split('\)', $content[$i] );
			$tmp_entry_count	=~ s/[\s]//;
			$tmp_entry_search	=~ s/[\s]//;
			
			# entferne unnötige zeichen aus dem Suchbegriff
			eval { substr( $tmp_entry_search, 0, 1 ) = ""; };		# schneide erstes zeichen ab
			eval { substr( $tmp_entry_search, length($tmp_entry_search) - 1, length($tmp_entry_search) ) = "";	}; # schneide letztes zeichen ab
			
		} elsif ( $content[$i] =~ /^[\s{4,}]/ ) {	# eventuell kleinere Zahl hier nehmen, wenn der Abstand zwischen SizeFilter und HIT Result zu klein wird
			
			my ( undef, $temp ) = split(/\s{5,}/, $content[$i] ); 
			if ( $temp eq "NO HITS" ) {
				$tmp_result_count = 0;
			} else {
				( undef, $tmp_result_count ) = split(':', $temp);
			};

			$listHashRef->{ $tmp_entry_count }{ 'SEARCH' }	= $tmp_entry_search;
			$listHashRef->{ $tmp_entry_count }{ 'RESULTS' } = $tmp_result_count;

		}; # } elsif ( $content[$i] =~ /^[\s{4,}]/ ) {}

	}; # for ( my $i=0; $i<=$#content; $i++ ) {}

	return $listHashRef;	

}; # sub ListCommandParser(){}


return 1;