#!/usr/bin/perl

$|++;
$SIG{PIPE} = sub { my @c = caller(); die "PIPE @c\n"; };
$SIG{SEGV} = sub { my @c = caller(); print "\nSEGV @c\n"; };
$SIG{INT}  = sub { my @c = caller(); die "INT @c\n"; };
$SIG{ALRM} = sub { die };
BEGIN {
#
  our $mainpid = $$;
#  our $uipid = fork();
}


#if ($$ == $mainpid) {
  my $man = manager->new();
#} else {
# $uipid = $$;
#}

package manager;
use IO::Socket::INET;
use IO::Select;
use constant CHR => {0,'+',1,'-',2,'"',64,'=',128,'@',129,'%'};
use POSIX;
use Benchmark;
use Getopt::Std;

sub new {
  my $self = bless {}, shift;
  $self->{hpos} = 0;
  $self->{opts} = {};
  getopts('f:p:',$self->{opts});
  $self->{opts}{p} ||= 5993;
  $self->{opts}{f} ||= "$ENV{HOME}/.hosts";
  my $listen = IO::Socket::INET->new(Listen    => 10,
				     LocalPort => $self->{opts}{p},
				     Proto     => 'tcp',
				     Reuse => 1,
				    );

  unless($listen) {
    print "Failed to bind port:\n\t$@\n";
    exit 1;
  }
#  $SIG{INT} = sub { print "Closing $listen\n"; $listen->close(); exit(0); };
  $self->load_hosts();
  $self->{sel} = IO::Select->new($listen);
  $self->{disp}{$listen}{sub} = $self->gen_cb('accept');#sub { $self->accept(@_) };
  $self->{listen} = $listen;
  END {
    $listen->shutdown(2) if $listen;
  }
#  for(qw(connect1.gnutellanet.com:6346 connect2.gnutellanet.com:6346 connect3.gnutellanet.com:6346 connect4.gnutellanet.com:6346)) {
#  for(qw(localhost:6436)) {
#    $self->connect_to_peer($_);
#  }
  my $cycle = 0;
  for (;;) {
    $cycle++;
#    print "($cycle % 1+",int(scalar(keys %{$self->{ch}})**1.4),")";
#    print " -\n";
    unless($cycle % (1+int(scalar(keys %{$self->{ch}})**1.4))) {
#	print '&';
	$self->connect_to_peer() if scalar(grep { !$self->{ch}{$_}{local} } keys %{$self->{ch}}) < 6;
    }
    unless($cycle % 250) {
      print "\nHave ",scalar(keys %{$self->{ch}})," servers\n";
      for(keys %{$self->{ch}}) {
	  print "$self->{ch}{$_}{host} buf ",length($self->{ch}{$_}{buf})," up ",(time()-$self->{ch}{$_}{time}),"s ";
	  print "$self->{ch}{$_}{agent}" if $self->{ch}{$_}{agent};
	  print "\n";
      }
      for(keys %{$self->{calls}}) {
	  print "$_ taking ",sprintf("%1.2f",$self->{calls}{$_}{time}/(100*$self->{calls}{$_}{calls})),"s on avg ($self->{calls}{$_}{calls} calls)\n";
      }
      print "Conections Stats:\n\tattempts   : $self->{conn}{a}\n\tgood socket: $self->{conn}{s}\n\thandshake  : $self->{conn}{h}\n\tdata       : $self->{conn}{d}\n";
    }
    unless($cycle % 1500) {
#      print "\nPinging $cycle ",scalar(keys %{$self->{ch}})," servers\n";
#      for(values %{$self->{ch}}) {
#	$self->send_ping($_->{sock});
#      }
      $self->write_hosts();
    }
#    print '#';
    for(1..5) {
	if (my @in = $self->{sel}->can_read(.02)) {
	    for(@in) {
		unless($self->{disp}{$_}{sub}) {
		    #	  print "NO CALLBACK $_ $listen\n";
		    $self->remove_peer($_);
		    next;
		}
		select(undef,undef,undef,.01);
		$self->{disp}{$_}{sub}->($_)
	    }
	    #      print "$_\n" for @in;
	}
    }
    select(undef,undef,undef,.05);
  }
  $self;
}

sub gen_cb {
    my $self = shift;
    my $subname = shift;
    my $sub = $self->can($subname);
    return unless $sub;

    return sub { 
#	my $t = (POSIX::times)[0]; 
	$self->$sub(@_); 
#	$self->{calls}{$subname}{time} += (POSIX::times)[0] - $t; 
#	$self->{calls}{$subname}{calls}++; 
    };
}
 
