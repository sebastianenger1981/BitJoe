#!/usr/bin/perl -I/root/.mutella/MutellaProxy

use MutellaProxy::CryptoLibrary;

my $ct = MutellaProxy::CryptoLibrary->Encrypt( "a9e83ef0f3161057a5d3fe40a09e9cbf", "TESTT" );
my $plain = MutellaProxy::CryptoLibrary->Decrypt( "a9e83ef0f3161057a5d3fe40a09e9cbf", $ct );

print "PLAIN: '$plain' \n";