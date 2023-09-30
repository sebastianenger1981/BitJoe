
use IO::Socket;
$s = IO::Socket::INET->new(PeerAddr => "88.171.172.70",
                           PeerPort => 36189,
                           Type     => SOCK_STREAM,
                           Timeout  => 0.5 )
    or die $@;

