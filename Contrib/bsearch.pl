#! /usr/bin/perl

# Binary search, array passed by reference

# search array of integers a for given integer x
# return index where found or -1 if not found
sub bsearch {
    my ($x, $a) = @_;            # search for x in array a
    my ($l, $u) = (0, @$a - 1);  # lower, upper end of search interval
    my $i;                       # index of probe
    while ($l <= $u) {
	$i = int(($l + $u)/2);
	print($i, "\n");
	if ($a->[$i] < $x) {
	    $l = $i+1;
	}
	elsif ($a->[$i] > $x) {
	    $u = $i-1;
	} 
	else {
	    return $i; # found
	}
    }
    return -1;         # not found
}

# pad: for making test data, return an array of $n copies of the number $i
sub pad {
    my ($i, $n) = @_;
    my @a = ();
    for ($c = 0; $c < $n; $c++) {
	push(@a, $i); 
    }
    return @a;
}

# main program
print "Binary search, array passed by reference\n";

@a10 = (0,pad(1,10),2);
print "The index of 0 in @a10 is ", bsearch(0,\@a10),"\n";
print "The index of 2 in @a10 is ", bsearch(2,[0,pad(1,10),2]),"\n";

print "Index of 2 in 0 1 .. 1 2 with 100 1's is ",bsearch(2,[0,pad(1,100),2]),"\n";
print "Index of 2 in 0 1 .. 1 2 with 1000 1's is ",bsearch(2,[0,pad(1,1000),2]),"\n";


print "Making list of a million entries...\n";
@a10x6 = (0,pad(1,1000000),2);
print "Index of 2 in 0 1 .. 1 2 with 1000000 1's is ",bsearch(2,@a10x6),"\n";

print "\nnow let's call search ten times\n";

for ($i=0; $i<10; $i++) {
   print "$i. Index of 2 in 0 1 .. 1 2 with 1000000 1's is ",bsearch(2,\@a10x6),"\n";
}

print "\nDone.\n";
