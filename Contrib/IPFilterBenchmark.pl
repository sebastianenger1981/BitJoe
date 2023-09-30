
@array = (1..8100000);

my $start = time();

for ($i=0;$i<=$#array; $i++) {

	my $a = rand(1);
	
	if ( $a == $array[$i] ) {
	} else {
	};

};

my $end = time();

print "Start-FOR: ";
print scalar( localtime($start) );

print " \nEnd: ";
print scalar( localtime($end) );


exit;


foreach (0..8100000) {

	my $a = rand(1);
	my $b = rand(1);

	if ( $a == $b ) {
	} else {
	};

};

my $end = time();

print "\nStart-FOREACH: ";
print scalar( localtime($start) );

print " \n End: ";
print scalar( localtime($end) );