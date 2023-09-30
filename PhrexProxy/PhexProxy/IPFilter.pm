#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		IP Filter für die Results
##### Todo:			
########################################

package PhexProxy::IPFilter;
use strict;

my $VERSION		= '0.18.1';

mkdir '/server/phexproxy/IPFILTER';
my $REALOADFILE = '/server/phexproxy/IPFILTER/reload.txt';
my $IPFILTER	= '/server/mutella/IPFILTER/ipfilter.dat';
my $TMPFILTER	= '/server/mutella/IPFILTER/tempfilter.txt';
my $IPBLOCKER	= '/server/mutella/IPFILTER/ipblocker.txt';	# eine IP pro Zeile


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # sub new(){}


sub IPBlocker(){

	my $self	= shift;
	my $GivenIP	= shift;

	open(BLOCKER, "<$IPBLOCKER") or sub { warn "PhexProxy::IPFilter->IPBlocker(): Blocking not possible: IO ERROR: $!\n"; return -1; };
		flock (BLOCKER, 2);
		while( defined( my $IPperLine = <BLOCKER> ) ){
			$IPperLine =~ s/[\s]//g;
			if ( $IPperLine eq $GivenIP ) {
				close BLOCKER;
				return -1; # sind equal
			}; # if ( $IPperLine eq
		}; # while 
	close BLOCKER;

	return 0;	# nicht gleich, wenn kein Match

}; # sub IPBlocker(){}


sub SimpleFilter(){

	my $self	= shift;
	my $GivenIP	= shift;
	
	my %IPFILTER = (
	#	'1' => '192.168.0.1',
	#	'2' => '127.0.0.1',
	#	'3' => '169.254.0.1',
	#	'4' => '10.0.1.1',
		'5' => '192.168.0',
	);

	my $keys = keys( %IPFILTER );

	# teste für jeden eintrag im IPFILTER Hash die beiden ips
	for ( my $i=0; $i<=$keys; $i++) {
	
		my ( $a1,$b1,$c1,$d1 ) = split('\.', $GivenIP );
		my ( $a2,$b2,$c2,$d2 ) = split('\.', %IPFILTER->{ $i } );

		if ( ($a1 == $a2) && ( $b1 == $b2 ) ) {
			return -1;	# sind equal
		};

		if ( ($a1 == $a2) && ( $b1 == $b2 ) && ( $c1 == $c2 ) && ( $d1 == $d2 ) ) {
			return -1;	# sind equal
		} elsif ( ($a1 == $a2) && ( $b1 == $b2 ) && ( $c1 == $c2 ) ){
			return -1;	# sind equal
		} elsif ( ($a1 == $a2) && ( $b1 == $b2 ) ) {
			return -1;	# sind equal
		} elsif ( $a1 == $a2 ) {
			return -1;	# sind equal
		};

	}; # for ( my $i=0; $i<=$keys; $i++) {}

	return 1;	# ips sind not equal

}; # sub SimpleFilter(){}


sub AdvancedFilter(){
	
	my $self			= shift;
	my $GivenIP			= shift;
	my $FilterArrayRef	= shift;

	# return -1 : equal
	# return 0: not equal

	for ( my $i=0; $i<=$#{$FilterArrayRef}; $i++ ) {
		if ( $GivenIP == $FilterArrayRef->[$i] ) {
			return -1;
		};	
	}; # for ( my $i=0; $i<=$#{$FilterArrayRef}; $i++ ) {}

	return 0;

}; # sub AdvancedFilter(){}


