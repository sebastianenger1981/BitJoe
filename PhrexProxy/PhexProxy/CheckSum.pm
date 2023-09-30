#!/usr/bin/perl

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	16.07.2006
##### Function:		MD5 Checksum erstellen		
##### Todo:			
########################################

package PhexProxy::CheckSum;

# use Digest::MD5 qw(md5 md5_hex md5_base64);

use Digest::MD5 qw( md5_hex );	#  perl -MCPAN -e 'force install "Digest::MD5"'
#use Digest::MD4 qw( md4_hex );
#use Digest::SHA1 qw( sha1_hex );

use strict;

my $VERSION = '0.20';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # sub new() {}


sub MD5ToHEX(){

	my $self	= shift;
	my $String	= shift;
	
	if ( ref($String) eq 'SCALAR' ) {
		return md5_hex( ${$String} );
	} elsif ( ref($String) eq '' ) {
		return md5_hex( $String );
	};

}; # sub md5_hex(){}


sub MD4ToHEX(){

	my $self	= shift;
	my $String	= shift;
	
	if ( ref($String) eq 'SCALAR' ) {
		return md5_hex( ${$String} );
	} elsif ( ref($String) eq '' ) {
		return md5_hex( $String );
	};

}; # sub md4_hex(){}


sub SHA1ToHEX(){

	my $self	= shift;
	my $String	= shift;
	
#	my ($classname,undef) = split('=', $self);
#
#	if ( $classname eq "PhexProxy::CheckSum" ) {
#		print "MD5ToHEX(): '$self' HASH\n";
#	} else {
#		print "MD5ToHEX(): '$self' normal\n";
#		$String = $self;
#	};

	if ( ref($String) eq 'SCALAR' ) {
		return md5_hex( ${$String} );
	} elsif ( ref($String) eq '' ) {
		return md5_hex( $String );
	};

}; # sub md4_hex(){}


return 1;