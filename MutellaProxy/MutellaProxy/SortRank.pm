#!/usr/bin/perl -I/server/mutella/MutellaProxy
package PhexProxy::PhexSortRank;

package MutellaProxy::SortRank;

use Sort::Array qw( Sort_Table );
use String::Approx 'amatch';
use MutellaProxy::Debug;
use File::Basename;
use strict;

# hinweis: momentan wird die unteren for iteration nur 20 mal durchgegangen!
#use integer;

my $MaxFileLength				= 10000;
my $KeywordMatchingMultiply		= 5;
my $NegativMatchingQuantifier	= -100;
my $ApproxMatchingQuantifier	= "40%";
my $MaxSourcesForOneHit			= 5;
#my $MaxScanningDepth			= 1000;


# speed related Things
my $SpeedRankingPointsforModem	= 1;
my $SpeedRankingPointsforISDN	= 2;
my $SpeedRankingPointsforDSL	= 4;
my $SpeedRankingPointsforCable	= 4;
my $SpeedRankingPointsforT1		= 6;
my $SpeedRankingPointsforT3		= 7;

my $IsSpeedModem				= 56;	
my $IsSpeedISDN					= 64;
my $IsSpeedDSL					= 1024;
my $IsSpeedCable				= 2048;
my $IsSpeedT1					= 4096;
my $IsSpeedT3					= 6144;


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()



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

	my $ResultContent;
	my @ResultContent			= ();
	my @UNSORTED				= ();
	my @SORTED					= ();
	my $SortedHashRef			= {};
	my $SortedHashRefCounter	= 0;


	##### Merke: $FileTypeHashRef kommt von MutellaProxy::LicenceManagement->CheckLicence() machts so, 
	#####	dass in $FileTypeHashRef die Values immer Kleinbuchstaben sind zb. Ref->{1} = 'jpg'

	# wenn keine ergebnisse
	if ( keys %{$ResultHashRef} == 0 ) {
		print "SortRank.pm: Keine Gültigen Ergebnisse\n";
		my @EMPTY = ();
		return ( \@EMPTY );
	} else {
		print "SortRank.pm: Gültigen Results von Parser.pm: " . keys %{$ResultHashRef};
		print "\n";
	};
	
	# Gib Fehlerstatus zurück, wenn kein Suchbegriff übergeben wurde
	if ( length($SearchQuery) == 0 ) {
		warn "invalid SearchQuery";	# Später Fehlerstatusmeldungen absetzen
		my @EMPTY = ();
		return ( \@EMPTY );
	};

	# trenne den Search Query an ' .' auf
	my ( $TemporarySearchQuery, undef) = split(' .', $SearchQuery); # geht von solchen suchbegriffen aus "Suchbegriff .jpg"
	

	
	my $ResultHashRefCount = keys(%{$ResultHashRef});
	
	for ( my $key=0; $key<=$ResultHashRefCount; $key++ ) {
		
		my $FileName	= %{$ResultHashRef}->{ $key }->{ 'FN' };
		my $Speed		= %{$ResultHashRef}->{ $key }->{ 'SP' };
		my $SHA1		= %{$ResultHashRef}->{ $key }->{ 'SH' };
		my $Size		= %{$ResultHashRef}->{ $key }->{ 'SZ' };
		my $FileIndex	= %{$ResultHashRef}->{ $key }->{ 'FI' };
		my $PeerHost	= %{$ResultHashRef}->{ $key }->{ 'PH' };

		# my ($Speed,$SHA1,$Size,$FileIndex,$PeerHost,$FileName) = split(/\;\!\$\#\%\&/, $_);	# ;!$#%& 
			
		# filelänge auf $MaxFileLength zeichen begrenzen
		if ( (length($FileName) > 0) && (length($FileName) <= $MaxFileLength) && (length($Speed) > 0) && (length($SHA1) == 32) && (length($Size) > 0) && (length($FileIndex) > 0) && ($PeerHost =~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ && length($PeerHost) >= 9) ) {	# 9 ist minimale gültige ip:port combi
			
			my ( $OnlyFileName , $OnlyFileTyp ) = split(/(\.([^.]+?)$)/i, $FileName );	# funzt auch korrekt bei "TEST.JPEG.bmp.jpg" ^^

			#DEBUG:  if ( ( lc($OnlyFileTyp) eq lc "jpg" ) || ( lc($OnlyFileTyp) =~ /jpg/i ) ) {
			if ( ( lc($OnlyFileTyp) eq lc($FileTypeHashRef->{1}) ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/i ) ) {
							
				my $TempFileName = $FileName;

				$TempFileName =~ s/\./ /ig;
				$TempFileName =~ s/\-/ /ig;
				$TempFileName =~ s/\,/ /ig;
				$TempFileName =~ s/\+/ /ig;

				# hier erst noch testen, ob amacht ordentlich funzt, solange ist matched = 1 gesetzt
				my $matched = 0;
				eval {
					$matched = amatch($FileName, $ApproxMatchingQuantifier, $TemporarySearchQuery);
				};
		
				################################################
				# Wenn der Suchbegriff dem FileName entspricht
				
				if ( $FileName eq $TemporarySearchQuery ) {
					$NegativMatchingQuantifier = 0;
				} elsif ( lc($TemporarySearchQuery) eq lc($FileName) ) {
					$NegativMatchingQuantifier = 0;
				} elsif ( eval { $FileName =~ /$TemporarySearchQuery/ig } ) {
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
								# eg: no match so substract -100 points from PageKount

							};	# if ( lc($SinglePartO...
						}; # foreach my $SinglePartSearchQuery ...
					}; # foreach my $SinglePartOfFilename ...
					
				}; # if ( $FileName eq $TemporarySearchQuery ) {}
				
				###################################################
				# Wenn der Suchbegriff dem FileName entspricht
				my $KeyWordMatching = 0;

				if ( length($OnlyFileName) > 0 ) {
					$KeyWordMatching = GetKeyWordMatching( length($SearchQuery) / length($OnlyFileName) ); 
				};

				$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $Speed . "\t\t";
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'FN' } = $FileName;				
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $Size;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'FI' } = $FileIndex;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SP' } = $Speed;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } = ($KeyWordMatching + $Speed + $NegativMatchingQuantifier);
			
				#		print "\n#############\n";
				#		print "SpeedPoints=$SpeedPoints\n";
				#		print "SHA1=$SHA1\n";
				#		print "Size=$Size\n";
				#		print "FileIndex=$FileIndex\n";
				#		print "PeerHost=$PeerHost\n";
				#		print "FileName=$FileName\n";

				$SortedHashRefCounter++;
					
			}; # if ( ( lc($OnlyFileTyp) eq $FileTypeHashRef->{1} ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/ ) ) {

		}; # if ( length($FileName) > 0 && length($Speed) ... ) {
			
	}; # for ( my $key=0; $key<=$ResultHashRefCount; $key++ ) {

	# Hash löschen
	%{$ResultHashRef} = ();


	########################################################################################################################
	###### 2 nested for-iterations for ordering the same sources into one single result by checking the sha1 values
	###### get count of HashRef $SortedHashRef -> keep this value, if we would take that value from keys() dynamically it would result in an endless loop :-(
	my $SortHashRefCount = keys(%{$SortedHashRef});
	
	for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {
#	for ( my $Key=0; $Key<=60; $Key++ ) {
		
		my $FileName		= "";
		my $Speed			= "";
		my $SHA1			= "";
		my $Size			= "";
		my $FileIndex		= "";
		my $PeerHost		= "";

		my $FileName		= %{$SortedHashRef}->{ $Key }->{ 'FN' };
		my $Speed			= %{$SortedHashRef}->{ $Key }->{ 'SP' };
		my $SHA1			= %{$SortedHashRef}->{ $Key }->{ 'SH' };
		my $Size			= %{$SortedHashRef}->{ $Key }->{ 'SZ' };
		my $FileIndex		= %{$SortedHashRef}->{ $Key }->{ 'FI' };
		my $PeerHost		= %{$SortedHashRef}->{ $Key }->{ 'PH' };
		
		my @IsDoublePeer	= split("\t\t", $SortedHashRef->{ $Key }->{ 'PH' });
		my $IsDoublePeer;

		for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {
			
			my $FileNameNext	= "";
			my $SpeedNext		= "";
			my $SHA1Next		= "";
			my $SizeNext		= "";
			my $FileIndexNext	= "";
			my $PeerHostNext	= "";

			my $FileNameNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FN' };
			my $SpeedNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SP' };
			my $SHA1Next		= %{$SortedHashRef}->{ $NextKey }->{ 'SH' };
			my $SizeNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SZ' };
			my $FileIndexNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FI' };
			my $PeerHostNext	= %{$SortedHashRef}->{ $NextKey }->{ 'PH' };
		
			# finde doppelte sha1 werte
			if ( $SHA1 eq $SHA1Next && length($SHA1) == 32 && length($SHA1Next) == 32 ) {
								
			#	my @IsDoublePeerNext	= split("\t\t", $SortedHashRef->{ $NextKey }->{ 'PH' });
			#	my $IsDoublePeerNext;
				my $BadCount = 0;
				
			#	for ( my $a=0; $a<=$#IsDoublePeerNext; $a++ ) {
			#		my ( $peerN, $indexN, $nameN, undef ) = split(";", $IsDoublePeerNext[$a] );
			#		for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {
			#			my ( $peer, $index, $name, undef ) = split(";", $IsDoublePeer[$i] );
			#			if ( ($peer eq $peerN) || (length($peerN) < 9) || (length($peer) < 9) ) {	# only valid peers needed
			#				
			#				# print "peer=$peer und peerhost=$peerN\n";
			#				$BadCount++;
			#	
			#			}; # if ( ($peer eq $peerN) || (length($peerN) < 9) || length($peer) < 9)) {
			#		}; # for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {}
			#	}; # for ( my $a=0; $a<=$#IsDoublePeerNext; $a++ ) {
				
				# wenn die ips $peer und $PeerHostNext nicht gleich sind
				if ( $BadCount == 0 ) {
			
					$SortedHashRef->{ $Key }->{ 'PH' } .= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedNext . "\t\t";					
					
					# erhöhe den Ranking Wert des aktuellen Eintrages um den Speed des folgenden Eintrages mit gleicher SHA1 
					# diese daten des folgenden Eintrages bekommen wir in der zeile 166:	my ($Speed,$SHA1,$Size,$FileIndex,$PeerHost,$FileName) = split(/\;\!\$\#\%\&/, $_);	# ;!$#%&  geliefert

					$SortedHashRef->{ $Key }->{ 'RK' } += $SpeedNext; 
					$SortedHashRef->{ $Key }->{ 'SZ' } = $Size;
					$SortedHashRef->{ $Key }->{ 'SH' } = $SHA1;
				
					# hier dann den aktuellen Next Eintrag löschen
					delete $SortedHashRef->{ $NextKey };
					delete $SortedHashRef->{ $Key };
					
				};	# if ( $BadCount == 0 ) {}
			
			}; # if ( $SHA1 eq $SHA1Next ) {
			
		}; # for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {
		
	}; # for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {

	###### 2 nested for-iterations for ordering the same sources into one single result by checking the sha1 values
	########################################################################################################################

