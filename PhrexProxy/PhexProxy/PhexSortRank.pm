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

### use URI::Escape qw(uri_escape);
use PhexProxy::CheckSum;
# use Data::Dumper;
# use HTML::Entities;
use strict;


######################
##### Idee: Alarm Timeout Einbauen: wenn die Funktion zu lange braucht, dann einfach rasch alles beenden und fix 10 ergebnisse zusammenstellen und diese dann zurückliefern
######################

my $MaxSourcesForOneHit				= 30;			# org: 30;

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

my $CHECK							= PhexProxy::CheckSum->new();


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


sub PhexSortRank(){
	
	my $self					= shift;
	my $ResultStringScalarRef	= shift;
	my $SearchQuery				= shift;
#	my $FileTypeArrayRef		= shift;

	my $ResultContent;
	my @UNSORTED				= ();
	my @SORTED					= ();
	my $SortedHashRef			= {};
	my $SortedHashRefResults	= {};
	my $SortedHashRefCounter	= 0;

	# separete the content from the phex proxy
	my $ResultString			= ${$ResultStringScalarRef};
	my @ResultContent			= split(/\\n/, $ResultString );
	my $NoDoublePeers			= {};	# HashRef

	my @CheckAliveHost			= ();	# speichert erstmal alle PeerHosts ab und diese werden später auf alive getestet
	my $DeadPeerHosts			= {};	# speichere hier die toten hosts drinne ab
	my $peercountfirst			= 0;

	# $ResultContent[0]	='350;!$#%&5MPINMLCMXURWALTFX3XZDAJIFYBTT2H;!$#%&3910857;!$#%&62;!$#%&68.40.70.132:5537;!$#%&Britney Spears - gimme more.mp3';
	for ( @ResultContent ) {

		# Hinweis: der Phex liefert die direkten Speed Werte in KB/s wieder !
		# 350;!$#%&5MPINMLCMXURWALTFX3XZDAJIFYBTT2H;!$#%&3910857;!$#%&62;!$#%&68.40.70.132:5537;!$#%&Britney Spears - gimme more.mp3
		my ($Speed,$SHA1,$Size,$FileIndex,$PeerHost,$FileName)	= split(/\;\!\$\#\%\&/, $_);	# ;!$#%&
		my ( $OnlyFileName , $OnlyFileTyp )						= split(/(\.([^.]+?)$)/i, $FileName );	# funzt auch korrekt bei "TEST.JPEG.bmp.jpg" ^^
		next if ( length($OnlyFileName) <= 0 );					# diese anweisung hier ist nur, damit später keine division durch null passiert bei GetKeyWordMatching()

		# bilde einen String über die 3 Variabeln, diese sind später Grundlage für den "Keine Doppelten Treffer" - Hinweis: eventuell noch den Filename Wert weglassen ?
		chomp($SHA1);
		chomp($PeerHost);
		chomp($Size);
		chomp($Speed);
		chomp($FileIndex);
		chomp($FileName);

		my $NoDoublePeerString	= lc($SHA1.$PeerHost);
		next if ( exists($NoDoublePeers->{ $NoDoublePeerString }) );
				
	#	for ( my $i=0; $i<=scalar(@{$FileTypeArrayRef})-1; $i++ ) {
	#		
	#		my $AllowedFilename		= $FileTypeArrayRef->[$i];
	#		next if ( ( lc($OnlyFileTyp) ne lc($AllowedFilename) ) || ( lc($OnlyFileTyp) !~ /$AllowedFilename}/i ) );
	#	#	print "Allowed '$AllowedFilename'\n";
		
			$peercountfirst++;
			my $SpeedPoints	 = GetSpeedPoints($Speed);
			#$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. encode_entities($FileName) . ';' . $SpeedPoints . "\t\t";
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'PH' } = $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'FN' } = $FileName; # 	uri_escape($FileName);	# 
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'SH' } = $SHA1;
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'SZ' } = $Size;
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'FI' } = $FileIndex;
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'SP' } = $Speed;
			$SortedHashRef->{ $SortedHashRefCounter }->{ 'RK' } = $SpeedPoints;
	
			$NoDoublePeers->{ $NoDoublePeerString }				= "";	# Trage in HashRef ein, das die Quelle bereits verwendet wird, und sie somit nicht nochmal auftreten darf
			$NoDoublePeerString									= "";	# string resetten
			$SortedHashRefCounter++;

		#	push(@CheckAliveHost,"$PeerHost\n");


	#	}; # for ( my $i=0; $i<=scalar(@{$FileTypeArrayRef}); $i++ ) {


	}; # for ( @ResultContent ) {


