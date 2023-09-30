#!/usr/bin/perl

use IO::Socket;
use IO::Select;
use Getopt::Std;
use POSIX ":sys_wait_h";

our $pipe = 0;

$SIG{INT} = sub { print join(" - ",caller()),"\n"; exit; };
$SIG{PIPE} = sub { $pipe++ };

my %opts;
getopts('d:D:h:s:S:PW:p',\%opts);
$opts{W} ||= '.';
#my $target = shift @ARGV;
our(@targets,@exclude,@searches,%cache);
my $i = 0;
while($ARGV[$i]) {
    if($ARGV[$i] =~ s/^\!//) {
	push @exclude, qr/$ARGV[$i]/i;
    } elsif($ARGV[$i] =~ /\D/) {
	push @searches, lc($ARGV[$i]);
	if($ARGV[$i] =~ s/mpg/mpeg/i) {
	    push @searches, lc($ARGV[$i]);
	}
    } else {
	push @targets, $ARGV[$i];
    }
    $i++;
}

my %qr;
for(@searches) {
  my @tmp = split /\s+/, $_;
  $qr{$_} = sub { my $i = 0; for(@tmp) { return 0 if index($_[0],$_) == -1 } 1 };
}

print join(',',@targets),"\n";
print join(',',@searches),"\n";

our %targets = map { ($_,1) } @targets;
#open(OUT, ">>/home/ant/eg/tmp/$target");
our(%searches);

our $sock = conn();
$pipe = 1 unless $sock;
our $sel;

sub conn {
    my $sock = IO::Socket::INET->new(PeerAddr => ($opts{h} ||  'localhost:5993'));
    return unless $sock;
    my $connect = "GNUTELLA CONNECT/0.4\r\n\r\n";
    
    syswrite($sock,$connect,length($connect));
    my $buf;
    sysread($sock,$buf,1024,0);
#    print "-- $buf\n";
    if($buf =~ s/(.*)\n[ \t\r]*\n//) {
	my $hdr = $1;
	unless($hdr =~ /GNUTELLA.*OK/) {
	    die "ACK\n";
	}
    }
    $sel = IO::Select->new($sock);
    $sock;
}
#my $connect = "GNUTELLA/0.6 200 OK\r\n\r\n";
    
#syswrite($sock,$connect,length($connect));
    
my %dl;

sub do_downloads {
    for(sort { rand(3)-1 } keys %cache) {
	my @keys = keys %{$cache{$_}};
	if(!$opts{d} || @keys >= $opts{d}) {
	    if(defined &download && !$dl{$_} && scalar(keys(%dl)) < 10) {
		my $file = "$opts{W}/$cache{$_}{$keys[0]}";
		next if (-s $file) == $_;
		my $pid = download($_,$file,$cache{$_});
		$dl{$_} = $pid if $pid;
	    }
	}
    }
}

sub send_push {
    print "PUSHING\n";
    my $info = shift;
    my $dat = $info->{guid};
    $dat .= $info->{index};
    $dat .= pack('C4S',24,128,221,140,4567);
    my @conid = (map { int(rand(999999)) } (1..4));
    my $pkt = $info->{conid}.pack('CCCL',@conid,40,$info->{hops},-1,length($dat)).$dat;
    syswrite($sock,$pkt,length($pkt));
    
}

