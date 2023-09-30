use LWP::Simple;

_GetExtractStore();

sub _GetExtractStore(){
		
		my $url		= shift || "http://gwc2.nonexiste.net:8080/";
		
		my $doc		= get($url);
		my @content = split(">", $doc);
		my $content;
		#my $time	= time();
		
		for ( my $i=0; $i<=$#content; $i++ ) {
			
			if ( $content[$i] =~ /^([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)\.([\d{0,255}]+)+[\:]+[\d{1,5}]/ ) {
				
				#IP:PORT</A
				$content[$i] =~ s/<\/a//ig;
				$content[$i] =~ s/<\/td//ig;
				print "$content[$i]\n";

			}; # if ( $content[$i] =~ ...

		}; # for ( my $i=0; $i<=$#content; $i++ ) {}
			
	}; # sub _GetExtractStoreInstall()){}