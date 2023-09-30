#!/usr/bin/perl

my $finalString;

open(RH,"<$ARGV[0]");
open(WH,">out.txt");
while( <RH>){
	my $line = $_;
	chomp($line);
	$finalString .= '"' . $line . '",'
};
print WH $finalString;
close WH;
close RH;