#	open(LOG,">sources.txt");
#		print LOG @CheckAliveHost;
#	close LOG;



	# Abschnitt For-Double SortedHashRefResults
	########################################################################################################################
	###### 2 nested for-iterations for ordering the same sources into one single result by checking the sha1 values
	###### get count of HashRef $SortedHashRef -> keep this value, if we would take that value from keys() dynamically it would result in an endless loop :-(

	my $SortHashRefCount		= keys(%{$SortedHashRef});
		
	for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {
      
		my $FileName		= %{$SortedHashRef}->{ $Key }->{ 'FN' };
		my $Speed			= %{$SortedHashRef}->{ $Key }->{ 'SP' };
		my $SHA1			= %{$SortedHashRef}->{ $Key }->{ 'SH' };
		my $Size			= %{$SortedHashRef}->{ $Key }->{ 'SZ' };
		my $FileIndex		= %{$SortedHashRef}->{ $Key }->{ 'FI' };
		my $PeerHost		= %{$SortedHashRef}->{ $Key }->{ 'PH' };

		# SpeedPoints für das Ranking berechnen
		my $SpeedPoints		= GetSpeedPoints($Speed);	
	
		if ( exists($SortedHashRefResults->{ $SHA1 }) ) {
					
			$SortedHashRefResults->{ $SHA1 }->{ 'PH' }	.= $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";		
			$SortedHashRefResults->{ $SHA1 }->{ 'SZ' }	= $Size;
			$SortedHashRefResults->{ $SHA1 }->{ 'SH' }	= $SHA1;
			$SortedHashRefResults->{ $SHA1 }->{ 'RK' }	= 0;	# werden später verarbeitet
				
		} elsif ( !exists($SortedHashRefResults->{ $SHA1 }) ) {
					
			$SortedHashRefResults->{ $SHA1 }->{ 'PH' }	= $PeerHost .';'. $FileIndex .';'. $FileName . ';' . $SpeedPoints . "\t\t";		
			$SortedHashRefResults->{ $SHA1 }->{ 'SZ' }	= $Size;
			$SortedHashRefResults->{ $SHA1 }->{ 'SH' }	= $SHA1;
			$SortedHashRefResults->{ $SHA1 }->{ 'RK' }	= $SpeedPoints; 
					
		} else {

	#		open(LOG,"+>>rdouble.txt");
	#		print LOG "for-schleife-deadend: hopefully Never reached: $SHA1 \n";
	#		close LOG;

		}; # if ( ($SHA1 eq $SHA1Next) && (length($SHA1) == 32 && length($SHA1Next) == 32 ) ) {

    }; # for ( my $Key=0; $Key<=$SortHashRefCount; $Key++ ) {

#	open(LOG,"+>>rdouble.txt");
#		print LOG "\nMiddle Entries after for-schleife: in Hash " . keys(%$SortedHashRefResults);
#		print LOG "\n\n";
#	close LOG;


