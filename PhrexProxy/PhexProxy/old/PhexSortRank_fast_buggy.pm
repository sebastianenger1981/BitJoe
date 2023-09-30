#!/usr/bin/perl

package PhexProxy::PhexSortRank;

# Sort::Key - nkeysort - similar to keysort but compares the keys numerically instead of as strings.

# use PhexProxy::SortArray qw( Sort_Table );
# use Sort::Array qw( Sort_Table );
# use String::Approx 'amatch';

# use Sort::Key qw(keysort nkeysort ikeysort ukeysort);	# perl -MCPAN -e 'force install "Sort::Key"'
# use PhexProxy::IPFilter;
# use Math::BigFloat;			# perl -MCPAN -e 'force install "Math::BigFloat"'
# use PhexProxy::Filter;
# use Benchmark;
# use Data::Dumper;
# use POSIX qw(ceil);

use PhexProxy::CheckSum;
use strict;


######################
##### Idee: Alarm Timeout Einbauen: wenn die Funktion zu lange braucht, dann einfach rasch alles beenden und fix 10 ergebnisse zusammenstellen und diese dann zurückliefern
######################

# my $MaxFileLength					= 10000;
# my $KeywordMatchingMultiply			= 105;			# 105 % - sprich 5 % aufschlag
# my $NegativMatchingQuantifier		= 0;			#-10000;
# my $ApproxMatchingQuantifier		= "40%";
my $MaxSourcesForOneHit				= 30;			# org: 20;

# speed related Things
my $SpeedRankingPointsforModem		= 0.85;
my $SpeedRankingPointsforISDN		= 1.05;
my $SpeedRankingPointsforDSLLite	= 1.25;
my $SpeedRankingPointsforDSL1000	= 1.35;
my $SpeedRankingPointsforDSL2000	= 1.4;
my $SpeedRankingPointsforDSL3000	= 1.45;
my $SpeedRankingPointsforDSL4000	= 1.5;
my $SpeedRankingPointsforDSL6000	= 1.55;
my $SpeedRankingPointsforT1			= 1.6;
my $SpeedRankingPointsforDSL16000	= 1.65;
my $SpeedRankingPointsforT3			= 1.7;

