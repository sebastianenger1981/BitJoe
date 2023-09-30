#!/usr/bin/perl

# autonuts v3.0 by cider (slf@dreamscape.org)
# "my music collection has a juicy new center!"
# this version tries to avoid using expect. Expect sucks.
# mutella is vastly superior to gnut, will try to find better hosts
# for the file downloads while they are downloading or if fails
# you can also start up mutella manually after it has ran long enough
# to download the files if you wish to type list or info to track
# the progress. i am strongly in favor of this approach instead of
# my former tactics with gnut.
# http://enraptured.compulsion.org/code/
#
# autonuts is designed to pillage and data-mine gnutella using the
# command line gnutella client "mutella", using pure perl.
#
# this version is designed to run for 30 minutes after horizon and download
# requests are fired off, and then exits suitable for suicide batch jobs.
#
# usage: autonuts your simple text bandname here
#    ie: autonuts sneakerpimps &
#        autonuts the cure &
#        autonuts fugazi &
#                             ;)


use Term::ANSIColor;
use Text::Soundex;
use IPC::Open2;
$| = 1;

$ENV{TERM} = "dumb";
$SIG{INT} = sub { system "killall -9 mutella"; die "dying with cleanup.\n"; };

$archive = "."; # where our mp3s are located and downloaded to

$band = shift || die "who do you want to search for?\n";

$wantcap = 2; # this number is how many gigs of storage to wait for before searching
$testphrase = "$band"; # this is your generic search phrase for the search test

check_existing_songs($band);

my($r,$w);				# my read and write filehandles, globals definitely!
open2($r, $w, 'TERM=dumb mutella 2\>/dev/null') or die;	# does what open FH, "| cmd |" dosent
printuntil("Enjoy");		# wait until mutella's ready..

print $w "set MinConnections 4\n";
find_prompt();
print $w "set MaxConnections 8\n";
find_prompt();
print $w "set TerminalCols 2048\n";
find_prompt();

#print $w "info\n";
#printuntil("total transfers");

#print $w "help\n";
#printuntil("no parameters");

parse_list_kill_previous_searches();

loop_for_horizon();

loop_for_searchtest();

%songs = ();
%songs = get_results();
process_responses();

list();

getuniq();

interact1();

#print $w "set\n";
#printuntil("RetryDelay");

print $w "exit\n";
print "trying to die.\n";
print "massacaring the remaining mutella processes.\n";
system "killall -9 mutella";
die "dead.\n\n";



### END..