#	open(LOGW,">rwhile.txt");
#	my $HasBeenUsed			= {};	# Debug - wie oft wurde ein SHA1 Wert schon verwendet
#	my $HasBeenUsed2		= {};

	my $last = $peercountfirst * 0.5;
	# print "$self :: $peercountfirst peers to check: had to wait $last seconds\n";


	# Abschnitt While-Ergebniszusammenstellung
	################################################################
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
	while( my ($key, $value) = each( %{$SortedHashRefResults} ) ) {
		
		my $PH	= %{$SortedHashRefResults}->{ $key }->{ 'PH' };
		my $SZ	= %{$SortedHashRefResults}->{ $key }->{ 'SZ' };
		my $SH	= %{$SortedHashRefResults}->{ $key }->{ 'SH' };	
		my $RK	= %{$SortedHashRefResults}->{ $key }->{ 'RK' };
		
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
		
#		print LOGW "\n\n\nLINESTART SHA1='$SH' ### PEER='".join("\n -->",@SortBySpeed)."  LINEND\n\n\n \n";

		my $SourcesCounter		= 0;		# Zählt wieviel Einträge bereits verwendet wurden
		my $DoublePeerEntries	= {};		# Doppelte Peers vorhalten - Lokal - wir nehmen lieber die obige, globale variante
		my $SourcesSpeedValue	= 0;		# Ranking Punkte für den Eintrag

		# Setzte die nach Speed sortierten Einträge wieder zusammen
		# Alle Einträge in einem Array @SortBySpeed gehören zu einem Treffer 
		my $j;
		for ( $j=0; $j<=$#SortBySpeed; $j++ ) {
			
			my ( $peer, $index, $filename, $speed ) = split(";", $SortBySpeed[$j] );	# im dateinamen darf kein ";" vorkommen
			
			# bilde wert über peer+sha1 wert
			# my $CheckSumforPeer = $CHECK->MD5ToHEX(lc($peer.$SH));
			my $CheckSumforPeer		= lc($peer.$SH);	# md5 zu bilden kostet nur unnötig ressourcen

#			my $PeerFlag = CheckValidPeerHost($peer);
#			print LOGW "LINESTART IN FOR SCHLEIFE PEERFLAG=[$PeerFlag] J=[$j] Jmax=[$#SortBySpeed] SHA1='$SH' ### PEER='$peer' \n";


			# Diese beiden next anweisungen sind hier dringend erforderlich
			next if ( length($peer) < 9 );	# 1.1.1.1:1
#			next if ( CheckValidPeerHost($peer) != 1 );
			next if ( exists($DoublePeerEntries->{$CheckSumforPeer}) );

#			$HasBeenUsed2->{$SH}++;
#			print LOGW "LINESTART IN FOR SCHLEIFE AFTER KICK FALSE PEERS J=[$j] Jmax=[$#SortBySpeed] SHA1='$SH' ### PEER='$peer' \n";

			# max $MaxSourcesForOneHit einträge als quelle für ein file
			if ( $SourcesCounter < $MaxSourcesForOneHit ){
							
#				if ( exists($DoublePeerEntries->{$CheckSumforPeer}) ) {
#					open(LOG,"+>>rdouble.txt");
#					print LOG "Warning Doppelte Quelle while: $peer und $SH sind schon verwendet worden \n";
#					close LOG;
#				};
				
				$PH	.= $peer.';'. $index.';'. $filename. "\r\n";
				
				$SourcesSpeedValue += $speed;
				$DoublePeerEntries->{$CheckSumforPeer} = "";		# setzte in Hashref ein, dass peerhost+sha1 wert schon benutzt wurde
				$SourcesCounter++;
	
#				$HasBeenUsed->{$SH}++;

			}; # if ( $SourcesCounter < $MaxSourcesForOneHit ){

		}; # for ( my $j=0 ; $j<=$#SortBySpeed ; $j++ ) {}

		$RK	+= $SourcesSpeedValue;		# Speed für den gesamten Treffer herstellen
		push(@UNSORTED, "$RK###$PH###$SZ###$SH\n"); 
					
	}; # while( my ($key, $value) = each( %{$SortedHashRefResults} ) ) {
	###### Einzelne Sortierung der Ergebnisse nach Speed für ein File
	################################################################
	close LOGW;