my $IsSpeedModem					= 5;	# alles in Kbyte/s
my $IsSpeedISDN						= 8;
my $IsSpeedDSLLite					= 56;	
my $IsSpeedDSL1000					= 128;
my $IsSpeedDSL2000					= 256;
my $IsSpeedDSL3000					= 376;
my $IsSpeedDSL4000					= 512;
my $IsSpeedDSL6000					= 750;
my $IsSpeedT1						= 1200;
my $IsSpeedDSL16000					= 2000;
my $IsSpeedT3						= 6144;


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub PhexSortRank(){
	
	my $self					= shift;
	my $ResultStringScalarRef	= shift;
	my $SearchQuery				= shift;
	my $FileTypeHashRef			= shift;

	my $ResultContent;
	my @ResultContent			= ();
	my @UNSORTED				= ();
	my @SORTED					= ();
	my $SortedHashRef			= {};
	my $SortedHashRefResults	= {};
	my $SortedHashRefCounter	= 0;

	my $ResultString			= ${$ResultStringScalarRef};
	
	# separete the content from the phex proxy
	@ResultContent				= split(/\\n/, $ResultString );


	# Abschnitt For-Content-Splitter
	# trenne den Search Query an ' .' auf
	# my ( $TemporarySearchQuery, undef) = split(' .', $SearchQuery); # geht von solchen suchbegriffen aus "Suchbegriff .jpg"
	my ( $TemporarySearchQuery, undef)	 = split(/(\.([^.]+?)$)/i, $SearchQuery );

	my $TmpCounter		= 1;
	my $NoDoublePeers	= {};	# HashRef

	##print "DEBUG: Vor InitHash \n";

	for ( @ResultContent ) {

		# Hinweis: der Phex liefert die direkten Speed Werte in KB/s wieder !
		# 350;!$#%&5MPINMLCMXURWALTFX3XZDAJIFYBTT2H;!$#%&3910857;!$#%&62;!$#%&68.40.70.132:5537;!$#%&Britney Spears - gimme more.mp3
		my ($Speed,$SHA1,$Size,$FileIndex,$PeerHost,$FileName)	= split(/\;\!\$\#\%\&/, $_);	# ;!$#%&
		my ( $OnlyFileName , $OnlyFileTyp )						= split(/(\.([^.]+?)$)/i, $FileName );	# funzt auch korrekt bei "TEST.JPEG.bmp.jpg" ^^
		next if ( length($OnlyFileName) <= 0 );					# diese anweisung hier ist nur, damit später keine division durch null passiert bei GetKeyWordMatching()

		# bilde einen String über die 3 Variabeln, diese sind später Grundlage für den "Keine Doppelten Treffer" - Hinweis: eventuell noch den Filename Wert weglassen ?
		chomp($SHA1);
#		chomp($FileName);
		chomp($PeerHost);
		my $NoDoublePeerString									= lc($SHA1.$PeerHost);
#		my $IsSpamFlag											= PhexProxy::Filter->ClassifySpamResult( $TemporarySearchQuery, $FileName );
#		my $ProzentsatzUeberlaengeString						= ( length($FileName) / length($TemporarySearchQuery) ) * 100 if ( length($FileName) > 0 );	# X% mehr als 100%
#	
#		# print "($TmpCounter)[Spamflag=$IsSpamFlag]{Ueberlaenge=$ProzentsatzUeberlaengeString %}: $SHA1 --- $FileName\n"; $TmpCounter++; 
#	
#		open(LOG,"+>>/server/phexproxy/resultsStatusFile.txt");
#			print LOG "($TmpCounter)[Spamflag=$IsSpamFlag]{Ueberlaenge=$ProzentsatzUeberlaengeString %} - $SHA1 - $FileName - $PeerHost\n";
#		close(LOG);
#		
#		# select(undef, undef, undef, 0.2);


		#DEBUG:  if ( ( lc($OnlyFileTyp) eq lc "jpg" ) || ( lc($OnlyFileTyp) =~ /jpg/i ) ) {
		if ( ( lc($OnlyFileTyp) eq lc($FileTypeHashRef->{1}) ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/i ) ) {
						
			my $TempFileName		= $FileName;

			$TempFileName			=~ s/\./ /ig;
			$TempFileName			=~ s/\-/ /ig;
			$TempFileName			=~ s/\,/ /ig;
			$TempFileName			=~ s/\+/ /ig;
		
			if ( !exists($NoDoublePeers->{ $NoDoublePeerString }) ){	# Wenn die Quelle noch nicht benutzt wurde

			#	print "PEERLENGTH: " . length($PeerHost);
			#	print "\n";
			#
			#	next if ( length($PeerHost) < 9 );
				my $SpeedPoints		= GetSpeedPoints($Speed);
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'FN' } = $FileName;				
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $Size;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'FI' } = $FileIndex;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'SP' } = $Speed;
				$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } = $SpeedPoints;
						
				$NoDoublePeers->{ $NoDoublePeerString }				= "";	# Trage in HashRef ein, das die Quelle bereits verwendet wird, und sie somit nicht nochmal auftreten darf
				$NoDoublePeerString									= "";	# string resetten

				$SortedHashRefCounter++;

			} else {
				
			#	print "IGNORED because of DoublePeerString: $SHA1 - $FileName - $PeerHost \n"; 
			#	print "Ignored NoDoublePeerString: '$NoDoublePeerString' \n";
				
			}; # if ( !exists($NoDoublePeers->{ $NoDoublePeerString }) ){
				
		}; # if ( ( lc($OnlyFileTyp) eq $FileTypeHashRef->{1} ) || ( lc($OnlyFileTyp) =~ /$FileTypeHashRef->{1}/ ) ) {

	}; # for ( @ResultContent ) {


	# Abschnitt For-Double SortedHashRefResults
	########################################################################################################################
	###### 2 nested for-iterations for ordering the same sources into one single result by checking the sha1 values
	###### get count of HashRef $SortedHashRef -> keep this value, if we would take that value from keys() dynamically it would result in an endless loop :-(

	my $SortHashRefCount		= keys(%{$SortedHashRef});
	my $NoDoublePeers			= {};	# Resette Hash hinter HashRef

	##print "DEBUG: insgesamte eintraege: $SortHashRefCount\n"; 
	##print "DEBUG: Vor for-while konstrukt\n";
	
	for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {
      
		my $FileName		= %{$SortedHashRef}->{ $Key }->{ 'FN' };
		my $Speed			= %{$SortedHashRef}->{ $Key }->{ 'SP' };
		my $SHA1			= %{$SortedHashRef}->{ $Key }->{ 'SH' };
		my $Size			= %{$SortedHashRef}->{ $Key }->{ 'SZ' };
		my $FileIndex		= %{$SortedHashRef}->{ $Key }->{ 'FI' };
		my $PeerHost		= %{$SortedHashRef}->{ $Key }->{ 'PH' };

		my $NextKey			= $Key++;
		my $FileNameNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FN' };
		my $SpeedNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SP' };
		my $SHA1Next		= %{$SortedHashRef}->{ $NextKey }->{ 'SH' };
		my $SizeNext		= %{$SortedHashRef}->{ $NextKey }->{ 'SZ' };
		my $FileIndexNext	= %{$SortedHashRef}->{ $NextKey }->{ 'FI' };
		my $PeerHostNext	= %{$SortedHashRef}->{ $NextKey }->{ 'PH' };
		
		if ( ($SHA1 eq $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {

		#	my $NoDoublePeerString	= lc($SHA1.$PeerHostNext);
		#	next if ( exists($NoDoublePeers->{ $NoDoublePeerString }) );

			my $SpeedPoints = GetSpeedPoints($SpeedNext);	
		
			$SortedHashRefResults->{ $SHA1 }->{ 'PH' }	.= $PeerHostNext .';'. $FileIndexNext .';'. $FileNameNext . ';' . $SpeedPoints . "\t\t";		
			$SortedHashRefResults->{ $SHA1 }->{ 'SZ' }	= $Size;
			$SortedHashRefResults->{ $SHA1 }->{ 'SH' }	= $SHA1;
			$SortedHashRefResults->{ $SHA1 }->{ 'RK' }	= 0;	# werden später verrechnet
			# $SortedHashRefResults->{ $SHA1 }->{ 'RK' }	+= $SpeedPoints;
			
		#	$NoDoublePeers->{ $NoDoublePeerString }				= "";	# Trage in HashRef ein, das die Quelle bereits verwendet wird, und sie somit nicht nochmal auftreten darf
		#	$NoDoublePeerString									= "";

		} elsif ( ($SHA1 ne $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {
					
		#	my $NoDoublePeerString	= lc($SHA1.$PeerHost);
		#	next if ( exists($NoDoublePeers->{ $NoDoublePeerString }) );

			my $SpeedPoints	= GetSpeedPoints($Speed);
			$SortedHashRefResults->{ $SHA1 }->{ 'PH' }	= $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";		
			$SortedHashRefResults->{ $SHA1 }->{ 'SZ' }	= $Size;
			$SortedHashRefResults->{ $SHA1 }->{ 'SH' }	= $SHA1;
			$SortedHashRefResults->{ $SHA1 }->{ 'RK' }	= $SpeedPoints; 
			
		#	$NoDoublePeers->{ $NoDoublePeerString }				= "";	# Trage in HashRef ein, das die Quelle bereits verwendet wird, und sie somit nicht nochmal auftreten darf
		#	$NoDoublePeerString									= "";

		}; # if ( ($SHA1 eq $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {

    }; # for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {


	##print "DEBUG: vor ergebnis zusammensetzung \n";

	# Abschnitt While-Ergebniszusammenstellung
	################################################################
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
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
		my $SourcesSpeedValue	= 0;

		# Setzte die nach Speed sortierten Einträge wieder zusammen
		# Alle Einträge in einem Array @SortBySpeed gehören zu einem Treffer 
		for ( my $j=0; $j<=$#SortBySpeed; $j++ ) {

			my ( $peer, $index, $filename, $speed ) = split(";", $SortBySpeed[$j] );	# im dateinamen darf kein ";" vorkommen
			
			# Diese beiden next anweisungen sind hier dringend erforderlich
			next if ( length($peer) < 9 );	# 1.1.1.1:1
			next if ( $peer !~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ );

			# max $MaxSourcesForOneHit einträge als quelle für ein file
			if ( $SourcesCounter < $MaxSourcesForOneHit ){
			
				# my $CheckSumforPeer = PhexProxy::CheckSum->MD5ToHEX("$peer;$index;$filename");
				my $CheckSumforPeer = PhexProxy::CheckSum->MD5ToHEX($peer);
				next if ( exists($DoublePeerEntries->{$CheckSumforPeer}) );
				
				$PH	.= $peer.';'. $index.';'. $filename. "\r\n";
				
				$SourcesSpeedValue += $speed;
				$DoublePeerEntries->{$CheckSumforPeer} = "";
				$SourcesCounter++;
	
			}; # if ( $SourcesCounter < $MaxSourcesForOneHit ){

		}; # for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {}

		$RK	+= $SourcesSpeedValue;		# Speed für den gesamten Treffer herstellen
		push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 
					
	}; # while( my ($key, $value) = each( %{$SortedHashRefResults} ) ) {
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
	################################################################

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
	$SortedHashRefResults	= {};
	$SortedHashRef			= {};

	#########################################################
	###### eigentliche Sortierung nach SortRank durchführen
	
	@SORTED = SortArray(
		cols      => '4',
		field     => '1',
		sorting   => 'descending',
		structure => 'csv',
		separator => '###',
		data      => \@UNSORTED,
	); # @SORTED = SortArray(

	return \@SORTED;

}; # sub PhexSortRank(){





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
			sort {							# Sort::Key - nkeysort - similar to keysort but compares the keys numerically instead of as strings.
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



sub GetSpeedPoints(){

	my $SpeedValue = shift;

	if ( $SpeedValue <= $IsSpeedModem ) {	# modem speed
		return $SpeedRankingPointsforModem;

	} elsif ( $SpeedValue >= $IsSpeedISDN && $SpeedValue < $IsSpeedDSLLite ) {	# isdn 
		return $SpeedRankingPointsforISDN;

	} elsif ( $SpeedValue >= $IsSpeedDSLLite && $SpeedValue < $IsSpeedDSL1000 ) {	# dsllite
		return $SpeedRankingPointsforDSLLite;

	} elsif ( $SpeedValue >= $IsSpeedDSL1000 && $SpeedValue < $IsSpeedDSL2000 ) {	# dsl 1000
		return $SpeedRankingPointsforDSL1000;

	} elsif ( $SpeedValue >= $IsSpeedDSL2000 && $SpeedValue < $IsSpeedDSL3000 ) {	# dsl 2000
		return $SpeedRankingPointsforDSL2000;
		
	} elsif ( $SpeedValue >= $IsSpeedDSL3000 && $SpeedValue < $IsSpeedDSL4000 ) {	# dsl 3000
		return $SpeedRankingPointsforDSL3000;

	} elsif ( $SpeedValue >= $IsSpeedDSL4000 && $SpeedValue < $IsSpeedDSL6000 ) {	# dsl 4000
		return $SpeedRankingPointsforDSL4000;

	} elsif ( $SpeedValue >= $IsSpeedDSL6000 && $SpeedValue < $IsSpeedT1 ) {	# dsl 6000
		return $SpeedRankingPointsforDSL6000;

	} elsif ( $SpeedValue >= $IsSpeedT1 && $SpeedValue < $IsSpeedDSL16000 ) {	# t1
		return $SpeedRankingPointsforT1;

	} elsif ( $SpeedValue >= $IsSpeedDSL16000 && $SpeedValue < $IsSpeedT3 ) {	# dsl 16000
		return $SpeedRankingPointsforDSL16000;

	} elsif ( $SpeedValue >= $IsSpeedT3 ) {	# t3
		return $SpeedRankingPointsforT3;

	} else { 
		return 0.4;
	}; # if ( $SpeedValue <= $IsSpeedModem ) {	# modem speed

	# never reached
	return 0.4;

}; # sub GetSpeedPoints(){


sub CheckValidPeerHost(){

	###############
	### Checke den Status einen Peerhosts auf formale Gültigkeit
	### I: Scalar String $PeerHost
	### O: Scalar Int $StatusFlag
	###############

	my $PeerHost		= shift;
	my $StatusFlag		= 1;

	$PeerHost			=~ s/^\s+//;
	$PeerHost			=~ s/\s+$//;
	chomp($PeerHost);

	my ($IP,$PeerPort)	= split(":", $PeerHost);
	my ($a,$b,$c,$d)	= split(/\./, $IP);

	# print "IP=$IP  Peer=$PeerPort\n";

	if ( length($PeerHost) < 9 ){	# # 9 ist minimale gültige ip:port combi - 1.1.1.1:1
		$StatusFlag = 0;
		print "CheckValidPeerHost(): Length Peer Host '$PeerHost' failed: ". length($PeerHost); print "\n";
	}; # if ( length($PeerHost) < 9 ){

	# Wenn PeerPort Invalide
	if ( $PeerPort !~ /(\d{1,})/ig ) {
		$StatusFlag = 0;
		print "CheckValidPeerHost(): PeerPort '$PeerPort' invalid\n";
	}; # if ( $PeerPort !~ /(\d{1,})/ig ) {
	
	if ( $a =~ /(\d{1,})/ig && $a > 0 && $a <= 255 && $a != 127 && $a != 196 ) {
	} else {
		$StatusFlag = 0;
		print "CheckValidPeerHost(): '$PeerHost' IP Part a '$a' invalid\n";
	}; # if ( $a =~ /

	if ( $b =~ /(\d{1,})/ig && $b >= 0 && $b <= 255 ) {
	} else {
		$StatusFlag = 0;
		print "CheckValidPeerHost(): '$PeerHost' IP Part b '$b' invalid\n";
	}; # if ( $b =~ /

	if ( $c =~ /(\d{1,})/ig && $c >= 0 && $c <= 255 ) {
	} else {
		$StatusFlag = 0;
		print "CheckValidPeerHost(): '$PeerHost' IP Part c '$c' invalid\n";
	}; # if ( $c =~ /

	if ( $d =~ /(\d{1,})/ig && $d >= 0 && $d <= 255 ) {
	} else {
		$StatusFlag = 0;
		print "CheckValidPeerHost(): '$PeerHost' IP Part d '$d' invalid\n";
	}; # if ( $d =~ /

	return $StatusFlag;

}; # sub CheckValidPeerHost(){
	

		#	print "RANK: ". length($RK). "\n";
		#	print "SIZE: ". length($SZ). "\n";
		#	print "SHA1: ". length($SH). "\n";
		#	print "PEER: ". length($PH) . "\n";
		
		
	#	###################################################
	#	# Hier KeywordMatching: $Quellenpunkte mal Keywordmatching
	#	my $filename						= "";
	#	( undef, undef, $filename, undef )	= split(";", $PH );
	#	my $KeyWordMatching					= &GetKeyWordMatching( $SearchQuery , $filename ); 
	#	my $int								= new Math::BigFloat( length($SearchQuery )) / new Math::BigFloat( length($filename));
	#	my $result							= sprintf("%.2f", length($SearchQuery )/ length($filename) );
	#
	#	$RK									= new Math::BigFloat($RK);
	#	$RK									*= $KeyWordMatching;
		###################################################

#sub GetKeyWordMatching(){
#
#	# diese Funktion kann so einfach funktionieren, da der Phex sicherstellt, dass der Suchbegriff im Dateinamen des Ergebnisses vorkommt
#	
#	my $SearchQuery		= shift;
#	my $OnlyFileName	= shift;
#	my $int				= new Math::BigFloat( length($SearchQuery )) / new Math::BigFloat( length($OnlyFileName));
#	my $result			= sprintf("%.2f", $int );
#
#	#	print "GetKeyWordMatching: [$result - $int] for lengtht search query " . length($SearchQuery) ." length filename: ".length($OnlyFileName) . " \n"; sleep 1;
#	return $result;
#
#}; # GetKeyWordMatching(){}
