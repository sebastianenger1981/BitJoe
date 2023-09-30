#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		Sortierung und Punktevergabe für die Ergebnisse
##### Todo:			hits vergabe / nach speed sortieren
########################################


# neue version:
# 1.) gehe das hash durch, und teste ob der dateityp des aktuellen hasheswertes -Dateitypes dem FileType laut Lizenzemanagement ist, 
# wenn ja speichere dies alles in ein separates hash
# 2.) ordne die dateiname aus dem neuen hash nach speed, Rank usw
# gib ergebnisse zurück


package MutellaProxy::SortRank;

use Sort::Array qw( Sort_Table );
use String::Approx 'amatch';
use MutellaProxy::Debug;
use File::Basename;
use strict;

my $VERSION = '0.22.1';

my $KeywordMatchingMultiply		= 5;
my $NegativMatchingQuantifier	= -100;
my $ApproxMatchingQuantifier	= "40%";
my $MaxSourcesForOneHit			= 20;
my $MaxScanningDepth			= 1000;


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub SortRank(){
	
	my $self			= shift;
	my $ResultHashRef	= shift;
	my $SearchQuery		= shift;
	my $FileTypeHashRef = shift;

	my $UnSortedHashRef			= {};
	my $SortedHashRef			= {};
	my $UnSortedHashRefCounter	= 0;
	my $SortedHashRefCounter	= 0;	# korrekt
	my @UNSORTED				= ();
	my @SORTED					= ();

	##### Merke: $FileTypeHashRef kommt von MutellaProxy::LicenceManagement->CheckLicence() machts so, 
	#####	dass in $FileTypeHashRef die Values immer Kleinbuchstaben sind zb. Ref->{1} = 'jpg'

	# wenn keine ergebnisse
	if ( keys %{$ResultHashRef} == 0 ) {
		print "SortRank.pm: Keine Gültigen Ergebnisse\n";
		my @EMPTY = ();
		return ( \@EMPTY );
	} else {
		print "SortRank.pm: Gültigen Ergebnisse Vor Vorsortierung: " . keys %{$ResultHashRef};
		print "\n";
	};
	
	# Gib Fehlerstatus zurück, wenn kein Suchbegriff übergeben wurde
	if ( length($SearchQuery) == 0 ) {
		warn "invalid SearchQuery";	# Später Fehlerstatusmeldungen absetzen
		my @EMPTY = ();
		return ( \@EMPTY );
	};


	# funzt: lösche den 
	my $TemporarySearchQuery = $SearchQuery;
	foreach my $undef ( 0..length($FileTypeHashRef->{1}) ){
		chop($TemporarySearchQuery);
	}; # foreach my $undef

	
	while( my ($key, $value) = each( %{$ResultHashRef} ) ) {
		
		my $FileName	= %{$ResultHashRef}->{ $key }->{ 'FN' };
		my $Speed		= %{$ResultHashRef}->{ $key }->{ 'SP' };
		my $SHA1		= %{$ResultHashRef}->{ $key }->{ 'SH' };
		my $Size		= %{$ResultHashRef}->{ $key }->{ 'SZ' };
		my $FileIndex	= %{$ResultHashRef}->{ $key }->{ 'FI' };
		my $PeerHost	= %{$ResultHashRef}->{ $key }->{ 'PH' };

		# Wenn die Einträge gültig sind und zb keines der Felder leer ist
		if ( length($FileName) > 0 && length($Speed) > 0 && length($SHA1) == 32 && length($Size) > 0 && length($FileIndex) > 0 && length($PeerHost) > 0 ) {
			
			# Wenn Peerhost eine gültige IP:Port Kombination ist und der Fileindex nummerisch
			if ( ( $PeerHost =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\:)(\d{1,})/ ) && ( $FileIndex =~ /(\d)/ ) ) {
				
				# Wenn der FileType des aktuell gefundenen Files mit dem FileType der Lizenzfunktion übereinstimmt
				my ( $OnlyFileName , $OnlyFileTyp ) = split(/[(\w)|(\d)]+(\.([^.]+?)$)/i, $FileName );
				if ( ( lc($OnlyFileTyp) eq $FileTypeHashRef->{1} ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/ ) ) {
				
					my $TempFileName = $FileName;

					$TempFileName =~ s/\./ /ig;
					$TempFileName =~ s/\-/ /ig;
					$TempFileName =~ s/\,/ /ig;
					$TempFileName =~ s/\+/ /ig;

					my $matched = 0;
					eval {
						$matched = amatch($FileName, $ApproxMatchingQuantifier, $TemporarySearchQuery);
					};

					# Wenn der Suchbegriff dem FileName entspricht
					if ( $FileName eq $TemporarySearchQuery ) {
						$NegativMatchingQuantifier = 0;
					} elsif ( lc($TemporarySearchQuery) eq lc($FileName) ) {
						$NegativMatchingQuantifier = 0;
					} elsif ( $FileName =~ /$TemporarySearchQuery/ig ) {
						$NegativMatchingQuantifier = 0;
					} elsif ( $matched == 1 ) {
						$NegativMatchingQuantifier = 0;

					} else {
						
						foreach my $SinglePartOfFilename ( split(' ', $TempFileName ) ) {
							foreach my $SinglePartSearchQuery ( split(' ', $TemporarySearchQuery ) ) {
								if ( lc($SinglePartOfFilename) eq lc($SinglePartSearchQuery) ) {
									$NegativMatchingQuantifier = 0;
								} elsif ( eval { $SinglePartOfFilename =~ /$SinglePartSearchQuery/ig } ) {
									$NegativMatchingQuantifier = 0;
								} else {
									# negativ modifier works here

								};	# if ( lc($SinglePartO...
							}; # foreach my $SinglePartSearchQuery ...
						}; # foreach my $SinglePartOfFilename ...
						
					}; # if ( $FileName eq $TemporarySearchQuery ) {}

					my $KeyWordMatching = 0;

					if ( length($OnlyFileName) != 0 ) {
						$KeyWordMatching = GetKeyWordMatching( length($SearchQuery) / length($OnlyFileName) ); 
					};

					# $UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $Speed . "\t\t";
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'PH' } = $PeerHost;
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'FN' } = $FileName;				
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'SH' } = $SHA1;
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'SZ' } = $Size;
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'FI' } = $FileIndex;
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'SP' } = $Speed;
					$UnSortedHashRef->{ $UnSortedHashRefCounter }->{ 'RK' } = ($KeyWordMatching + $Speed + $NegativMatchingQuantifier);
					
					delete $ResultHashRef->{$key};
					
					$UnSortedHashRefCounter++;

				}; # if (  ( lc($OnlyFileTyp) eq $FileTy ...

			}; # if ( ( $PeerHost  ...
	
		}; # if ( length($FileName) >  ..

	}; # while( my ($key, $value) = each( %{$ResultHashRef} ) ) {

	# Hash löschen
	%{$ResultHashRef} = ();

	print "SortRank.pm: Gültigen Ergebnisse Nach erster Sortierung: " . keys %{$UnSortedHashRef};
	print "\n";
	
	my $outer = 0;
	
	SUBELEMENT:
	while( my ($key, $value) = each( %{$UnSortedHashRef} ) ) {
	
	#	$outer++;
	#	next if ( $outer >= 300 );

		# $SortedHashRefCounter++;
		
		# print "Bearbeite inner=$inner\n";

		my $FileName	= %{$UnSortedHashRef}->{ $key }->{ 'FN' };
		my $Speed		= %{$UnSortedHashRef}->{ $key }->{ 'SP' };
		my $SHA1		= %{$UnSortedHashRef}->{ $key }->{ 'SH' };
		my $Size		= %{$UnSortedHashRef}->{ $key }->{ 'SZ' };
		my $FileIndex	= %{$UnSortedHashRef}->{ $key }->{ 'FI' };
		my $PeerHost	= %{$UnSortedHashRef}->{ $key }->{ 'PH' };
		my $SortRank	= %{$UnSortedHashRef}->{ $key }->{ 'RK' };
	
		$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $Speed . "\t\t";
		# $SortedHashRef->{ $SortedHashRefCounter }->{ 'FN' } = $FileName;				
		$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1;
		$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $Size;
		$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } = $SortRank;
	
		delete $UnSortedHashRef->{$key};

		my $inner = 0;

		NEXTSUBELEMENT:
		while( my ( $NextKey, $NextValue ) = each( %{$UnSortedHashRef} ) ) {

		#	$inner++;
		#	next SUBELEMENT if ( $inner >= $MaxScanningDepth );

			my $FileNameNext	= %{$UnSortedHashRef}->{ $NextKey }->{ 'FN' };
			my $SpeedNext		= %{$UnSortedHashRef}->{ $NextKey }->{ 'SP' };
			my $SHA1Next		= %{$UnSortedHashRef}->{ $NextKey }->{ 'SH' };
			my $SizeNext		= %{$UnSortedHashRef}->{ $NextKey }->{ 'SZ' };
			my $FileIndexNext	= %{$UnSortedHashRef}->{ $NextKey }->{ 'FI' };
			my $PeerHostNext	= %{$UnSortedHashRef}->{ $NextKey }->{ 'PH' };
			my $SortRankNext	= %{$UnSortedHashRef}->{ $NextKey }->{ 'RK' };
	
			if ( $SHA1 eq $SHA1Next ) {

				# Teste auf doppelte IPS
				my @IsDoublePeer		= split("\t\t", $SortedHashRef->{ $SortedHashRefCounter }->{'PH'} );
				my $IsDoublePeer		= '';
				my $BadCount			= 0;

				for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {
					my ( $peer, $index, $name ) = split(";", $IsDoublePeer[$i] );
					if ( $peer eq $PeerHostNext || $peer == $PeerHostNext ) {
						$BadCount++;
					}; # if ( $peer eq $PeerHostNext 
				}; # for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {}

				# wenn die ips $peer und $PeerHostNext sind nicht gleich
				if ( $BadCount == 0 ) {
					
					$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } .= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedNext . "\t\t";			
					$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } += ( $SpeedNext + $SortRankNext );  #  erhöhe den Ranking Wert des aktuellen Eintrages um den Speed des folgenden Eintrages mit gleicher SHA1 
					$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $SizeNext;
					$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1Next;

					#	$SortedHashRefCounter++;
					delete $UnSortedHashRef->{$NextKey};
					next NEXTSUBELEMENT;

				}; # if ( $BadCount == 0 ) {

			}; # if ( $SHA1 eq $SHA1Next || $SHA1 == $SHA1Next ) {

			# delete $UnSortedHashRef->{$NextKey};

		}; # while( my ( $NextKey, $NextValue ) = each( %{$UnSortedHashRef} ) ) {

		$SortedHashRefCounter++;

	}; # while( my ($key, $value) = each( %{$UnSortedHashRef} ) ) {

	%{$UnSortedHashRef}	= ();

	print "SortRank.pm: Keys vor allen Sortierungen: " .  keys %{$SortedHashRef};
	print "\n";


	# Einzelne Sortierung der Ergebnisse nach Speed für ein File
	while( my ($key, $value) = each( %{$SortedHashRef} ) ) {

		my $PH = %{$SortedHashRef}->{ $key }->{ 'PH' };
		my $SZ = %{$SortedHashRef}->{ $key }->{ 'SZ' };
		my $SH = %{$SortedHashRef}->{ $key }->{ 'SH' };
		my $RK = %{$SortedHashRef}->{ $key }->{ 'RK' };
		
		my ( @Temporary ) = split("\t\t", $PH);
		my $SortBySpeed;
		$PH ='';   # WICHTIG!!!

		my @SortBySpeed = Sort_Table(
			cols      => '4',
			field     => '4',
			sorting   => 'descending',
			structure => 'csv',
			separator => ';',
			data      => \@Temporary,
		);

		my $SourcesCounter = 0;

		# Setzte die nach Speed sortierten Einträge wieder zusammen
		# Ignoriere dabei falsche Werte ( if-Anweisungen )
		for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {
			my ( $peer, $index, $filename, $speed ) = split(";", $SortBySpeed[$j] );	# im dateinamen darf kein ";" vorkommen
			
				if ( $peer.';'.$index.';'.$filename ne ';;' ) {
					if ( $MaxSourcesForOneHit >= $SourcesCounter ){
						$PH .= $peer.';'. $index.';'. $filename. "\r\n";
						$SourcesCounter++;
					}; # if ( $SourcesCounter >=
				}; # if ( $peer.';'. $index. ..

		}; # for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {}
				
		# if ( ( length($PH) != 0 ) && ( length($SZ) != 0 ) && ( length($SH) != 0 ) ) {
			push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 
		# }; # if ( ( length($PH)  ...

	};	# while( my ($key, $value) = each( %{$SortedHashRef} ) ) {}


	%{$SortedHashRef}	= ();
	
	print "SortRank.pm: Unsortierte Keys $#UNSORTED \n";

	# eigentliche Sortierung nach SortRank durchführen
	@SORTED = Sort_Table(
		cols      => '4',
		field     => '1',
		sorting   => 'descending',
		structure => 'csv',
		separator => '###',
		data      => \@UNSORTED,
	); # @SORTED = Sort_Table()


	print "SortRank.pm: Sortierte Keys $#SORTED \n";
	sleep 2;

	return ( \@SORTED ) ;


}; # sub SortRank(){}


sub GetKeyWordMatching(){

	my $int = shift;
	return sprintf ("%.2f", $int) * $KeywordMatchingMultiply;
		
}; # GetKeyWordMatching(){}


		 # FormatCheck
		# print "##################### \n";
		# print "DATEINAME:$FileNameForMatching \n";
		# print "ONLYFN:	 $OnlyFileName\n";
		# print "DATEITYP: $OnlyFileTyp \n";
			
		# für jeden Formatwunsch des Clients, teste den dateinamen des aktuell gefunden Files mit jedem formatwunsch
		# foreach my $key ( each( %{$FileTypeHashRef} ) ) {
		#	if (  ( lc($OnlyFileTyp) eq $FileTypeHashRef->{ $key } ) && ( length($FileTypeHashRef->{ $key }) != 0 ) && ( length($OnlyFileTyp) != 0 ) ) {
		#		$AllowedFileTypeFlag++;
		#	};
		#};  # foreach my $key ( each( %{$FileTypeHashRef} ) ) {}
		##### FormatCheck: <ende


return 1;