sub loop_for_horizon
{
	my $cap;
	my $oldcap;

	print "\n\@ waiting for adequate searchable storage... (want $wantcap gigs)";
	
	while(1)
	{
		#print $w "info\n";
		#printuntil("total transfers");

		$oldcap = "$cap";

		print $w "info\n";
		while(<$r>)
		{
			s/\e\[.*?m//g;
			chomp;
			#print "\n\| debug: $_";
			$cap = $1 if /Capacity:\s(.*?)$/;
			last if (/total transfers:/);
			
		}
		
		if ($cap =~	/.*?M$/)   { $cap = 0; }
		if ($cap =~ /(.*?)G$/) { $cap = int($1); }
	
		unless ($oldcap eq $cap) {
			print "\n\# capacity: ${cap} (need >${wantcap} gigs).." if (defined $cap);
			
			if ($cap > $wantcap)
			{
				print "\n! * network horizon of $wantcap gigs searchable storage reached.\n";
				last;
			}
			else
			{
				print "(count went down\?).." if ($oldcap > $cap);
			}
		} else
		{
		}
	
		find_prompt();

		sleep 5;
		
	}
	
}


sub loop_for_searchtest
{
	my $hits;
	my $hitz;
	my $oldhitz;
	my %keys = ();
	
	print "\n\@ performing search test for popular phrase $testphrase";
	print $w "find $testphrase\n";
	
	while(1)
	{
		print $w "list\n";
		while(<$r>)
		{
			s/\e\[.*?m//g;
			chomp;
			#print "\n\| list: ${_}";
   	   if (/(\d+)\)\s\`(.*?)\'/)
   	   {
   	   	$number = $1;
   	   	$name = $2;
   	   	#print "\n\$ name: $name";
   	   	$keys{$number}{name} = $name;
   	   }
   	   elsif (/NO HITS/)
   	   {
   	   	undef $hits;
   	   	$hits = 1;
   		  	#print "\n\$ no hits.";
   	  		$keys{$number}{hits} = $hits;
      	}
      	elsif (/HITS:(\d+)$/)
      	{
      		undef $hits;
     	 		$hits = $1;
      		#print "\n\$ $hits hits. from number $number";
      		$keys{$number}{hits} = $hits;
      	}
      
			last if (/count: /);
		}
		
		$oldhitz = $hitz;
		$hitz = $keys{$number}{hits};
		
		#unless(defined $hits) { die "$0: no hits found in loop_for_searchtest, bad i think.\n"; }
		
		if ($hitz > 255)
		{
			print "\n\! 256 results found for popular phrase $testphrase\n";
			last;
		}
		else
		{
			print "\n\# $hits result(s) found. (need 256)" unless ($hitz eq $oldhitz);
		}
		find_prompt();

		sleep 5;
	}
	
}


sub get_results
{
	my %keys = ();
	my $oldnumber;
	
	print $w "r 1\n";
	while(<$r>)
	{
		s/\e\[.*?m//g;
		chomp;
		#print "\n\| r: ${_}|";
		
		HANDLER: for ($_)
		{
			#  93) `songname.mp3' 1.96M REF:114
			/(\d+)\)\s\`(.*?)\'\s((\d|\d+)\.\d+(M|G))/ && do
			{
				$number = $1; #print "\n* number: $number";
	      	$name = $2;
   	   	$size = $3; #print "\n* size: $size";
	      	#print "\n* name: $name";
				$keys{$testphrase}{$number}{name} = $name;
				$keys{$testphrase}{$number}{size} = $size;
				last HANDLER;
			};
			
			#     LOCATIONS:2    avg.speed:ISDN
			/\s+LOCATIONS:(\d+)\s+avg.speed:(.*?)$/ && do
			{
				$locations = $1; #print "\n* locations: $locations";
				$avg_speed = $2; #print "\n* avgspeed: $avg_speed";
				$keys{$testphrase}{$number}{locations} = $locations;
				$keys{$testphrase}{$number}{avgspeed} = $avg_speed;
				last HANDLER;
			};

			#    extra: 128 Kbps 44 kHz 2:08
			/\s+extra:\s(.*?)$/ && do
			{
				# i dont think i care about this field.
				last HANDLER;
				$extra = $1;
				next if ($extra eq '');
				#print "\n* extra: $extra";
				last HANDLER;
			};
			
			#      172.153.67.104:6346 speed:56K Modem    BearShare    time:4m9s
			/\s+(.*?\d+)\sspeed:(.*?)\s{2,}/ && do
			{
				$host = $1; #print "\n* host: $host";
				$speed = $2; #print "\n* speed: $speed";
				$keys{$testphrase}{$number}{speed}{$host} = $speed;
				last HANDLER;
			};

			#print "\nhuh? ::${_}::";
		}
      
		last if (/count: /);
	}
	find_prompt();
	return %keys;
}

sub parse_list_kill_previous_searches
{
	my %keys = ();
	print $w "list\n";
	while(<$r>)
	{
		s/\e\[.*?m//g;
		chomp;
		#print "\n\| list: $_";
      if (/(\d+)\)\s\`(.*?)\'/)
      {
      	$number = $1;
      	$name = $2;
      	#print "\n\$ name: $name\n";
      	$keys{$number}{name} = $name;
      }
      elsif (/NO HITS/)
      {
      	#print "\n\$ no hits.";
      	$keys{$number}{hits} = 0;
      }
      elsif (/HITS:(\d+)/)
      {
      	$hits = $1;
      	#print "\n\$ $hits hits.\n";
      	$keys{$number}{hits} = $hits;
      }
      
		last if (/count: /);
	}
	find_prompt();
	foreach $key (sort keys %keys)
	{
		print "\n\$ stopping existing search \#${key} on subject $keys{$key}{name}";
		print $w "del $key\n";
		find_prompt();
	}
	# DELETE THE PARTIALS! CHECK THIS DIRECTORY TO MAKE SURE ITS ACCURATE
	print "\n\$ deleting partials if any.";
	system "rm ~/mutella/part/* 2> /dev/null";
}



sub printuntil
{
	my $until = shift or die;
	my $quiet = shift;
	while(<$r>)
	{
		s/\e\[.*?m//g;
		chomp;
		print "\n! autonuts: $_" unless ($quiet eq 1);
		last if /$until/;
		# ready for our abuse...
	}
	find_prompt();
}

sub find_prompt
{
	#print "\n";
	#print "! * finding prompt: ";
	$gt = getc($r);
	$space = getc($r);
	#if ($gt eq '>' && $space eq ' ') { print "ok, found.\n"; }
	#else { print "NOT found.\n"; }
}


sub process_responses
{
	%available = %songs;
	
	my $result_count;
	%sounds = ();
	
	foreach (sort keys %available)
	{
		$search = $_;
		foreach (sort keys %{ $available{$search} })
		{
			$number = $_;

			my $song = $available{$search}{$number}{name};
			my $size = $available{$search}{$number}{size};

			$result_count++;
				
			$isize = int($size);
			next unless ($size =~ /m$/i); # should be in the meg ballpark
			next unless ($isize > 2); # should be bigger then two megs
			next unless ($isize < 10); # should be less than ten megs

			$song = lc($song); # change the song to lowercase
			$song =~ s/_/ /g; # change underscores to spaces
			$song =~ s/\.mp3//gi; # remove the file extension
			$song =~ s/\s{0,}[\(\[].*?[\[\(].*?[\]\)].*?[\]\)]\s{0,}//g; # remove double variant comments eg: (remix(its phat))
			$song =~ s/\s{0,}[\(\[].*?[\]\)]\s{0,}//g; # remove variant comments eg: (remix)
			$song =~ s/${band} - .* - (.*?)$/${band} - $1/g; # greedy attempt at removing album names
			next unless ($song =~ /$band - .*?/i); # should resemble band with a title
				
			$title = $1 if ($song =~ /${band} - (.*?)$/);

			$code = soundex $title;
			next unless ($code =~ /^\w+/);

			$already_have = 0;

			foreach (@already_have)
			{
				$ihave = $_;
				$ihavecode = $1 if ($ihave =~ /^(.*?) /);
				$uhave = "$code $title";
				# if it sounds like something we already have,
				# we probably dont want it.
				if ($uhave =~ /^$ihavecode /)
				{
					$already_have = 1;
					print "** passing by: $code $title\n";
				}
			}

			if ($already_have eq 0)
			{
				print "** marking: $code $title\n";
				$accepted++;
				$sounds{$code}{title} = $title;
				$sounds{$code}{number} = $number;
			}
		}
	}
}

sub list {		
		foreach $codes (sort keys %sounds) {
			$uniq++;
			print "$codes [$sounds{$codes}{number}]\t$sounds{$codes}{title}\n";
		}
		print "$uniq unique that you don\'t already have.\n";
		undef $uniq;
}
	
sub getuniq {
		$total_songs_to_get = 0;
		print "i'll take";
		foreach $codes (sort keys %sounds) {
		   $total_songs_to_get++;
			$num = $sounds{$codes}{number};
			$num2 = $sounds{$codes}{number2} if defined($sounds{$codes}{number2});
			print " ${num},";
			print $w "g $num\n";
			if(defined($num2)) {
				# the backup request... in case the first one was firewalled or slow
				print $w "g $num2\n";
			}
			undef $num2;
		}
		print " and that aughta do it.\n";
		print "Made $total_songs_to_get song download request.\n";
		
	
		print "\n";
		#print "Trying to acquire ${total_songs_to_get} by ${band}...\n";
		#list();
}



sub green
{
	my $msg = shift or die;
	print colour 'green';
	print "$msg";
	print colour 'reset';
	print "\n";
}

sub interact1 {
		die "something didnt work at all, cutting losses and moving on...\n" if ($total_songs_to_get eq 0);
		
		print "\n";
		print "Sit back and wait for thirty minutes please. This script will need to\n";
		print "be restarted later to continue collecting.\n\n";
		print "flip";
  	   $flipstr = "flip";
		for (1..30) {
		 for (1..60) {
		  if ($flipstr eq "flip") { $flipstr = "flop"; }
		  elsif ($flipstr eq "flop") { $flipstr = "flip"; }
		  print "\b\b\b\b$flipstr";
		  sleep 1;
		 }
		 print " $_ min.\n    ";
		}
	   print "\ndying!\n";
	   system "killall -9 mutella";
}
		
sub check_existing_songs {
	$num_songs = 0;
	$group = shift;
	$group =~ s/ /_/g;
	print "purging temporary transfers if any in this directory..\n";
	system "rm $archive/*.gnut 1> /dev/null 2> /dev/null";
	print "opening existing archive...\n";
	print "**" . uc($band) . "**" . "\n";
	opendir OFF, "$archive" or return "no archive directory found.\n";
	while($song = readdir OFF) {
		next if ($song =~ /^\.|\.\.$/);
		next unless ($song =~ /\.mp3$/i);
		$song = lc($song); # change the song to lowercase
		$song =~ s/_/ /g; # change underscores to spaces
		$song =~ s/\.mp3//gi; # remove the file extension
		$song =~ s/\s{0,}[\(\[].*?[\[\(].*?[\]\)].*?[\]\)]\s{0,}//g; # remove double variant comments eg: (remix(its phat))
		$song =~ s/\s{0,}[\(\[].*?[\]\)]\s{0,}//g; # remove variant comments eg: (remix)
		$song =~ s/${band} - .* - (.*?)$/${band} - $1/g; # greedy attempt at removing album names
		next unless ($song =~ /$band - .*?/i); # should resemble band with a title
		$title = $1 if ($song =~ /${band} - (.*?)$/);
		$code = soundex $title;
		#print "you have: $code $title\n";
		push @already_have, "$code $title";
		$num_songs++;
	}
	closedir OFF;
	unless ($num_songs eq 0) {
	 print "$num_songs songs total!\n";
	} else {
	 print "We haven't gotten any songs yet, just you wait!\n";
	}
}

