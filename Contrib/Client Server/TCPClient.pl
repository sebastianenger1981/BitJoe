use IO::Socket;
use constant CRLF => "\r\n";

my $in = $ARGV[0];

use constant TIMEOUT => 5;
$socket = new IO::Socket::INET(PeerAddr => 'www.zoozle.net',
                 PeerPort => '3381',
                 Proto    => 'tcp', Timeout => TIMEOUT)
    or die "can't connect to $@\n";

#$socket->autoflush(1);
#$socket->blocking(0);

#binmode $socket;
#print $socket "FIND star" . CRLF;
#$socket->recv($buff, 1024) or die;
#my $buff = <$socket>;
#print "Buffer: $buff\n";
#close $socket;
exit;

# hole immer die ergebnisse vom ersten suchquery ab - @micha: nach jedem query eins halt hochzählen lassen
print $socket "RESULTS f2b92487ea9f0df023dcf0f469ae254b" . CRLF;	
#my $buff = $socket->recv($buff, 1024);

print "I got back: '$buff' \n";
$socket->close(); 
exit;