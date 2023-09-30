use LWP::Simple;

my $doc = get("http://www.heise.de");

my @content = split(' ', $doc );
my $lineContent;

foreach my $line ( @content ) {
	next if ( $line !~ /\w/ );
	next if ( $line =~ /\"/ );
	$lineContent .= '"' . $line . '",';
};

print $lineContent;