sub DESTROY {
# print "DESTROYING $_[0] - $_[0]->{listen}\n";
# print join(" ",%{$_[0]}),"\n";
# $_[0]->{listen}->close() if $_[0]->{listen};
}

sub accept {
  my $self = shift;
  my $listen = shift;
  my $sock = $listen->accept();
  print "In Accept!\n";
  $self->{disp}{$sock}{sock} = $sock;
  $self->{sel}->add($sock);
  $self->{disp}{$sock}{sub} = $self->gen_cb('incoming');#sub { $self->incoming(@_) };
}

sub connect_to_peer {
    my $self = $_[0];
    my $t = (POSIX::times)[0];
    &wrap_ctp;
    $self->{calls}{connect_to_peer}{calls}++;
    $self->{calls}{connect_to_peer}{time}+=(POSIX::times)[0]-$t;;
}

sub wrap_ctp {
  my $self = shift;
  my $host = ($_[0] || $self->get_next_host());
  return unless $host;
  return if $self->{tried}{$host}++;
  $self->{conn}{a}++;
  print '~';
  my $sock;
  eval {
    alarm(1);
    $sock = IO::Socket::INET->new(PeerAddr => $host);
    alarm(0);
  };
  unless($sock) {
#    print "\nfail: no connect $host $sock ",$!+0," $!\n";
      $self->remove_host($host) if($! == 9 || $! == 113);
      return;
  }
  my $connect = "GNUTELLA CONNECT/0.6\r\n\r\n";
  $self->swrite($sock,$connect);
  $self->{disp}{$sock}{sock} = $sock;
  $self->{sel}->add($sock);
  $self->{disp}{$sock}{sub} = $self->gen_cb('incoming');#sub { $self->incoming(@_) };
  $self->{conn}{'s'}++;
  print '*';
}

sub incoming {
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  my $buf;
  print "\$-";
  if ($self->sread($sock,$buf,1024,0)) {
    $dat->{buf} .= $buf;
  }
  
  #print "\n>> $dat->{buf}\n<<\n";
  if ($dat->{buf} =~ s/^(.*)\n[ \t\r]*\n//s) {
    my $header = $1;
    if ($header =~ m{GNUTELLA(?:/(0\.6))? (?:CONNECT/(\d+\.\d+)|(?:200 )?OK)}) {
      if ($2 <= .6) {
	my $version = ($1 || $2);
	my $in = $2 ? 1 : 0;
#	print "\nGood connect! $version $sock\n$header\n";
	$self->{ch}{$sock} = { host => inet_ntoa($sock->peeraddr) , sock => $sock, time => time(), version => $version };
	
	$self->{ch}{$sock}{local} = 1 if $self->{ch}{$sock}{host} eq '127.0.0.1';

	if(!$self->{connected}{$self->{ch}{$sock}{host}} && $version == .6) {
	    print "$sock SEND: GNUTELLA/0.6 200 OK\r\nUser-Agent: Pgnut\r\n\r\n";
	  $self->swrite($sock,"GNUTELLA/0.6 200 OK\r\nUser-Agent: Pgnut\r\n\r\n");
	}
	$self->{connected}{$self->{ch}{$sock}{host}} = 1;
	if($in) {
	  if($version <= .4) {
	    $self->swrite($sock,"GNUTELLA OK\r\n\r\n");
#	    print "SEND: GNUTELLA OK\r\n\r\n";
	  } else {
#	    print "WAIT FOR MORE\n";
	    $self->incoming($sock);
	    return;
#	    return if $version == .6;
	  }
	} else {
	    if($header =~ /^User-Agent:\s*(.*)/mi) {
		$self->{ch}{$sock}{agent} = $1;
	    }
	}
	$self->send_ping($sock);
	$dat->{sub} = $self->gen_cb('packet_header');#sub { $self->packet_header(@_) };
	$self->{conn}{h}++;
	return;
      } else {
	  
	$self->remove_peer($sock);
	return;
      }
    } else {
	if($header =~ /X-Try:\s*(\S*)/) {
	    for(split ',', $1) {
		print '_';
		$self->add_host($_);
	    }
	}
	if($header =~ /X-Try-Ultrapeers:\s*(\S*)/) {
	    for(split ',', $1) {
		print '_';
		$self->add_host($_);
	    }
	}
      $self->remove_peer($sock);
      return;
    }
  }
}