sub ReloadFilter(){

	# Sehr CPU und IO gotoige Funktion - sie sollte nur sehr selten aufgerufen werden

	my $self			= shift;
	my $FilterArrayRef	= shift;	# nimm die alte FilterHashRef an
	my $Reload			= shift;
	
	# teste, ob als parameter für Reload ein gültiger Wert übergeben wurde
	# wenn ja, dann reload die ipfilter
	# wenn nein, dann lese die reload config file ein und gucke, ob etwa doch reloadet werden soll

	if ( $Reload == 1 ) {
		
		@{$FilterArrayRef} = ();

	} else {

		open(RELOAD, "<$REALOADFILE") or sub { warn "PhexProxy::IPFilter->ReloadFilter(): Blocking not possible: IO ERROR: $!\n"; return -1; };
			flock (RELOAD, 2);
			$Reload = <RELOAD>;
		close RELOAD;

		chomp($Reload);
	
	};

	# hier führe dann den Reload durch
	if ( $Reload == 0 ) {
		
		return $FilterArrayRef;

	} else {
		
		# leere das Array mit den ips
		@{$FilterArrayRef} = ();
			
		# öffne ipfilter.dat
		open(FILTER, "<$IPFILTER") or sub { warn "PhexProxy::IPFilter->ReloadFilter(): Blocking not possible: IO ERROR: $!\n"; return -1; };
			flock (FILTER, 2);
		
			while( my $entry = <FILTER> ){
				
				# Annahme ipfilter.dat besteht aus '123.3.3.2-124.6.21.3 ADDISION DIVISION COOP'

				my ( $IPRange, undef )	= split(' ', $entry );
				my ( $FromIP, $ToIP )	= split('-', $IPRange );
				
				$FromIP =~ s/\s//g;
				$ToIP	=~ s/\s//g;

				if ( ($FromIP =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})/) && ($ToIP =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})/) ) {
					&GenerateIPAdressesFromRange( $FromIP, $ToIP, "BOTH" );
				} elsif ( ($FromIP =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})/) && ($ToIP !~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})/) ) {
					&GenerateIPAdressesFromRange( $FromIP, $ToIP, "FROM" );
				} elsif ( ($FromIP !~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})/) && ($ToIP =~ /(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})+(\.)(\d{0,255})/) ) {
					&GenerateIPAdressesFromRange( $FromIP, $ToIP, "TO" );
				};

			}; # while( my $entry = <FILTER> ){}

		close FILTER;
		
		# lese die tmpfilter.txt in das ensprechende array ein!
		open(TMPFILTER, "<$TMPFILTER") or sub { warn "PhexProxy::IPFilter->ReloadFilter(): Blocking not possible: IO ERROR: $!\n"; return -1; };
			flock (TMPFILTER, 2);
			while( my $entry = <TMPFILTER> ){
				push( @{$FilterArrayRef}, "$entry\n" );
			};
		close TMPFILTER;

		unlink $TMPFILTER;

	}; # } else {}

	return $FilterArrayRef;

}; # sub ReloadFilter(){}


sub GenerateIPAdressesFromRange(){

	my $FromIP	= shift;
	my $ToIP	= shift;
	my $Flag	= shift;

	if ( $Flag eq 'BOTH' ) {
	
		my ( $ia,$ib,$ic,$id ) = split('\.', $FromIP );
		my ( $ja,$jb,$jc,$jd ) = split('\.', $ToIP );

		open(WRITE, "+>>$TMPFILTER") or sub { warn "PhexProxy::IPFilter->GenerateIPAdressesFromRange(): Blocking not possible: IO ERROR: $!\n"; return -1; };
			flock (WRITE, 2);
			
			for ( my $a=$ia; $a<=$ja; $a++) {
				for ( my $b=$ib; $b<=$jb; $b++) {
					for ( my $c=$ic; $c<=$jc; $c++) {
						for ( my $d=$id; $d<=$jd; $d++) {
							print WRITE "$a.$b.$c.$d\n";
						};
					};	
				};
			};
		
		close WRITE;

	} elsif ( $Flag eq 'FROM' ) {

		open(WRITE, "+>>$TMPFILTER") or sub { warn "PhexProxy::IPFilter->GenerateIPAdressesFromRange(): Blocking not possible: IO ERROR: $!\n"; return -1; };
			flock (WRITE, 2);
			print WRITE "$FromIP\n";
		close WRITE;

	} elsif ( $Flag eq 'TO' ) {
	
		open(WRITE, "+>>$TMPFILTER")  or sub { warn "PhexProxy::IPFilter->GenerateIPAdressesFromRange(): Blocking not possible: IO ERROR: $!\n"; return -1; };
			flock (WRITE, 2);
			print WRITE "$ToIP\n";
		close WRITE;

	};

	return 1;

}; # sub GenerateIPAdressesFromRange(){}

return 1;