#	print "PhexSortRank(): Dumper\n";
#	print Dumper $SortedHashRef;

	################################################################
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
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
		
				#old:	if ( $peer.';'.$index.';'.$filename ne ';;' ) {
				
				if ( ($peer =~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ && length($peer) >= 9) && ($index =~ /[0-9]{1,}/) && (length($filename)>5) ) {
					
					if ( $SourcesCounter <= $MaxSourcesForOneHit ){						# max $MaxSourcesForOneHit einträge als quelle für ein file
						
						$PH .= $peer.';'. $index.';'. $filename. "\r\n";
						
						if ( ( length($PH) > 0 ) && ( length($SZ) > 0 ) && ( length($SH) > 0 ) && ( length($peer) > 0 ) && ( length($index) > 0 ) && ( length($filename) > 0 ) ) {
							# old: push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 
							push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 
						};

						$SourcesCounter++;

					}; # if ( $SourcesCounter >=

				}; # if ( $peer.';'.$inde

		}; # for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {}
			
	}; # while( my ($key, $value) = each( %{$SortedHashRef} ) ) {
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
	################################################################

	##########################################
	##### Fix für 1-Result-Bug - 24.ß8.2006
	
	if ( keys %{$SortedHashRef} == 0 ) {
		# Wenn nur ein Ergebnis vorliegt, funktioniert die untere Sortierung mittels Sort_Table nicht korrekt
		# darum wird hier ein Dummy Element eingefügt, welches später wieder entfernt wird. 
		# Dieses Dummy Element ist von nöten, damit @SORTED = Sort_Table() korrekt funktioniert, wenn nur 1 Ergebnis vorliegt.
		push(@UNSORTED, "-3333###-3333###-3333###-3333\n"); 	
	};


