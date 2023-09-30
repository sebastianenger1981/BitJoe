#!/usr/bin/perl -I/server/mutella/MutellaProxy


use IO::Socket;
use Data::Dumper;
use MutellaProxy::IO;

use constant CRLF => "\r\n";

my $IO	= MutellaProxy::IO->new();


$socket = IO::Socket::INET->new(PeerAddr => '85.214.39.76',
                                PeerPort => '3381',
                                Proto    => "tcp",
                                Type     => SOCK_STREAM)
    or die "Couldn't connect to 85.214.39.76:3381 : $@\n";


$IO->writeSocket( $socket, "find 1 paris" . CRLF );

sleep 12;

if (!$socket) {
	print "connection to socket lost!\n";
};

my $ReadFromClient = $IO->readSocket( $socket );

print Dumper($ReadFromClient);