sub send_query {
  print STDERR "QUERYING\n";
  for my $search (@searches) {
    my @conid = (map { int(rand(999999)) } (1..4));
    $searches{"@conid"} = $qr{$search};
    my $dat = pack('SZ*',0,"$search\0");
    my $pkt = pack('L4CCCL',@conid,128,5+int(rand(4)),-1,length($dat)).$dat;

    syswrite($sock,$pkt,length($pkt));
  }
  for(sort { $a <=> $b } keys %cache) {
    my @keys = keys %{$cache{$_}};
    if(@keys >= $opts{d}) {
      print scalar(@keys)," - $_ $cache{$_}{$keys[0]}\n" if $opts{d};
      if($opts{D}) {
	mkdir($opts{D},0755) unless -e $opts{D};
	if(open(my $out, ">$opts{D}/$_")) {
	  for my $key (@keys) { 
	    print $out "$key\t$_\t$cache{$_}{$key}\n";
	  }
	}
      }
    }
  }
}
$|++;
my $cycle = 0;
for(;;) {
    do_downloads() unless $cycle % 20;
    send_query() unless $cycle++ % 200 || $pipe;
    if(keys %dl) {
	while (($pid = waitpid(-1,WNOHANG)) > 0) {
	    for(keys %dl) {
		delete $dl{$_} if $dl{$_} == $pid;
	    }
	}
    }
    unless($sock && $sock->connected) {
	print "&";
	$sock = conn();
	print "CONNECTED\n" if $sock;
	$pipe = 0 if $sock;
	select(undef,undef,undef,30);
	next;
    }
    if($sel->can_read(1)) {
	my $b;
	sysread($sock,$b,1024,0);
	$buf .= $b;
	while(length($buf) >= 23) {
	    my $data;
	    my $conid = substr($buf,0,16);
	    my @d = unpack('L4CCCL',substr($buf,0,23,''));
	    if($d[7]) {
		while(length($buf) < $d[7]) {
		    sysread($sock,$b,1024,0);
		    $buf .= $b;
		}
		$data = substr($buf,0,$d[7],'');
	    }
	    next unless $d[4] == 129;
#	    print "+";
	    my $key = "@d[0..3]";
	    next unless exists $searches{$key};
	    my %hdr;
	    my $count = unpack("C",  substr($data, 0, 1, ''));
	    my $port  = unpack("S",  $hdr{port} = substr($data, 0, 2, ''));
	    my @ip    = unpack("C4", $hdr{ip} = substr($data, 0, 4, ''));
	    my $speed = unpack("L",  substr($data, 0, 4, ''));
	    my $guid = $hdr{guid} = substr($data,-16);
	    $hdr->{hops} = $d[6];
	    $hdr->{conid} = $conid;
	    next if $ip[0] == 192 && $ip[1] == 168;	    

	    for (my $i = 0; $i < $count; $i++) {
		my %myhdr = %hdr;
	      my $index = unpack("L", $myhdr{index} = substr($data, 0, 4, ''));
	      my $size  = unpack("L", substr($data, 0, 4, ''));
	      my($name) = $myhdr{name} = substr($data, 0, index($data, "\0"), '');
	      substr($data,0,1,'');
	      my($extra) = substr($data, 0, index($data, "\0"), '');
	      substr($data,0,1,'');
	      next unless $size; 
	      
		next if($opts{P} && porn_check($name));
		next if($opts{p} && !porn_check($name));
		next unless $name =~ /\S/;		
		my $skip = 0;
		for(@exclude) {
		    $skip++ if $name =~ /$_/;
		}
		next if $skip;
		next if index($name,'secret paysite passwords for ') != -1;
		next unless $searches{$key}->(lc($name));
		next if $opts{s} && $opts{s} > $size;
		next if $opts{S} && $opts{S} < $size;
		next if $size > 1_000_000_000;
		next if $index > 100_000;
		local $" = '.';
		print "=";
		$cache{$size}{"@ip:$port\t$index"} = $name if $opts{d};
		next unless $targets{$size};
		next if $cache{$size}{"@ip:$port\t$index"};
		$cache{$size}{"@ip:$port\t$index"} = \%myhdr;
		local $" = '.';
		my $ent = "@ip:$port\t$index\t$size\t$name\n";
		print "\n$ent";
		next;
		if(open(my $out, "$ENV{HOME}/eg/tmp/$size")) {
		    my $match = 0;
		    while(<$out>) {
			if($_ eq $ent) {
			    $match = 1;
			    last;
			}
		    }
		    last if $match;
		}
		if(open(my $out, ">>$ENV{HOME}/eg/tmp/$size")) {
		    print $out $ent;
		} else {
		    print "Problem opening $ENV{HOME}/eg/tmp/$size: $!\n";
		}
	      }
	    my @guid = unpack("L4", substr($data, 0, 16, ''));
#	    print "... $count\n";
#	    exit if $count > 2;
#	    for(@set) {
#	    }
	}
	select(undef,undef,undef,.5);
    }
}

sub porn_check {
  my $count = 0;
  $_ = lc($_[0]);
  $count++ if index($_,'xxx') != -1;
  $count++ if index($_,'jenna') != -1;
  $count++ if index($_,'jameson') != -1;
  $count++ if index($_,'cock') != -1;
  $count++ if index($_,'pussy') != -1;
  $count++ if index($_,'cunt') != -1;
  $count++ if index($_,'porn') != -1;
  $count++ if index($_,'slut') != -1;
  $count++ if index($_,'sex') != -1;
  $count++ if index($_,'girls') != -1;
  $count++ if index($_,'amateur') != -1;
  $count++ if index($_,'fuck') != -1;
  $count++ if index($_,'suck') != -1;
  $count++ if index($_,'ass') != -1;
  $count++ if index($_,'strip') != -1;
  $count++ if index($_,'masturbate') != -1;
  $count++ if index($_,'audition') != -1;
  $count++ if index($_,'lolita') != -1;
  $count++ if index($_,'erotic') != -1;
  $count++ if index($_,'lesbian') != -1;
  $count++ if index($_,'private') != -1;
  $count++ if index($_,'adult') != -1;
  $count++ if index($_,'anal') != -1;
  $count++ if index($_,'facial') != -1;
  $count++ if index($_,'cum') != -1;
  $count++ if index($_,'gay') != -1;
  $count+=2 if index($_,'bangbus') != -1;
  return 1 if $count > 1;
}

1;

