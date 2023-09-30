#!/usr/bin/perl -I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.2006
##### Function:		Sortierung und Punktevergabe für die Ergebnisse
##### Todo:			hits vergabe / nach speed sortieren
########################################

package MutellaProxy::SortRank;

use Sort::Array qw( Sort_Table );
use String::Approx 'amatch';
use MutellaProxy::Debug;
use File::Basename;
use strict;

my $VERSION = '0.22.1';

my $KeywordMatchingMultiply		= 5;
my $HitsMatchingMultiply		= 0.1;
my $NegativMatchingQuantifier	= -100;
my $ApproxMatchingQuantifier	= "20%";

sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub SortRank(){
	
	my $self			= shift;
	my $ResultHashRef	= shift;
	my $SearchQuery		= shift;
	my $FileTypeHashRef = shift;

	my $KeyWordMatching			= 0;
	my $SortedHashRef			= {};
	my $SortedHashRefCounter	= 0;
	my @UNSORTED				= ();
	my @SORTED					= ();
	my $multiply;

	##### Merke: $FileTypeHashRef kommt von MutellaProxy::LicenceManagement->CheckLicence() machts so, 
	#####	dass in $FileTypeHashRef die Values immer Kleinbuchstaben sind zb. Ref->{1} = 'jpg'

	# wenn keine ergebnisse
	if ( keys %{$ResultHashRef} == 0 ) {
		print "SortRank.pm: Keine Gültigen Ergebnisse\n";
		my @EMPTY = ();
		return ( \@EMPTY );
	} else {
		print "SortRank.pm: Gültigen Ergebnisse " . keys %{$ResultHashRef};
		print "\n";
	};
	
	# Gib Fehlerstatus zurück, wenn kein Suchbegriff übergeben wurde
	if ( length($SearchQuery) == 0 ) {
		warn "invalid SearchQuery";	# Später Fehlerstatusmeldungen absetzen
		my @EMPTY = ();
		return ( \@EMPTY );
	};

	MAINWHILE:
	while( my ($key, $value) = each( %{$ResultHashRef} ) ) {
			
		my $hits = 0;
	 
		###### Matching des gefundenen Filenames mit dem eigentlichen Suchbegriff: Start
		my $FileNameForMatching = %{$ResultHashRef}->{ $key }->{ 'FN' };
		
		if ( $SearchQuery eq $FileNameForMatching ) {
			$hits = 10;	# gibt genau einen Punkt mehr, bei haargenauem treffer
		} elsif ( lc($SearchQuery) eq lc($FileNameForMatching) ) {
			$hits = 5;
		} elsif ( lc($SearchQuery) eq $FileNameForMatching ) {
			$hits = 5;
		} elsif ( $SearchQuery eq lc($FileNameForMatching) ) {
			$hits = 5;
		} elsif ( eval { $SearchQuery =~ /$FileNameForMatching/ } ) {
			$hits = 3;
		} elsif ( eval { $SearchQuery =~ /$FileNameForMatching/ig }) {
			$hits = 2;
		} else {

			foreach my $SinglePartOfFilename ( split(' ', $FileNameForMatching ) ) {
				foreach my $SinglePartSearchQuery ( split(' ', $SearchQuery ) ) {
					if ( lc($SinglePartOfFilename) eq lc($SinglePartSearchQuery) ) {
							$hits++;
					} elsif ( eval { $SinglePartOfFilename =~ /$SinglePartSearchQuery/ig } ) {
							$hits++;
					} else {
					#	print "SORTRANK: $SinglePartSearchQuery und $SinglePartOfFilename\n";	
					};	# if ( lc($SinglePartO...
				}; # foreach my $SinglePartSearchQuery ...
			}; # foreach my $SinglePartOfFilename ...
		
		}; # if ( $SearchQuery eq $FileNameForMatching ) {}
		###### Matching des gefundenen Filenames mit dem eigentlichen Suchbegriff: Ende

	   # $hits++;

		###### Auswertung der Punkte
		if ( $hits == 0 ) {
			# keine Trefferübereinstimmung darum zählt der $NegativMatchingQuantifier 
		} else {
			$NegativMatchingQuantifier = ($HitsMatchingMultiply*$hits);
		}; 	# if ( $hits == 0 ) {}
	

		# eval {	substr($TempFileName, length($TempFileName) - 4, length($TempFileName) ) = ""; };
		# OLD VERSION:  my ( $OnlyFileName, $OnlyFileTyp ) = split(/[(\w)|(\d)]+\.(.*?)$/i, $FileNameForMatching );

		my ( $OnlyFileName , $OnlyFileTyp ) = split(/[(\w)|(\d)]+(\.([^.]+?)$)/i, $FileNameForMatching );
	
		if ( length($OnlyFileName) == 0 || length( $OnlyFileTyp) == 0 ){
			delete $ResultHashRef->{ $key };
			next MAINWHILE;
		};
		
		##### FormatCheck: Start
		my $AllowedFileTypeFlag = 0;

		if (  ( lc($OnlyFileTyp) eq $FileTypeHashRef->{1} ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{ 1 }/ ) ) {
			$AllowedFileTypeFlag++;
		}; # if (  ( lc($OnlyFileTyp) eq $FileTy ...


		if ( $AllowedFileTypeFlag > 0 ) {
			
			# Berechne das KeyWordMatching
			if ( length($OnlyFileName) != 0 ) {
				$KeyWordMatching = GetKeyWordMatching( length($SearchQuery) / length($OnlyFileName) ); 
			};

			my $FileName	= %{$ResultHashRef}->{ $key }->{ 'FN' };
			my $Speed		= %{$ResultHashRef}->{ $key }->{ 'SP' };
			my $SHA1		= %{$ResultHashRef}->{ $key }->{ 'SH' };
			my $Size		= %{$ResultHashRef}->{ $key }->{ 'SZ' };
			my $FileIndex	= %{$ResultHashRef}->{ $key }->{ 'FI' };
			my $PeerHost	= %{$ResultHashRef}->{ $key }->{ 'PH' };

			# print "SORTRANK: $OnlyFileName und $FileName\n";

			my $matched;

			eval {
				$matched = amatch($OnlyFileName, $ApproxMatchingQuantifier, $FileName);
			};

			if ( ($matched == 1) || (length( $FileName ) != 0) || ( $OnlyFileName =~ /$FileName/ ) || ( lc($OnlyFileName) eq lc($FileName) ) ){ 	
			
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'FN' } = $FileName;				
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $Size;
				
				if ( ( $PeerHost =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\:)(\d{1,})/ ) && ( $FileIndex =~ /(\d)/ ) ) {
					# print "$PeerHost und $FileIndex\n";
					$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $Speed . "\t\t"; # "\r\n";
				};

				$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } = ($KeyWordMatching + $Speed + $NegativMatchingQuantifier);
				
				# füge hinzu und lösche den bearbeiteten eintrag
				delete $ResultHashRef->{ $key };

			} else {
				delete $ResultHashRef->{ $key };
			};

			NEXTSUBELEMENT:
			while( my ( $NextKey, $NextValue ) = each( %{$ResultHashRef} ) ) {
			
				my ( $NextOnlyFileName , $NextOnlyFileTyp ) = split(/[(\w)|(\d)]+(\.([^.]+?)$)/i, %{$ResultHashRef}->{ $NextKey }->{ 'FN' } );
			
				if ( length($NextOnlyFileName) == 0 || length( $NextOnlyFileTyp ) == 0 ){
					delete $ResultHashRef->{ $NextKey };
					next NEXTSUBELEMENT;
				};
				
				my $NextAllowedFileTypeFlag = 0;

				if (  ( lc($NextOnlyFileTyp) eq $FileTypeHashRef->{1} ) || ( lc($NextOnlyFileTyp) =~ /$FileTypeHashRef->{ 1 }/ ) ) {
					$NextAllowedFileTypeFlag++;
				}; # if (  ( lc($OnlyFileTyp) eq $FileTy ...

				if ( $NextAllowedFileTypeFlag > 0 ) {

					my $FileNameNext	= %{$ResultHashRef}->{ $NextKey }->{ 'FN' };
					my $SpeedNext		= %{$ResultHashRef}->{ $NextKey }->{ 'SP' };
					my $SHA1Next		= %{$ResultHashRef}->{ $NextKey }->{ 'SH' };
					my $SizeNext		= %{$ResultHashRef}->{ $NextKey }->{ 'SZ' };
					my $FileIndexNext	= %{$ResultHashRef}->{ $NextKey }->{ 'FI' };
					my $PeerHostNext	= %{$ResultHashRef}->{ $NextKey }->{ 'PH' };
		
					# if ( ($SHA1 eq $SHA1Next) && (length( $FileNameNext ) != 0) && (length( $PeerHostNext ) != 0) && (length( $FileIndexNext ) != 0) ) {
					
					if ( $SHA1 eq $SHA1Next || $SHA1 == $SHA1Next ) {
						
						my @IsDoublePeer = split("\t\t", $SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' });
						my $IsDoublePeer;
						my $BadCount = 0;

						for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {
							my ( $peer, $index, $name ) = split(";", $IsDoublePeer[$i] );
							if ( $peer eq $PeerHostNext || $peer == $PeerHostNext ) {
								$BadCount++;
							}; # if ( $peer eq $PeerHostNext 
						}; # for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {}

						# wenn die ips $peer und $PeerHostNext sind nicht gleich
						if ( $BadCount == 0 ) {
						
							if ( ( $PeerHostNext =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\:)(\d{1,})/ ) && ( $FileIndexNext =~ /(\d)/ ) ) {
								# print "$PeerHostNext und $FileIndexNext\n";
								$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } .= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedNext . "\t\t"; # "\r\n"; 					
							};

							# erhöhe den Ranking Wert des aktuellen Eintrages um den Speed des folgenden Eintrages mit gleicher SHA1 
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } += $SpeedNext; 
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $SizeNext;
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1Next;
							
						};	# if ( $BadCount == 0 ) {}

						delete $ResultHashRef->{ $NextKey };
						next NEXTSUBELEMENT;	# kann eigentlich hier weg ^^
										
					}; # if ( $SHA1 eq $SHA1Next ) {}
				
				};  # if ( $NextAllowedFileTypeFlag > 0 ) {

			};	# while( my ($NextKey,$NextValue) = each( %{$SortedHashRef} ) ) {}
	
			$SortedHashRefCounter++;	

		};	# if ( $AllowedFileTypeFlag > 0 ) {
		  
	};	# while( my ($key,$value) = each( %{$ResultHashRef} ) ) {}

	# Hash löschen
	%{$ResultHashRef} = ();

	print "SortRank.pm: Keys vor allen Sortierungen: " .  keys %{$SortedHashRef};
	print "\n";

	# Einzelne Sortierung der Ergebnisse nach Speed für ein File
	foreach my $ResultCount ( keys %{$SortedHashRef} ) {
	
		my $PH = %{$SortedHashRef}->{ $ResultCount }->{ 'PH' };
		my $SZ = %{$SortedHashRef}->{ $ResultCount }->{ 'SZ' };
		my $SH = %{$SortedHashRef}->{ $ResultCount }->{ 'SH' };
		my $RK = %{$SortedHashRef}->{ $ResultCount }->{ 'RK' };
		
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

		# Setzte die nach Speed sortierten Einträge wieder zusammen
		# Ignoriere dabei falsche Werte ( if-Anweisungen )
		for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {
			my ( $peer, $index, $filename, $speed ) = split(";", $SortBySpeed[$j] );	# im dateinamen darf kein ";" vorkommen
			
			if ( length($peer) > 0 && length($index) > 0 && length($filename) > 0  ) {
			
				if ( $peer.';'.$index.';'.$filename ne ';;' ) {
					$PH .= $peer.';'. $index.';'. $filename. "\r\n";
				}; # if ( $peer.';'. $index. ..

			}; # if ( length($peer) ..

		}; # for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {}
				
		if ( ( length($PH) != 0 ) && ( length($SZ) != 0 ) && ( length($SH) != 0 ) ) {
			push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 
		}; # if ( ( length($PH)  ...

	};	# foreach my $ResultCount ( keys %{$SortedHashRef} ) {}
	
	print "SortRank.pm: $#UNSORTED UNSORTED \n";

	if ( $#UNSORTED > 0 ) {
	
		# eigentliche Sortierung nach SortRank durchführen
		@SORTED = Sort_Table(
			cols      => '4',
			field     => '1',
			sorting   => 'descending',
			structure => 'csv',
			separator => '###',
			data      => \@UNSORTED,
		); # @SORTED = Sort_Table()

	}; # if ( $#UNSORTED > 0 ) {}

	%{$SortedHashRef}	= ();
	
	print "SortRank.pm: $#SORTED SORTED \n";

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