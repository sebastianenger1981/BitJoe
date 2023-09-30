
my @files = glob("*.pm");

my $lineCount = 0;

foreach my $file (@files) {
	open(RH,"<$file");
		while(<RH>){
			$lineCount++;
		};
	close RH;
};

print "$lineCount Zeilen Code\n";

sleep 2;