#	open(LOG,"+>>rdouble.txt");
#
#		print LOG "\n SUCHBEGRIFF $SearchQuery	\n\n";
#		print LOG "\nAnzahl Start Entries - Treffer : " . keys(%$HasBeenUsed3);
#		print LOG "\nAnzahl Cutted Entries - Treffer : " . keys(%$HasBeenUsed);
#		print LOG "\nAnzahl NotCutted Entries - Treffer : " . keys(%$HasBeenUsed2);
#		print LOG "\n Hinweis zur nächsten Debug ausgabe: wenn bei ORIGNAL PHEX ein höhrer Wert als bei NOT CUTTED steht, dann wurde eine quelle verschluckt.\n";
#		print LOG "\n Hinweis: nur von NOT CUTTED ZU CUTTED dürfen geringere Werte auftreten - dann war eine Quelle doppelt oder das Quellenmaximum war erreicht!\n";
#		print LOG "\n\n SIMPLE PARALLEL - \t\t CUTTED <-> NOT CUTTED <-> ORIGINAL VOM PHEX:\n";
#		
#		for(sort keys %$HasBeenUsed) {
#			
#			if ( $HasBeenUsed3->{$_} > $HasBeenUsed2->{$_} ) {
#				print LOG $_ . " = " . $HasBeenUsed->{$_} . " -	 " . $HasBeenUsed2->{$_} . " -	 " . $HasBeenUsed3->{$_} ."   ERROR - Quelle verschluckt - Vergleiche SHA1 mit rwhile.txt! \n";
#			} elsif ( $HasBeenUsed2->{$_} > $HasBeenUsed->{$_} ) {
#				print LOG $_ . " = " . $HasBeenUsed->{$_} . " -	 " . $HasBeenUsed2->{$_} . " -	 " . $HasBeenUsed3->{$_} ."   Quelle doppelt oder Quellenmaximum erreicht! \n";
#			} else {
#				print LOG $_ . " = " . $HasBeenUsed->{$_} . " -	 " . $HasBeenUsed2->{$_} . " -	 " . $HasBeenUsed3->{$_} ."\n";
#			}
#		}
#		
##		print LOG "\n\n PARALLEL: \n";
##		
##		for(sort keys %$HasBeenUsed) {
##			print LOG $_ . " = " . $HasBeenUsed->{$_} . "		###		" . $_ ." = ". $HasBeenUsed2->{$_} . "\n";
##		}
##
##		print LOG "\nCUTTED-FINAL: \n";
#		my $l = 0;
#		my $count2 = 0;
#		for(sort keys %$HasBeenUsed) {
##			print LOG $_ . " = " . $HasBeenUsed->{$_} . "\n";
#			$l+=$HasBeenUsed->{$_};
#			$count2++;
#		}
#		print LOG "CUTTED WHOLE QUELLEN: $l -- count TREFFER: $count2\n\n";
##		print LOG "\n\n\nNOT CUTTED: \n";
#		my $c = 0;
#		my $count = 0;
#		for(sort keys %$HasBeenUsed2) {
##			print LOG $_ . " = " . $HasBeenUsed2->{$_} . "\n";
#			$c+=$HasBeenUsed2->{$_};
#			$count++;
#		}
#		print LOG "NOT CUTTED WHOLE QUELLEN: $c -- count TREFFER: $count\n\n";
#
##	#	print LOG "START ENTRIES: \n\n";
#		my $a = 0;
#		
#		for(sort keys %$HasBeenUsed3) {
#		#	print LOG $_ . " = " . $HasBeenUsed3->{$_} . "\n";
#			$a+=$HasBeenUsed3->{$_};
#			
#		}
#		print LOG "START WHOLE QUELLEN: $a \n\n";
#	close LOG;


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



