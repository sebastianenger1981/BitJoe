use Net::Nslookup;

$Net::Nslookup::MX_IS_NUMERIC = 1;
$Net::Nslookup::TIMEOUT		= 2;

my $name = nslookup( host => "85.214.59.105", type => "PTR" );
# my $name = nslookup( host => "192.168.59.255", type => "PTR" );
print length $name;
print " $name \n";