#	@SORTED = nkeysort{
#			my @q = split( "###", $_ );
#			} @UNSORTED; # split("###",$_)
#	open(WH,">/server/phexproxy/debug/dumper.txt");
#	print WH Dumper @SORTED; 
#	close WH;
	
	#########################################################
	###### eigentliche Sortierung nach SortRank durchführen
	
	@SORTED = Sort_Table(
		cols      => '4',
		field     => '1',
		sorting   => 'descending',
		structure => 'csv',
		separator => '###',
		data      => \@UNSORTED,
	);

	# speicher separat freigegeben, der Hash geht eh out of scope
	%{$SortedHashRef}	= ();

	return \@SORTED;

}; # sub SortRank(){



sub GetKeyWordMatching(){

	my $int = shift;
	return sprintf ("%.2f", $int) * $KeywordMatchingMultiply;
		
}; # GetKeyWordMatching(){}



sub GetSpeedPoints(){

	my $SpeedValue = shift;

	if ( $SpeedValue <= $IsSpeedModem ) {	# modem speed
		return $SpeedRankingPointsforModem;
	} elsif ( $SpeedValue >= $IsSpeedISDN && $SpeedValue < $IsSpeedDSL ) {	# isdn 
		return $SpeedRankingPointsforISDN;
	} elsif ( $SpeedValue >= $IsSpeedDSL && $SpeedValue < $IsSpeedCable ) {	# dsl
		return $SpeedRankingPointsforDSL;
	} elsif ( $SpeedValue >= $IsSpeedCable && $SpeedValue < $IsSpeedT1 ) {	# cable
		return $SpeedRankingPointsforCable;
	} elsif ( $SpeedValue >= $IsSpeedT1 && $SpeedValue < $IsSpeedT3 ) {	# t1
		return $SpeedRankingPointsforT1;	
	} elsif ( $SpeedValue >= $IsSpeedT3 ) {	# t3
		return $SpeedRankingPointsforT3;
	};

	# never reached
	return 0;

}; # sub GetSpeedPoints(){


# 350	;!$#%&	6KZ7DNIKSGXMGW37OUQRRWWFCHHCDNGC	;!$#%&	625	;!$#%&	7254	;!$#%&	201.92.103.14:42753	;!$#%&	britneyraiva_x17online[1].jpg	\n


# later write cache with full results:
# schreibe: 1#$Speed,$SHA1,$Size,$Fileindex,$PeerHost,$FileName
#			2#$Speed,$SHA1,$Size,$Fileindex,$PeerHost,$FileName
#			3#$Speed,$SHA1,$Size,$Fileindex,$PeerHost,$FileName