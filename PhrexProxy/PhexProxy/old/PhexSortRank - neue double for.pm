#!/usr/bin/perl

package PhexProxy::PhexSortRank;

# use PhexProxy::SortArray qw( Sort_Table );
# use Sort::Array qw( Sort_Table );
# use String::Approx 'amatch';
# use Tie::Hash::Sorted;			 # perl -MCPAN -e 'force install "Tie::Hash::Sorted"'

use PhexProxy::IPFilter;
use PhexProxy::CheckSum;
use PhexProxy::Filter;
use Data::Dumper;
# perl -MCPAN -e 'force install "Data::Walk"'
use strict;
use integer;


my $MaxFileLength				= 10000;
my $KeywordMatchingMultiply		= 5;
my $NegativMatchingQuantifier	= -100;
my $ApproxMatchingQuantifier	= "40%";
my $MaxSourcesForOneHit			= 20;	# org: 20;

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



sub PhexSortRank(){
	
	my $self					= shift;
	my $ResultString			= shift;
	my $SearchQuery				= shift;
	my $FileTypeHashRef			= shift;

	my $ResultContent;
	my @ResultContent			= ();
	my @UNSORTED				= ();
	my @SORTED					= ();
	my $SortedHashRef			= {};
	my $SortedHashRefResults	= {};
	my $SortedHashRefCounter	= 0;

	# separete the content from the phex proxy
	@ResultContent				= split(/\\n/, $ResultString );

############ debug: start 
	my $len = length $ResultString;
	print "PhexSortRank(): $len\n";
############ debug: ende

	# Abschnitt For-Content-Splitter
	# trenne den Search Query an ' .' auf
	my ( $TemporarySearchQuery, undef) = split(' .', $SearchQuery); # geht von solchen suchbegriffen aus "Suchbegriff .jpg"
	
	my $TmpCounter = 0;
	for ( @ResultContent ) {

		if ( length($_) > 100 ) {

			my ($Speed,$SHA1,$Size,$FileIndex,$PeerHost,$FileName) = split(/\;\!\$\#\%\&/, $_);	# ;!$#%& 
			
			# filelänge auf $MaxFileLength zeichen begrenzen
			if ( (length($FileName) > 0) && (length($FileName) <= $MaxFileLength) && (length($Speed) > 0) && (length($SHA1) == 32) && (length($Size) > 0) && (length($FileIndex) > 0) && ($PeerHost =~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ && length($PeerHost) >= 9) ) {	# 9 ist minimale gültige ip:port combi
				print "($TmpCounter): $SHA1 --- $FileName\n"; $TmpCounter++;

				my ( $OnlyFileName , $OnlyFileTyp ) = split(/(\.([^.]+?)$)/i, $FileName );	# funzt auch korrekt bei "TEST.JPEG.bmp.jpg" ^^

				#DEBUG:  if ( ( lc($OnlyFileTyp) eq lc "jpg" ) || ( lc($OnlyFileTyp) =~ /jpg/i ) ) {
				if ( ( lc($OnlyFileTyp) eq lc($FileTypeHashRef->{1}) ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/i ) ) {
								
					my $TempFileName	= $FileName;

					$TempFileName		=~ s/\./ /ig;
					$TempFileName		=~ s/\-/ /ig;
					$TempFileName		=~ s/\,/ /ig;
					$TempFileName		=~ s/\+/ /ig;

				# hier erst noch testen, ob amacht ordentlich funzt, solange ist matched = 1 gesetzt
					my $matched = 1;
				#	eval {
				#		$matched = amatch($FileName, $ApproxMatchingQuantifier, $TemporarySearchQuery);
				#	};
			
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
					}; # if ( length($OnlyFileName) > 0 ) {
	

					########################################
					#### teste, ob die dateigröße ok ist
					#### teste, ob es kein spamfile ist
					#### teste, ob es keine ungültige IP ist
			#		my ( $ToCheckIP, $Port ) = split(':', $PeerHost );
			#		my $StatusA = PhexProxy::Filter->SpamFilter( \$FileName, $TemporarySearchQuery );
					my $StatusB = PhexProxy::Filter->SizeFilter( $FileTypeHashRef->{1}, $Size );
			#		my $StatusC	= PhexProxy::IPFilter->SimpleFilter( $ToCheckIP );
			#		if ( $StatusA == 1 && $StatusB == 1 && $StatusC == 1 ) {
			#		if ( $StatusA == 1 && $StatusB == 1 ) {
					if ( $StatusB == 1 ) {
						
						if ( $PeerHost =~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ && length($PeerHost) >= 9 && $FileIndex =~ /[0-9]{1,}/ && length($FileName) >= 5 ) {

							my $SpeedPoints		= GetSpeedPoints($Speed);
							my $MD5ValuePack	= $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'FN' } = $FileName;				
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1;
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $Size;
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'FI' } = $FileIndex;
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'SP' } = $Speed;
							$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } = ($KeyWordMatching + $SpeedPoints + $NegativMatchingQuantifier);
					
							$SortedHashRefCounter++;
						
						}; # if ( $PeerHost =~ 

					}; # if ( $StatusB == -1 ) {

					#### teste, ob die dateigröße ok ist
					#### teste, ob es kein spamfile ist
					########################################
					
				}; # if ( ( lc($OnlyFileTyp) eq $FileTypeHashRef->{1} ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/ ) ) {

			}; # if ( length($FileName) > 0 && length($Speed) ... ) {
			
		}; # if ( length($_) > 20 ) {

	}; # for ( @ResultContent ) {



	my $SortHashRefCount = keys(%{$SortedHashRef});
	print "BEFORE: I have $SortHashRefCount PreSorted Results\n";
	sleep 3;

	my $DoubleSourcesSHA1Values = {};

	for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {
      
		my $FileName		= %{$SortedHashRef}->{ $Key }->{ 'FN' };
		my $Speed			= %{$SortedHashRef}->{ $Key }->{ 'SP' };
		my $SHA1			= %{$SortedHashRef}->{ $Key }->{ 'SH' };
		my $Size			= %{$SortedHashRef}->{ $Key }->{ 'SZ' };
		my $FileIndex		= %{$SortedHashRef}->{ $Key }->{ 'FI' };
		my $PeerHost		= %{$SortedHashRef}->{ $Key }->{ 'PH' };
		
		while ( my ($NextKey, ) = each(%{$SortedHashRef}) ) {
			
			next if ( $Key == $NextKey );
			my $FileNameNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FN' };
			my $SpeedNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SP' };
			my $SHA1Next		= %{$SortedHashRef}->{ $NextKey }->{ 'SH' };
			my $SizeNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SZ' };
			my $FileIndexNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FI' };
			my $PeerHostNext	= %{$SortedHashRef}->{ $NextKey }->{ 'PH' };
			
		#	print "$SortHashRefCount - Walking first($Key) and second($NextKey) \n";
			
			if ( ($SHA1 eq $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {

				my $SpeedPoints = GetSpeedPoints($SpeedNext);	

				$SortedHashRefResults->{ $SHA1 }->{ 'PH' } .= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedPoints . "\t\t";		
				$SortedHashRefResults->{ $SHA1 }->{ 'RK' } += $SpeedPoints; 
				$SortedHashRefResults->{ $SHA1 }->{ 'SZ' } = $Size;
				$SortedHashRefResults->{ $SHA1 }->{ 'SH' } = $SHA1;
			
				print "DOUBLE $SHA1Next\n";
			#	print "$SortHashRefCount -  - deleted $NextKey\n"; sleep 1;
			
				# SHA1 Values von Einträgen, die mehrere Quellen haben
				$DoubleSourcesSHA1Values->{ $SHA1 } = "";
									
				# hier dann den aktuellen Next Eintrag löschen
				$SortedHashRef->{ $NextKey } = "";
				delete $SortedHashRef->{ $NextKey };

			}; # if ( ($SHA1 eq $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {

		}; # while ( my ($NextKey, ) = each(%{$SortedHashRef}) ) {

    }; # while ( my ($Key, $HashRef) = each(%{$SortedHashRef}) ) {


	my $SortHashRefCount = keys(%{$SortedHashRef});
	print "AFTER: I have $SortHashRefCount PreSorted Results\n";
	print "AFTER: Double sources: " . keys(%{$SortedHashRefResults}); print "\n";
	sleep 1;

	my $SortHashRefCount = keys(%{$SortedHashRef});
	for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {

			my $FileNameNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FN' };
			my $SpeedNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SP' };
			my $SHA1Next		= %{$SortedHashRef}->{ $NextKey }->{ 'SH' };
			my $SizeNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SZ' };
			my $FileIndexNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FI' };
			my $PeerHostNext	= %{$SortedHashRef}->{ $NextKey }->{ 'PH' };

			next if ( exists($DoubleSourcesSHA1Values->{ $SHA1Next }) );	# SHA1 Werte, die mehrere Quellen je Treffer haben, nicht mehr beachten
			next if ( length($FileNameNext) <= 0 );
			next if ( length($SpeedNext) <= 0 );
			next if ( length($SHA1Next) < 32 );
			next if ( length($SizeNext) <= 0 );
			next if ( length($PeerHostNext) <= 0 );

		#	print "SINGLE $SHA1Next\n";

			my $SpeedPoints		= GetSpeedPoints($SpeedNext);

			if ( !exists($SortedHashRefResults->{ $SHA1Next }) ) {			# diese Anweisung auf Grund der oberen exists($DoubleSourcesSHA1Values unnötig
			
				$SortedHashRefResults->{ $SHA1Next }->{ 'PH' } = $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedPoints . "\t\t";		
				$SortedHashRefResults->{ $SHA1Next }->{ 'RK' } = $SpeedPoints; 
				$SortedHashRefResults->{ $SHA1Next }->{ 'SZ' } = $SizeNext;
				$SortedHashRefResults->{ $SHA1Next }->{ 'SH' } = $SHA1Next;

			} elsif ( exists($SortedHashRefResults->{ $SHA1Next }) ) {

				$SortedHashRefResults->{ $SHA1Next }->{ 'PH' } .= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedPoints . "\t\t";		
				$SortedHashRefResults->{ $SHA1Next }->{ 'RK' } += $SpeedPoints; 
				$SortedHashRefResults->{ $SHA1Next }->{ 'SZ' } = $SizeNext;
				$SortedHashRefResults->{ $SHA1Next }->{ 'SH' } = $SHA1Next;

			}; # if ( !exists($SortedHashRefResults->{ $SHA1Next }) ) {

			$SortedHashRef->{ $NextKey } = "";
			delete $SortedHashRef->{ $NextKey };

	}; # for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {


	exit;


	# Abschnitt For-Double SortedHashRefResults
	########################################################################################################################
	###### 2 nested for-iterations for ordering the same sources into one single result by checking the sha1 values
	###### get count of HashRef $SortedHashRef -> keep this value, if we would take that value from keys() dynamically it would result in an endless loop :-(

	my $firstCount = 0;

	for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {
	# foreach my $Key ( sort { $SortedHashRef->{$b}->{'SH'} <=> $SortedHashRef->{$a}->{'SH'} } keys %{$SortedHashRef} ) {

	#	print "### $SortHashRefCount - first($firstCount) \n";

		my $FileName		= %{$SortedHashRef}->{ $Key }->{ 'FN' };
		my $Speed			= %{$SortedHashRef}->{ $Key }->{ 'SP' };
		my $SHA1			= %{$SortedHashRef}->{ $Key }->{ 'SH' };
		my $Size			= %{$SortedHashRef}->{ $Key }->{ 'SZ' };
		my $FileIndex		= %{$SortedHashRef}->{ $Key }->{ 'FI' };
		my $PeerHost		= %{$SortedHashRef}->{ $Key }->{ 'PH' };

		$firstCount++;

	#	my @IsDoublePeer	= ();
	#	my @IsDoublePeer	= split("\t\t", $PeerHost);
	#	my $IsDoublePeer;

		
		my $secondCount = 0;

		for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {
		# foreach my $NextKey ( sort { $SortedHashRef->{$b}->{'SH'} <=> $SortedHashRef->{$a}->{'SH'} } keys %{$SortedHashRef} ) {

			my $FileNameNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FN' };
			my $SpeedNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SP' };
			my $SHA1Next		= %{$SortedHashRef}->{ $NextKey }->{ 'SH' };
			my $SizeNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SZ' };
			my $FileIndexNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FI' };
			my $PeerHostNext	= %{$SortedHashRef}->{ $NextKey }->{ 'PH' };

			$secondCount++;

		# 	print "Walking first($firstCount) first $SHA1                    and second($secondCount) and second $SHA1Next \n";
			print "$SortHashRefCount - Walking first($firstCount) and second($secondCount) \n";


			# finde doppelte sha1 werte
			#  if ( ($SHA1 eq $SHA1Next) && ($MD5Value ne $MD5ValueNext) ) {
			if ( ($SHA1 eq $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {
				
			#	my $IsDoublePeerNext;
			#	my $BadCount			= 0;
			#	my @IsDoublePeerNext	= ();
			#	my @IsDoublePeerNext	= split("\t\t", $PeerHostNext);
			#
			#	for ( my $a=0; $a<=$#IsDoublePeerNext; $a++ ) {
			#		my ( $peerN, $indexN, $nameN, $speedN ) = split(";", $IsDoublePeerNext[$a] );
			#		
			#		for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {
			#			my ( $peer, $index, $name, $speed ) = split(";", $IsDoublePeer[$i] );
			#					
			#			# if ( $peer eq $peerN && $NextKey != $Key ) {		
			#			if ( $peer eq $peerN ) {		
			#				# print "Gleich: peer=$peer und peerhost=$peerN\n";
			#				$BadCount++;
			#	
			#			}; # if ( ($peer eq $peerN) || (length($peerN) < 9) || length($peer) < 9)) {
			#		
			#		}; # for ( my $i=0; $i<=$#IsDoublePeer; $i++ ) {}
			#	
			#	}; # for ( my $a=0; $a<=$#IsDoublePeerNext; $a++ ) {
			#	
			#	# wenn die ips $peer und $PeerHostNext nicht gleich sind
			#	if ( $BadCount == 0 ) {
			
				# erhöhe den Ranking Wert des aktuellen Eintrages um den Speed des folgenden Eintrages mit gleicher SHA1 
				# diese daten des folgenden Eintrages bekommen wir in der zeile 166:	my ($Speed,$SHA1,$Size,$FileIndex,$PeerHost,$FileName) = split(/\;\!\$\#\%\&/, $_);	# ;!$#%&  geliefert

			#	print "SAME SHA1 VALUES HERE: $SHA1\n";
				my $SpeedPoints = GetSpeedPoints($SpeedNext);	

				$SortedHashRefResults->{ $SHA1 }->{ 'PH' } .= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedPoints . "\t\t";		
				$SortedHashRefResults->{ $SHA1 }->{ 'RK' } += $SpeedPoints; 
				$SortedHashRefResults->{ $SHA1 }->{ 'SZ' } = $Size;
				$SortedHashRefResults->{ $SHA1 }->{ 'SH' } = $SHA1;
			#	$SortedHashRefResults->{ $SHA1 }->{ 'ST' } = 1;
					
								
				print "$SortHashRefCount - Walking first($firstCount) and second($secondCount) - deleted $NextKey\n";
				# hier dann den aktuellen Next Eintrag löschen
				$SortedHashRef->{ $NextKey } = "";
				delete $SortedHashRef->{ $NextKey };

				#	};	# if ( $BadCount == 0 ) {}
					
			}; # if ( $SHA1 eq $SHA1Next ) {

		}; # for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {
		

	#	my $SameSHA1Results = keys(%{$SortedHashRefResults});
	#	print "We have $SameSHA1Results same SHA1 Results\n";
	#	sleep 3;

	print "ready with 2 foreach loops\n";
 exit;

		# Hier dann alle übrigen Ergebnisse, deren SHA1 Wert nicht gleich ist in die Ergebnissmenge einführen - diese würden sonst nicht ausgegeben werden
		my $SortHashRefCount = keys(%{$SortedHashRef});

		for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {

			my $FileNameNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FN' };
			my $SpeedNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SP' };
			my $SHA1Next		= %{$SortedHashRef}->{ $NextKey }->{ 'SH' };
			my $SizeNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SZ' };
			my $FileIndexNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FI' };
			my $PeerHostNext	= %{$SortedHashRef}->{ $NextKey }->{ 'PH' };

			next if ( length($FileNameNext) <= 0 );
			next if ( length($SpeedNext) <= 0 );
			next if ( length($SHA1Next) < 32 );
			next if ( length($SizeNext) <= 0 );
			next if ( length($PeerHostNext) <= 0 );

			print "SINGLE $SHA1\n";
		#	my $SpeedPoints		= GetSpeedPoints($SpeedNext);
		#	$SortedHashRefResults->{ $SHA1Next }->{ 'PH' } = $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedPoints . "\t\t";		
		#	$SortedHashRefResults->{ $SHA1Next }->{ 'RK' } += $SpeedPoints; 
		#	$SortedHashRefResults->{ $SHA1Next }->{ 'SZ' } = $Size;
		#	$SortedHashRefResults->{ $SHA1Next }->{ 'SH' } = $SHA1;

			$SortedHashRef->{ $NextKey } = "";
			delete $SortedHashRef->{ $NextKey };

		}; # for ( my $NextKey=0; $NextKey<=$SortHashRefCount; $NextKey++ ) {

		#	$SortedHashRefResults->{ $SHA1 }->{ 'PH' } .= "\t\t";

	}; # for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {

	###### 2 nested for-iterations for ordering the same sources into one single result by checking the sha1 values
	########################################################################################################################


	my $SortHashRefResultsCount = keys(%{$SortedHashRefResults});
	print "I have $SortHashRefResultsCount before PeerMerge Results\n";
	exit;


	# speicher separat freigegeben, der Hash geht eh out of scope
	%{$SortedHashRef}	= ();

	# Abschnitt While-Ergebniszusammenstellung
	################################################################
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
	# while( my ($key, $value) = each( %{$SortedHashRef} ) ) {
	while( my ($key, $value) = each( %{$SortedHashRefResults} ) ) {
	
		my $PH		= %{$SortedHashRefResults}->{ $key }->{ 'PH' };
		my $SZ		= %{$SortedHashRefResults}->{ $key }->{ 'SZ' };
		my $SH		= %{$SortedHashRefResults}->{ $key }->{ 'SH' };	
		my $RK		= %{$SortedHashRefResults}->{ $key }->{ 'RK' };
		
		my ( @Temporary ) = split("\t\t", $PH);
		my $SortBySpeed;
		$PH ='';   # WICHTIG!!!
		
		my @SortBySpeed = SortArray(
			cols      => '4',
			field     => '4',
			sorting   => 'descending',
			structure => 'csv',
			separator => ';',
			data      => \@Temporary,
		);

		my $SourcesCounter		= 0;
		my $DoublePeerEntries	= {};

		# Setzte die nach Speed sortierten Einträge wieder zusammen
		# Alle Einträge in einem Array @SortBySpeed gehören zu einem Treffer 
		for ( my $j=0; $j<=$#SortBySpeed; $j++ ) {
			my ( $peer, $index, $filename, $speed ) = split(";", $SortBySpeed[$j] );	# im dateinamen darf kein ";" vorkommen
			
			# max $MaxSourcesForOneHit einträge als quelle für ein file
			if ( $SourcesCounter < $MaxSourcesForOneHit ){
			
				next if ( $peer !~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ );

				my $CheckSumforPeer = PhexProxy::CheckSum->MD5ToHEX("$peer;$index;$filename");
				next if ( exists($DoublePeerEntries->{$CheckSumforPeer}) );
				$PH					.= $peer.';'. $index.';'. $filename. "\r\n";
				
				$DoublePeerEntries->{$CheckSumforPeer} = "";
				next if ( length($index) <= 0 ); next if ( length($filename) <= 0 ); next if ( length($SH) != 32 );  
				next if ( $PH eq ''|| length($PH) <= 0 ); next if ( $peer eq '' || length($peer) <= 0 ); 
				$SourcesCounter++;

			}; # if ( $SourcesCounter >=

		}; # for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {}
		
		#	print "RANK: ". length($RK). "\n";
		#	print "SIZE: ". length($SZ). "\n";
		#	print "SHA1: ". length($SH). "\n";
		#	print "PEER: ". length($PH) . "\n";
		
		push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 

	}; # while( my ($key, $value) = each( %{$SortedHashRef} ) ) {
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
	################################################################

	# print Dumper $SortedHashRefResults;

	# Abschnitt Sortierung
	##########################################
	##### Fix für 0-Result SORT::ARRAY()->Bug - 24.08.2006
	
	if ( keys %{$SortedHashRefResults} == 0 ) {

		# Wenn nur ein Ergebnis vorliegt, funktioniert die untere Sortierung mittels Sort_Table nicht korrekt
		# darum wird hier ein Dummy Element eingefügt, welches später wieder entfernt wird. 
		# Dieses Dummy Element ist von nöten, damit @SORTED = Sort_Table() korrekt funktioniert, wenn nur 1 Ergebnis vorliegt.

		push(@UNSORTED, "-3333###-3333###-3333###-3333\n"); 

	}; # if ( keys %{$SortedHashRefResults} == 0 ) {

	# speicher separat freigegeben, der Hash geht eh out of scope
	%{$SortedHashRefResults}	= ();

	#########################################################
	###### eigentliche Sortierung nach SortRank durchführen
	
	@SORTED = SortArray(
		cols      => '4',
		field     => '1',
		sorting   => 'descending',
		structure => 'csv',
		separator => '###',
		data      => \@UNSORTED,
	);

	my $FinalSortedResults = $#SORTED;
	print "I have $FinalSortedResults finally sorted results for mobile phone \n";
	exit;
	return \@SORTED;
	##### hier hinten passiert nix mehr #####

}; # sub PhexSortRank(){



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


sub SortArray(){

	# Taken from Sort::Array - http://search.cpan.org/~midi/Sort-Array-0.26/Array.pm - by Michael Diekmann

	# Get the args and put them into a Hash.
    my (%arg) = @_;
	my $error = 0;

	# Check if <cols> is set,
	# else return error-code.
	if ((! $arg{cols}) && ($arg{cols} !~ /0-9/)) {
		$error = 100;
		return undef;
	};

	# Check if <field> is set,
	# else return error-code.
	if ((! $arg{field}) && ($arg{field} !~ /0-9/)) {
		$error = 101;
		return undef;
	};

	# Check if <sorting> is set,
	# else return error-code.
	if ((! $arg{sorting}) && (($arg{sorting} ne 'ascending') || ($arg{sorting} ne 'descending'))) {
		$error = 102;
		return undef;
	};

	# Check if <structure> set,
	# else return error-code.
	if (! $arg{structure}) {
		$error = 103;
		return undef;
	};

	# Check for content that should be sorted,
	# else return error-code.
	if (scalar(@{$arg{data}}) == 0) {
		$error = 104;
		return undef;
	};

	# Check is <separator> set,
	# else set the standard > ";"
	if (! $arg{separator}) {
		$arg{separator} = ';';
	};

	# Subtract 1 for better readable Arrayfields ->
	# beginning count at 1 (not 0). ;)
	$arg{cols}--;
	$arg{field}--;

	if ($arg{structure} eq 'single') {
		# Array is not semicolon-separated and we must
		# convert it to semicolon-separated.
		@_ = ();
		my $i=0;
		while (defined ${$arg{data}}[$i] ne '') {
			my $tmp='';
			for (0..$arg{cols}) {
				$tmp .= "${$arg{data}}[$i+$_]";
				if ($_ != $arg{cols}) {
					$tmp .= "$arg{separator}";
				};
			};
			push(@_, $tmp);
			$i += $arg{cols} + 1;
		};
		@{$arg{data}} = @_;
	};

	my $use_warn = 0;
	# Turn warnings off, because we do first a '<=>' and if that
	# fails, we do a 'cmp' and then a warning comes up.
	# After sorting, we turn $^W to the same as before.
	if ($^W) {
		$use_warn = $^W;
		$^W = 0;
	};
	if ($arg{sorting} eq 'ascending') {
		# Sorting content ascending order.
		@{$arg{data}} =
			map { $_->[0] }
			sort {
				$a->[1] <=> $b->[1]
					||
				$a->[1] cmp $b->[1]
			}
			map { [ $_, (split(/$arg{separator}/))[$arg{field}] ] }
		@{$arg{data}};
	} elsif ($arg{sorting} eq 'descending') {
		# Sorting content descending order.
		@{$arg{data}} =
			map { $_->[0] }
			sort {
				$b->[1] <=> $a->[1]
					||
				$b->[1] cmp $a->[1]
			}
			map { [ $_, (split(/$arg{separator}/))[$arg{field}] ] }
		@{$arg{data}};
	};

	# Turn warnings to the same as before.
	if ($use_warn) {
		$^W = $use_warn;
	};

	# Return the sorted Array in the
	# same format as input.
	if ($arg{structure} eq 'csv') {
		return @{$arg{data}};
	} elsif ($arg{structure} eq 'single') {
		@_ = ();
		foreach (@{$arg{data}}) {
			push(@_, split(/$arg{separator}/));
		};
		return @_;
	};

}; # sub SortArray(){