sub sread {
 my $self = shift;
 unless($_[0]->connected) {
#   print "GOT EOF!\n";
   $self->remove_peer($_[0]);
   return;
 }
 eval {
   alarm(2);
   my $bytes = sysread($_[0],$_[1],$_[2],$_[3]);
   alarm(0);
   unless($bytes) {
     $self->remove_peer($_[0]);
   }
   $self->{disp}{$_[0]}{read} += $bytes;
 };
}

sub swrite {
 my $self = shift;
 unless($_[0]->connected) {
#   print "GOT EOF write!\n";
   $self->remove_peer($_[0]);
   return;
 }
# print " SEND ",length($_[1]),"\n$_[1]\n";
 eval {
   alarm(3);
   $self->{disp}{$_[0]}{writ} += syswrite($_[0],$_[1],length($_[1]));
   alarm(0);
 };
 $self->remove_peer($_[0]) if $@; 
}

sub packet_header {
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  do {
    my $buf;
    my $i = 0;
    for (;;) {
      if (length($dat->{buf}) >= 23) {
	last;
      }
      return if $i++;
      if ($self->sread($sock,$buf,1024,0)) {
	$dat->{buf} .= $buf;
      }
    }
    if (length($dat->{buf}) >= 23) {
      my @d = unpack('L4CCCL',$dat->{buf});
      unless($self->check_header({type => $d[4], len => $d[7]})) {
	substr($dat->{buf},0,1,'');
	next;
      }
      substr($dat->{buf},0,23,'');
      my $conid = join ' ', @d[0..3];
      $dat->{header} = { conidstr => $conid, conid => [@d[0..3]], type => $d[4], ttl => $d[5], hops => $d[6], len => $d[7] };
      if(!$dat->{good} && $dat->{header}{type} != 1) {
	  $self->{conn}{d}++;
	  print "\e[35m#\e[0m";
	  $dat->{good}++;
      }
      $dat->{sub} = $self->gen_cb('packet_body');
      $dat->{sub}->($sock);
    }
  } while (length($dat->{buf}) >= 23);
}

sub packet_body {
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  my $i = 0;
#  my %chr = (0,'+',1,'-',128,'@',129,'%',40,'=');

  for (;;) {
    if (length($dat->{buf}) >= $dat->{header}{len}) {
      last;
    }
    return if $i++;
    if ($self->sread($sock,$buf,1024,0)) {
      $dat->{buf} .= $buf;
    }
  }

  my $data = substr($dat->{buf},0,$dat->{header}{len},'');
  $dat->{sub} = $self->gen_cb('packet_header');#sub { $self->packet_header(@_) };

#  unless($self->check_header($dat->{header})) {
#  unless(CHR->{$dat->{header}{type}}) {
#      print "\n\nACK Bad type -$dat->{header}{type}- ",length($dat->{header}{type}),"\n";
#      $self->remove_peer($sock);
#      return;
#  }

  if($dat->{header}{type} == 2) {
      my @b = unpack('SZ*',$data);
      if($b[0] >= 200 && $b[0] <= 600) {
	  print "\n$dat->{host} said 'bye' with Code $b[0] - $b[1]\n";
	  $self->remove_peer($sock);
      }
      return;
  } 
  if ($dat->{header}{type} & 1) { # response
      print (CHR->{$dat->{header}{type}} || '?');
    if($dat->{header}{type} == 1) {
      my @in = unpack('SC4LL',$data);
      $self->add_host(join('.',@in[1..4]).":$in[0]");
    }
    if(exists $self->{idh}{$dat->{header}{conidstr}} && exists $self->{ch}{$self->{idh}{$dat->{header}{conidstr}}}) {
#	print "Routing PONG" if $dat->{header}{type} == 1;
      my $pkt = pack('L4CCCL',@{$dat->{header}{conid}},$dat->{header}{type},$dat->{header}{ttl}-1,$dat->{header}{hops}+1,$dat->{header}{len});
      $self->swrite($self->{idh}{$dat->{header}{conidstr}},$pkt.$data);
    }
  } else {			# request
      if ($dat->{header}{type} == 0) {
      $self->send_pong($sock);
    }
#    if ($dat->{header}{type} == 128) {
#      my @in = unpack("SZ*",substr($dat->{buf},0,$dat->{header}{len}));
#      print "> @in\n";
#    }
    if($self->handle_conid($sock)) {
      unless($dat->{header}{ttl} == 1 || ($dat->{header}{ttl} + dat->{header}{hops} > 7)) {
	my $pkt = pack('L4CCCL',@{$dat->{header}{conid}},$dat->{header}{type},$dat->{header}{ttl}-1,$dat->{header}{hops}+1,$dat->{header}{len});
	print (CHR->{$dat->{header}{type}} || '?');
#    print "SEND PING\n" if $dat->{header}{type} == 0;
	for(keys %{$self->{ch}}) {
	  next if $_ eq $sock || $self->{ch}{$_}{local};
	  $self->swrite($self->{ch}{$_}{sock},$pkt.$data);
	}
      }
    }
  }
  delete $dat->{header};
}

