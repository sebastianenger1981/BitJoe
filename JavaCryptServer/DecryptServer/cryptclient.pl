use IO::Socket;

$socket = IO::Socket::INET->new(PeerAddr => "127.0.0.1",
                                PeerPort => 1111,
                                Proto    => "tcp",
                                Type     => SOCK_STREAM)
    or die "Couldn't connect to $remote_host:$remote_port : $@\n";

# ... do something with the socket
print $socket "#123456789abcdef0123456789abcdef:cb49a5ce4b966a3824b110e8ace2b0e7eaab0d71b977d087cc22ebe856fcc7997f7d969e25dc93b5223262c6f82f3fb6c43274860d33fc464cdeb2321c5bb05a42d46de4ecaf3d6afd7261b39cf89c99";
print $socket "\r\n";

my $returnString = "";

while ( <$socket>) {
	$returnString .= $_;
	print "$_\n";
};


if (  $returnString =~ /\r\n/) {
	print "super";
};


# and terminate the connection when we're done
close($socket);