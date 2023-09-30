#!/usr/bin/perl

$SIG{ALRM} = sub { die };

do 'client2';

use URI::Escape;
use IO::Select;
use IO::Handle;

our %skip;
our %files;
#our 
sub download {
  my %info = ( size => shift, file => shift );
  my $list = shift;
  my $write_file = 0;
  if(-s "dlinfo/$info{size}" && open(my $i, "dlinfo/$info{size}")) {
    local $/;
    %info = split "\n", <$i>;
#    print "Using old name $info{file}\n";
  } else {
      $write_file = 1;
  }
  $info{search} = \@searches;
  return if $info{complete};
  my $start = -s $info{file};
  return if $start >= $info{size};
  if(my $pid = fork()) {
    return $pid;
  }

  for(keys %$list) { #serverlist
    my($serv,$id) = split("\t", $_);
    my $name = $list->{$_};
    next if $skip{$serv};
    $start = (-s $info{file} || 0);
    my $sock;
    print '.';
#    print "> $info{size} $serv\n";
    eval {
      alarm(3);
      $sock = new IO::Socket::INET
	PeerAddr => $serv,
	  Proto    => "tcp";
      alarm(0);
    };
#    print ".";
    if ($@) {
#      print STDERR "Sock timed out\n";
	print 'o';
      next;
    }
    unless($sock) {
#      print STDERR "Connection to $serv failed\n";
	print 'O';
      next;
    }
    print ':';
#    print STDERR "Start is at $start\n";

    my $match;
    if ($start > 20) {
      open(FILE, $info{file}) or die $!;
      seek FILE, -20, 2;
      local $/;
      $match =  <FILE>;
      close FILE;
      $start -= 20;
    }

    #    $name = uri_escape($name);

    my $status;
    my $range;
    my $range2;
    eval {
	alarm(10);
	print $sock "GET /get/$id/$name HTTP/1.0\r\n";
	print $sock "Connection: Keep-Alive\r\n";
	print $sock "Range: bytes=$start-\r\n";
	print $sock "User-Agent: Gnutella\r\n\r\n";
	
	while ($_ = $sock->getline()) {
	    $status = $1 if (m|HTTP.*([2345]\d\d)|);
	    #      print "$status\n";
	    if (/^Content-range:/i) {
		$range2 = $_;
		$range = 1 if /[^0-9]$start[^0-9]/;
	    }
	    #      print ">>>$_";
	    last if /^\s$/;
	}
	alarm(0);
    };
    if($@) {
	print 'T';
	next;
    }
    if ($status !~ /^2/) {
	#      print STDERR "Response was $status\n";
	print 'X';
	next;
    } else {
	print '!';
      #      print STATUS "Status was $status\n";
    }
    unless(!$start || $range) {
      print "Range was $range2\nStart is $start... BAD!\n";
      next;
    }
    open(FILE, ">>$info{file}") or die $!;
    if($write_file && open(my $i, ">dlinfo/$info{size}")) {
	for(sort keys %info) {
	    if(ref $info{$_}) {
		for my $val (@{$info{$_}}) {
		    print $i "$_\n$val\n";
		}
	    } else {
		print $i "$_\n$info{$_}\n";
	    }
	}
	$i->close();
    }
    alarm(20);
    my $num = 20;
    $num = 1024 unless $start;
    my $stt = time();
    my $total_bytes = $start;
    my $tbytes = 0;
    my $i = 0;
    eval {
      for (;;) {
	alarm(30);
	$bytes = $sock->read(my $buf, $num);
	alarm(0);
	last unless $bytes;
	$total_bytes += $bytes;
	$tbytes += $bytes;
	if (!$i++ && $start) {
	    unless(check_offset($buf,$match)) {
		$skip{$serv} = 1;
		last;
	    }
	  $num = 1024;
	  next;
	}
	print "Starting download of $info{file}\n" if $i == 2;
	$num = 1024;
	#	exit if $i > 2;
	print STDERR "+";
	print FILE $buf;
	complete(\%info) if((-s $info{file}) == $info{size});
	unless($i % 500) {
	  my $bps = $tbytes/(time()-$stt);
	  	    printf "\nDownload rate is %.2fK/s\n", ($bps/1024);
	  my $ttf = (($info{size}-$total_bytes)/$bps);
	  	    printf "Time to finish: ";
	  my(@t);
	  $t[0] = int($ttf/3600);
	  $ttf %= 3600;
	  $t[1] = int($ttf/60);
	  $ttf %= 60;
	  $t[2] = int($ttf);
	  print "$t[0]:" if $t[0];
	  printf ("%02d:", $t[1]) if ($t[0] || $t[1]);
	  printf ("%02d\n",$t[2]);
	  print "Bytes Received: $total_bytes/$info{size} (";
	  printf("%.2f%%)\n",(($total_bytes/$info{size})*100));
	  $tbytes = 0;
	  $stt = time();
	}
      }
    };
    $sock->close();
    alarm(0);
#    print "\nDownload timed out" if $@;    
#    print "\n";

    close(FILE);
  }
  complete(\%info) if((-s $info{file}) == $info{size});
  exit(0);
}

sub complete {
    my %info = %{$_[0]};
    $info{complete} = 1;
    print "$info{file} complete\n";
    if(open(my $i, ">dlinfo/$info{size}")) {
	for(sort keys %info) {
	    if(ref $info{$_}) {
		for my $val (@{$info{$_}}) {
		    print $i "$_\n$val\n";
		}
	    } else {
		print $i "$_\n$info{$_}\n";
	    }
	}
	$i->close();
    }
    exit(0);
}

sub check_offset {
  print "Checking\n";
  my @a = split '', $_[0];
  my @b = split '', $_[1];
  for (1..20) {
    print("ERROR\n"),return if $a[$_] ne $b[$_];
  }
  return 1;
}