#	open(LOG,">sources.txt");
#		print LOG @SORTED;
#	close LOG;


	return \@SORTED;

}; # sub PhexSortRank(){


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
	### Checke den Status einen Peerhosts auf formale Gültigkeit - Private Netzwerke sind ungültig
	### I: Scalar String $PeerHost
	### O: Scalar Int $StatusFlag
	###############

	my $PeerHost		= shift;
	
	$PeerHost			=~ s/^\s+//;
	$PeerHost			=~ s/\s+$//;
	chomp($PeerHost);

	my ($IP,$PeerPort)	= split(":", $PeerHost);
	my ($a,$b,$c,$d)	= split(/\./, $IP);

	if ( length($PeerHost) < 9 ){	# # 9 ist minimale gültige ip:port combi - 1.1.1.1:1
		return 0;
		#	print "CheckValidPeerHost(): Length Peer Host '$PeerHost' failed: ". length($PeerHost); print "\n";
	}; # if ( length($PeerHost) < 9 ){

	# Wenn PeerPort Invalide
	if ( $PeerPort !~ /(\d{1,})/ig ) {
		return 0;
		#	print "CheckValidPeerHost(): PeerPort '$PeerPort' invalid\n";
	}; # if ( $PeerPort !~ /(\d{1,})/ig ) {
	

	#########
	### Private Adressräume: Start
	#########

	# Gib Falsch zurück, wenn es sich bei einer IP um eine private ip handelt
	# 10.0.0.0        -   10.255.255.255  (10/8 prefix)
    # 172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
    # 192.168.0.0     -   192.168.255.255 (192.168/16 prefix)
	# 127.0.0.1

	# Achtung: hier direkt 0 zurückgeben, da sonst 
	if ( $a == 10 ) {									# 10.0.0.0        -   10.255.255.255  (10/8 prefix)
		return 0;
	}; # if ( $a == 10 ) {		

	if ( $a == 172 && ( $b >= 16 || $b <= 31 ) ) {		# 172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
		return 0;
	}; # if ( $a == 172 && ( $b >= 16 || $b =< 31) ) {

	if ( $a == 192 && $b == 168 ) {						# 192.168.0.0     -   192.168.255.255 (192.168/16 prefix)
		return 0;
	}; # if ( $a == 192 && $b == 168 ) {		

	if ( $a == 127 && $b == 0 && $c == 0 && $d == 1 ) {	# 127.0.0.1
		return 0;
	}; # if ( $a == 127 && $b == 0 && $c == 0 && $d == 1 ) {

	#########
	### Private Adressräume: Ende
	#########

	if ( $a =~ /(\d{1,})/ig && $a > 0 && $a <= 255 ) {
	} else {
		return 0;
		#	print "CheckValidPeerHost(): '$PeerHost' IP Part a '$a' invalid\n";
	}; # if ( $a =~ /

	if ( $b =~ /(\d{1,})/ig && $b >= 0 && $b <= 255 ) {
	} else {
		return 0;
		#	print "CheckValidPeerHost(): '$PeerHost' IP Part b '$b' invalid\n";
	}; # if ( $b =~ /

	if ( $c =~ /(\d{1,})/ig && $c >= 0 && $c <= 255 ) {
	} else {
		return 0;
		#	print "CheckValidPeerHost(): '$PeerHost' IP Part c '$c' invalid\n";
	}; # if ( $c =~ /

	if ( $d =~ /(\d{1,})/ig && $d >= 0 && $d <= 255 ) {
	} else {
		return 0;
		#	print "CheckValidPeerHost(): '$PeerHost' IP Part d '$d' invalid\n";
	}; # if ( $d =~ /

	# wird nur erreicht, wenn peer gültig ist, ansonsten wird vorher schon 0 sprich false zurückgegeben
	return 1;	

}; # sub CheckValidPeerHost(){
	


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

		#	if ( length($peer) < 9 ) {
		#		open(LOG,"+>>rdouble.txt");
		#		print LOG "while: length: $peer invalid \n";
		#		close LOG;
		#	};
		#	if ( $peer !~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ ) {
		#		open(LOG,"+>>rdouble.txt");
		#		print LOG "while: peer scheme: $peer invalid \n";
		#		close LOG;
		#	};

#		my $IsSpamFlag											= PhexProxy::Filter->ClassifySpamResult( $TemporarySearchQuery, $FileName );
#		my $ProzentsatzUeberlaengeString						= ( length($FileName) / length($TemporarySearchQuery) ) * 100 if ( length($FileName) > 0 );	# X% mehr als 100%
#		# print "($TmpCounter)[Spamflag=$IsSpamFlag]{Ueberlaenge=$ProzentsatzUeberlaengeString %}: $SHA1 --- $FileName\n"; $TmpCounter++; 
#		open(LOG,"+>>/server/phexproxy/resultsStatusFile.txt");
#			print LOG "($TmpCounter)[Spamflag=$IsSpamFlag]{Ueberlaenge=$ProzentsatzUeberlaengeString %} - $SHA1 - $FileName - $PeerHost\n";
#		close(LOG);
#		# select(undef, undef, undef, 0.2);



# Hinweis: die nächste anweisung mit regex funktioniert nicht 100% und desshalb einfach nicht benutzen
# next if ( $peer !~ /^((25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]\.){3}(25[0-4]|(2[0-4]|1[0-9]|[1-9]?)[0-9]))+(\:)([0-9]{1,})$/ );