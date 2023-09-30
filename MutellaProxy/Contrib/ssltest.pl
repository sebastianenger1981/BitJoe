
use IO::Socket::SSL;

$sock= new IO::Socket::SSL (
	PeerAddr => "localhost",
	PeerPort => 3382,
	Proto => 'tcp',
	Timeout => '5',
	SSL_verify_mode			=> 0x00,
	SSL_use_cert			=> 0,
	SSL_ca_file => '/server/mutella/certs/ca.key') or die;

print $sock "\r\n\r\n\r\n\r\n\r\nPariser Nächte\r\n";
$string = "find\r\n\r\n\r\n\r\n\r\nPariser\r\n";
#syswrite($sock, $string, length $string);
$back = <$sock>;
print "i got back: $back " . length $back;

$back = <$sock>;
print "i got back: $back\n";