sub check_header {
  my $self = shift;
  my $hdr = shift;
  
  if ($hdr->{type} == 0) {
    return if $hdr->{len} != 0;
  } elsif ($hdr->{type} == 1) {
    return if $hdr->{len} != 14;
  } elsif ($hdr->{type} == 2) {
    return if $hdr->{len} > 1024;
#  } elsif ($hdr->{type} == 4) {
#    return if $hdr->{len} >= 140;
  } elsif ($hdr->{type} == 64) {
    return if $hdr->{len} != 26;
  } elsif ($hdr->{type} == 128) {
    return if $hdr->{len} >= 257;
  } elsif ($hdr->{type} == 129) {
    return if $hdr->{len} >= 67_075;
  } else {
    return;
  }
  return 1;
}

sub handle_conid {
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  return if(exists $self->{idh}{$dat->{header}{conidstr}});
  $self->{idh}{$dat->{header}{conidstr}} = $sock;
  push @{$self->{ida}}, $dat->{header}{conidstr};
  delete $self->{idh}{shift @{$self->{ida}}} if(@{$self->{ida}} > 10000);
  1;
}

sub remove_peer {
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  print ($dat->{good} ? "\e[35mX\e[0m" : 'x');
  my @c = caller();
  print "\nconnection to $self->{ch}{$sock}{host} lost \@ @c\n" if $self->{ch}{$sock}{host};
  delete $self->{disp}{$sock};
  $self->{sel}->remove($sock);
  delete $self->{ch}{$sock};
#  $self->connect_to_peer();
}

sub send_pong {
#  return;
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  my $pkt = pack('L4CCCL',@{$dat->{header}{conid}},1,$dat->{hops},0,14);
  $pkt .= pack('SC4LL',5993,24,128,221,140,3,234);
  $self->swrite($sock,$pkt);
}

sub send_ping {
#  return;
  my $self = shift;
  my $sock = shift;
  my $dat = $self->{disp}{$sock};
  my $pkt = pack('L4CCCL',(map { int(rand(999999)) } (1..4)),0,5,0,0);
  $self->swrite($sock,$pkt);
#  print "Sent PING ",length($pkt)," $dat->{writ}\n";
}


sub load_hosts {
  my $self = shift;
  if(open(my $hosts, $self->{opts}{f})) {
    while(<$hosts>) {
      chomp;
      s/\s+/:/;
      $self->add_host($_);
    }
  }
}

sub add_host {
  my $self = shift;
  my $host = shift;
  return if $host =~ /^192\.168\./;
#  delete $self->{tried}{$host};
  $self->remove_host($host);
  $self->{hpos} = 0 if ($self->{hpos} < 0 || $self->{hpos} >= @{$self->{ha}});
  splice @{$self->{ha}}, $self->{hpos}, 0, $host;
  $self->{hh}{$host} = 1;
}

sub remove_host {
    my $self = shift;
    my $host = shift;
    if(exists $self->{hh}{$host}) {
	for(my $i = 0; $i < @{$self->{ha}}; $i++) {
	    if($self->{ha}[$i] eq $host) {
		splice @{$self->{ha}}, $i, 1;
		$self->{hpos}-- if($i >= $self->{hpos});
		last;
	    }
	}
    }    
}

sub get_next_host {
  my $self = shift;
  for(1..10) {
    print '^' if $_ > 1;
    $self->{hpos}++;
    $self->{hpos} = 0 if($self->{hpos} >= @{$self->{ha}});
    my $key = (split ':',$self->{ha}[$self->{hpos}])[0];
    next if exists $self->{connected}{$key};
    next if exists $self->{tried}{$self->{ha}[$self->{hpos}]};
    last;
  } 
  return $self->{ha}[$self->{hpos}];
}

sub DESTROY {
  $_[0]->write_hosts();
}

sub write_hosts {
  my $self = shift;
  if(open(my $hosts, ">$self->{opts}{f}")) {
    print $hosts join("\n",@{$self->{ha}});
  }
}

