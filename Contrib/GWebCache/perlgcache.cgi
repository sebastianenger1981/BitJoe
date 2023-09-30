#!/usr/bin/perl -wT
use strict;
#use Data::Dumper;

# Copyright (c) 2003-2004 Jon Atkins http://www.jonatkins.com/
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.



my $cacheversion = "0.8.3";

###### options ######

# OPTIONS HAVE BEEN MOVED INTO A SEPARATE FILE: default perlgcache.conf
my $config = "./perlgcache.conf";



use vars qw( %config );

$config{prefix} = "data";

$config{maxv1urlret} = 10;
$config{maxv2urlret} = 5;

$config{maxurlstore} = 500;
$config{maxurlage} = 7.3*24*60;
$config{minurlcheck} = 1.1*24*60;

$config{maxhost} = 20;
$config{maxhostage} = 24*60;

$config{blockv1anon} = 0;

$config{enablestats} = 1;

$config{updatelimit} = 55;

$config{checkurls} = 1;
$config{checkhosts} = 0;

$config{proxyhost} = undef;
$config{proxyport} = undef;

$config{requestlimitcount} = 10;
$config{requestlimittime} = 55;

$config{enablev1requests} = 1;
$config{enablev2requests} = 1;

$config{styleurl} = -f "perlgcache.css" ? "perlgcache.css" : "http://www.jonatkins.com/perlgcache/style/perlgcache.css";

$config{statfileurls} = [];

$config{bannedclients} = {};


# now process perlgcache.conf for additional options
my $config_ok = defined do $config;




###### global vars #####

# globals: read time once - to avoid possible race conditions
# note: values set at the top of dorequest() - ready for FastCGI version
use vars qw( $time $day );


###### subroutines ######

# first, generic routines...

sub error
{
	my ( @args ) = @_;

	print "ERROR: ".(join ' ', @args)."\n";
	exit;
}

sub paramdecode
{
	my ( $query ) = @_;

	my %param;

	return () unless defined $query;

	foreach my $arg ( split /&/, $query )
	{
		my ( $name, $val ) = split /=/, $arg;

		next unless defined $name and defined $val;

		$val =~ s/\+/ /g;
		$val =~ s/%([0-9a-fA-F]{2})/chr hex $1/eg;

		$param{$name} = $val;
	}

	return %param;
}


sub loadtextfile
{
	my ( $filename ) = @_;

	open IN, "$filename" or return ();

	my @data = <IN>;
	chomp @data;
	close IN;

	return @data;
}

sub savetextfile
{
	my ( $filename, @data ) = @_;

	my $tempfile = "$filename.tmp.$$~";

	open OUT, "> $tempfile" or die;
	foreach my $line ( @data )
	{
		print OUT "$line\n" or die;
	}
	close OUT or die;

	rename $tempfile, $filename or error "rename of $tempfile to $filename failed";
}

sub loadarrayhash
{
	my ( $filename ) = @_;


	my @array;

	my @filedata = loadtextfile $filename;

	my $header = shift @filedata;
	return () unless defined $header;

	my @fields = split /\|/, $header;

	foreach my $line ( @filedata )
	{
		my @items = split /\|/, $line, scalar @fields;

		my %item;
		for ( my $i=0; $i < @items; $i++ )
		{
			$item{$fields[$i]} = defined $items[$i] ? $items[$i] : '';
		}

		push @array, \%item;
	}

#print Dumper ( \@array );

	return @array;
}

sub savearrayhash
{
	my ( $filename, @array ) = @_;

	my @filedata;

	return if @array == 0;

	my @fields = sort keys %{$array[0]};

	push @filedata, join "|", @fields;


	foreach my $item ( @array )
	{
		my $fileline;

		my $first = 1;
		foreach my $field ( @fields )
		{
			$fileline .= "|" unless $first;
			$first = 0;

			my $val = ${$item}{$field};
			$val = '' unless defined $val;

			$fileline .= "$val";
		}
		push @filedata, $fileline;
	}

	savetextfile $filename, @filedata;

}


sub loadhashhashfromdata
{
	my ( @filedata ) = @_;

	my %hash;

	my $header = shift @filedata;
	return () unless defined $header;

	my @fields = split /\|/, $header;

	# make sure what we have is a hash file...
	return () if $fields[0] ne 'KEY';

	foreach my $line ( @filedata )
	{
		my @items = split /\|/, $line, scalar @fields;

		my %item;
		for ( my $i=1; $i < @items; $i++ )
		{
			$item{$fields[$i]} = defined $items[$i] ? $items[$i] : '';
		}
		$hash{$items[0]} = \%item;
	}

	return %hash;
}

sub loadhashhash
{
	my ( $filename ) = @_;

	my @filedata = loadtextfile $filename;

	return loadhashhashfromdata @filedata;
}



sub savehashhash
{
	my ( $filename, %hash ) = @_;


	my @filedata;

	return if (keys %hash) == 0;

	my @fields = sort keys %{$hash{(keys %hash)[0]}};

	push @filedata, "KEY|".(join "|", @fields);

	foreach my $key ( keys %hash )
	{
		my $fileline = "$key";

		foreach my $field ( @fields )
		{
			my $val = $hash{$key}{$field};
			$val = '' unless defined $val;

			$fileline .= "|$val";
		}
		push @filedata, $fileline;
	}

	savetextfile $filename, @filedata;

}


sub fixarrayfields
{
	my ( $fieldsref, $arrayref ) = @_;

	foreach my $item ( @{$arrayref} )
	{
		# add any missing fields...
		foreach my $field ( keys %{$fieldsref} )
		{
			${$item}{$field} = ${$fieldsref}{$field} unless defined ${$item}{$field};
		}
		# .. and remove any not required...
		foreach my $field ( keys %{$item} )
		{
			delete ${$item}{$field} unless exists ${$fieldsref}{$field};
		}
	}

}


sub getiptype
{
	my ( $ip ) = @_;

	#TODO: add support for IPv6 here...

	return "invalid" unless $ip =~ m/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/;

	my ( $a, $b, $c, $d ) = ( $1, $2, $3, $4 );

	return "invalid" if ( $a<0 or $a>255 or $b<0 or $b>255 or $c<0 or $c>255 or $d<0 or $d>255 );

	# don't allow 0.*.*.* (this net), 127.*.*.* (loopback) or 224-255.*.*.* (multicast, class-e, broadcast)
	return "unusable" if ( $a==0 or $a==127 or $a>=224 );

	# mark 10.*.*.* (private a), 169.254.*.* (local link), 172.16-31.*.* (private b), 192.0.2.* (test net), 192.168.*.* (private c)
	return "private" if ( ($a==10) or ($a==169 and $b==254) or ($a==172 and ($b>=16 and $b<=31)) or ($a==192 and $b==0 and $c==2) or ($a==192 and $b==168) );

	return "public";
}

sub is_good_url
{
	my ( $url ) = @_;

	return $url =~ m{^http://(?:[a-z0-9-]{1,100}\.){1,10}[a-z]{1,50}(?::(?!80/)[1-9][0-9]{0,4})?(?=/)(?:/(?!\./|\.$|\.\./|\.\.$)[a-zA-Z0-9.~_-]{1,100}){0,50}/?$};
}

# HTTP request routines - for testing of URLs....

# v1: uses IO::Socket::INET
## used for the internals of http requests...
#use IO::Socket;		# for testing of sent URLs
#sub socket_send_and_get
#{
#	my ( $host, $port, @data ) = @_;
#
#
#	my $remote = IO::Socket::INET->new ( Proto => 'tcp', PeerAddr => $host, PeerPort => $port, Timeout => 15 );
#print "# failed: $! - $@\n" unless $remote;
#	return undef unless $remote;
#
#	$remote->autoflush(1);
#
#	print $remote @data;
#	local $/ = undef;
#
#	my $recv = <$remote>;
#	close $remote;
#
#	alarm 0;
#
#	return $recv;
#}

# v2: uses lower level functions
use Socket;
sub socket_send_and_get
{
	my ( $host, $port, @data ) = @_;

	my $addr = inet_aton $host;
	unless ( defined $addr )
	{
		$addr = gethostbyname $host;
	}
	return undef unless $addr;

# assume 6 if the call fails
	my $proto = getprotobyname "tcp" || 6;


	my $paddr = sockaddr_in $port, $addr;

	my $ret = socket SOCK, PF_INET, SOCK_STREAM, $proto;
	return undef unless $ret;

	$ret = connect SOCK, $paddr;
	return undef unless $ret;

#	SOCK->autoflush(1);
#	autoflush SOCK 1;
	select SOCK; $| = 1; select STDOUT;

	print SOCK @data or return undef;


	local $/ = undef;
	my $recv = <SOCK>;

	close SOCK;

	return $recv;
}


# sends a http request to the given url and returns all data (header and body) as a single string.
sub http_request
{
	my ( $url ) = @_;

	if ( $url =~ m{^http://([a-zA-Z0-9-.]+)(?::(\d{1,5}))?(.*)$} )
	{
		my $host = $1;
		my $port = $2;
		my $path = $3;

		$port = 80 unless defined $port;
		$path = '/' if $path eq '';

		if ( defined $config{proxyhost} and defined $config{proxyport} )
		{
			my $reply = socket_send_and_get $config{proxyhost}, $config{proxyport}, "GET $url HTTP/1.0\r\n", "Host: $host:$port\r\n", "User-agent: perlgcache/$cacheversion (via proxy)\r\n", "X-RequestingIP: $ENV{REMOTE_ADDR}\r\n", "\r\n";
			return $reply;
		}

		my $reply = socket_send_and_get $host, $port, "GET $path HTTP/1.0\r\n", "Host: $host:$port\r\n", "User-agent: perlgcache/$cacheversion\r\n", "X-RequestingIP: $ENV{REMOTE_ADDR}\r\n", "\r\n";
		return $reply;
	}
	return undef;
}

# does a http request for a text/* object, processes redirect as required
# splits the output into an array of lines (without line terminators) and returns an array of:
# ( $code, $redircount, @lines )
sub do_http_text_request
{
	my ( $url, $redircount ) = @_;

	$redircount = 0 unless defined $redircount;

	# to stop redirect loops...
	return ( -4, $redircount ) if $redircount >= 10;


	my $reply = http_request $url;

	return ( -1, $redircount ) unless defined $reply;

	# HTTP headers should use \r\n to seperate lines - but for robustness clients can accept any format
	# i'll add that here later maybe
	my ( $header, $body ) = split /\r\n\r\n/, $reply, 2;
	return ( -5, $redircount ) unless defined $header and defined $body;
	my @header = split /\r\n/, $header;

	my $statusline = shift @header;
	return ( -2, $redircount ) unless defined $statusline;

	return ( -3, $redircount ) unless ( $statusline =~ m{^HTTP/\d+\.\d+ +(\d\d\d) *(.*)$} );
	my ( $code, $message ) = ( $1, $2 );

#	if ( $code =~ m/^3\d\d$/ )
#	{
#		# we've got a redirect - find the Location: header and follow it...
#		foreach my $headerline ( @header )
#		{
#			if ( $headerline =~ m{^location: +(.*)$}i )
#			{
#				# right - location headers *should* be absolute, but sometimes they're not...
#				my $newurl = $1;
#
#				if ( $newurl =~ m{^http:} )
#				{
#					# add trailing slash if hostname-only url
#					$newurl .= "/" if $newurl =~ m{^http://[^/]*$};
#
#					# full path - no problem
#					return do_http_text_request ( $newurl, $redircount+1 );
#				}
#				elsif ( $newurl =~ m{^/} )
#				{
#					# server relative url - add current server and port
#					$url =~ m{^(http://.*?)/} or die;
#					$newurl = $1.$newurl;
#
#					return do_http_text_request ( $newurl, $redircount+1 );
#				}
#				else
#				{
#					# directory relative url - add current server and path
#					$url =~ m{^(http:.*/)} or die;
#					$newurl = $1.$newurl;
#
#					return do_http_text_request ( $newurl, $redircount+1 );
#				}
#			}
#		}
#
#		# if we get here, there was no Location header...
#	}

	if ( $code ne '200' )
	{
		# bad code - fail
		return ( $code, $redircount );
	}

	# right - we've got the data - now let's check the type...
	foreach my $headerline ( @header )
	{
		if ( $headerline =~ m/^content-type: +(.*$)/i )
		{
			my $type = $1;

			# error on non text/* content-types...
			return ( -6, $redircount ) unless ( $type =~ m{^text/.*$} );
		}

		# (if we don't find a content-type, just assume it's text)
	}

	# it's good - now we need to sort out the body lines....
	# fun, because they could be seperated with just '\n', '\r\n' or even '\r' (and '\n\r'?)
	my @lines;

	# (isn't perl great!!)
	@lines = split /\r\n|\n\r|\n|\r/, $body;

	return ( $code, $redircount, @lines );
}


# now, utility routines for a gwebcache...


my %hostsfields =
(
	ipport	=> '0.0.0.0:0',	# well we have to have something in there by default
	client	=> 'unknown',
	clientver => 'unknown',
	time	=> 0,
	useragent => 'unknown',
);

sub gethosts
{
	my ( $network ) = @_;

	my $file = "$config{prefix}-hosts".($network eq 'gnutella' ? "" : "-$network");

	my @hosts = loadarrayhash $file;

	fixarrayfields \%hostsfields, \@hosts;

	# TODO: remove old/bad entries

	return @hosts;
}

sub addhost
{
	my ( $network, $ipport, $client, $clientver ) = @_;

	my $file = "$config{prefix}-hosts".($network eq 'gnutella' ? "" : "-$network");

	my @hosts = loadarrayhash $file;

	fixarrayfields \%hostsfields, \@hosts;

	my $alreadyhave = 0;
	foreach my $loopipport ( @hosts )
	{
		if ( ${$loopipport}{ipport} eq $ipport )
		{
			$alreadyhave = 1;
		}
	}


	# just return if we already have it
	# NOTE: we should probably update it's timestamp, but it isn't really worth it
	return if $alreadyhave;

	# add entry to start of list
	unshift @hosts, { ipport => $ipport, client => $client, clientver => $clientver, time => $time };

	# remove extra hosts
	splice @hosts, $config{maxhost} if @hosts > $config{maxhost};

	# and max age
	while ( scalar @hosts and $hosts[scalar @hosts - 1]{time} < $time - $config{maxhostage}*60 )
	{
		pop @hosts;
	}

	savearrayhash $file, @hosts;
}



my %urlfields =
(
	url	=> 'http://localhost/ignore',
	time	=> 0,
	version => 'unknown',
	client	=> 'unknown',
	clientver => 'unknown',
);



sub geturls
{
	my ( $cachetype, $network ) = @_;

	my $file = "$config{prefix}-urls".($cachetype == 1 ? "" : "-$cachetype");

	$file .= "-$network" if defined $network;


	my @urls = loadarrayhash $file;

	fixarrayfields \%urlfields, \@urls;

#	# first, remove any URLs which are too old...
#	# NOTE: URLs are stored newest to oldest, so we can just repeatedly drop the last one
#	while ( @urls > 0 and $urls[@urls-1]{time} < $time - $config{maxurlage}*60 )
#	{
#		splice @urls, -1;	# remove last entry
#	}

	my @keepurls;

	foreach my $item ( @urls )
	{
		my $timeout = ${$item}{version} eq 'FAILED' ? $config{minurlcheck} : $config{maxurlage};

		push @keepurls, $item if ${$item}{time} >= $time - $timeout*60;
	}

	return @keepurls;
}

sub forked_addurl
{
	my ( $cachetype, $url, $network ) = @_;

	my $urlcachever = 'unknown';


	my $requrl = $url;
	if ( $cachetype == 1 )
	{
		$requrl .= "?client=TEST&version=pgc-$cacheversion&ping=1";
	}
	else
	{
		# sending a ping isn't defined in the current GWC2 specs - so send a
		# get as well to ensure we trigger the correct mode of a dual-version cache
		$requrl .= "?client=TESTpgc-$cacheversion&ping=1&get=1";
		$requrl .= "&net=$network" if defined $network;
	}

	my ( $code, undef, @lines ) = do_http_text_request $requrl;

	if ( $code ne '200' )
	{
		$urlcachever = 'FAILED';
	}
	else
	{
		if ( $cachetype == 1 )
		{
			# v1 test - at least one line, and the first line starts with PONG
			if ( @lines >= 1 and $lines[0] =~ m{^PONG\s*([a-zA-Z0-9. _/+-]{0,100})} )
			{
				$urlcachever = $1 if $1 ne '';	# ignore if blank
			}
			else
			{
				$urlcachever = 'FAILED';
			}
		}
		else
		{
			# v2 test - each line must be of the form '[a-zA-Z]|.*'

			$urlcachever = 'FAILED' if @lines == 0;

			foreach my $line ( @lines )
			{
				chomp $line;

				if ( $line =~ m{^[iI]\|[pP][oO][nN][gG]\|([a-zA-Z0-9. _/+-]{0,100})} )
				{
					$urlcachever = $1 if $1 ne '';
				}
				elsif ( $line =~ m/^i\|net-not-supported/i )
				{
					$urlcachever = 'FAILED';
					last;
				}
				elsif ( $line !~ m/^[a-zA-Z0-9]\|/ )
				{
					$urlcachever = 'FAILED';
					last;
				}
			}
		}
	}

	substr $urlcachever, 25, (length $urlcachever), "..." if length $urlcachever > 28;


	my $file = "$config{prefix}-urls".($cachetype == 1 ? "" : "-$cachetype");

	$file .= "-$network" if defined $network;

	my @urls = loadarrayhash $file;

	fixarrayfields \%urlfields, \@urls;

	foreach my $urlhash ( @urls )
	{
		if ( ${$urlhash}{url} eq $url )
		{
			${$urlhash}{version} = $urlcachever;
			${$urlhash}{time} = time;
		}
	}

	savearrayhash $file, @urls;

	exit;
}

sub addurl
{
	my ( $cachetype, $url, $network, $client, $clientver ) = @_;

	my $file = "$config{prefix}-urls".($cachetype == 1 ? "" : "-$cachetype");

	$file .= "-$network" if defined $network;

	my @loadurls = loadarrayhash $file;

	fixarrayfields \%urlfields, \@loadurls;

#	# first, remove any URLs which are too old...
#	# NOTE: URLs are stored newest to oldest, so we can just repeatedly drop the last one
#	while ( @urls > 1 and $urls[@urls-1]{time} < $time - $config{maxurlage}*60 )
#	{
#		splice @urls, -1;	# remove last entry
#	}

	my $alreadyhave = 0;
	my @urls;

	foreach my $item ( @loadurls )
	{
		my $timeout = ( ${$item}{version} eq 'FAILED' or ${$item}{url} eq $url ) ? $config{minurlcheck} : $config{maxurlage};

		if ( ${$item}{time} >= $time - $timeout*60 )
		{
			push @urls, $item;
			$alreadyhave = 1 if ${$item}{url} eq $url;
		}
	}



#	foreach my $loopurl ( @urls )
#	{
#		if ( ${$loopurl}{url} eq $url )
#		{
#			$alreadyhave = 1;
#		}
#	}

	# just return if we already have it
	# NOTE: we should really update it's timestamp, but it isn't really worth it
	return if $alreadyhave;

	my $urlcachever = 'unknown';
	if ( $config{checkurls} )
	{
		$urlcachever = 'CHECKING';
	}

	# add entry
	unshift @urls, { url => $url, time => $time, version => $urlcachever, client => $client, clientver => $clientver };

	# remove extra urls
	splice @urls, $config{maxurlstore} if @urls > $config{maxurlstore};

	savearrayhash $file, @urls;

	if ( $config{checkurls} )
	{
		my $pid = fork();
		if ( defined $pid and $pid == 0 )
		{
			forked_addurl $cachetype, $url, $network;
		}

	}
}

sub pickurls
{
	my ( $maxurlret, @urls ) = @_;

	my @newurls;
	while ( @urls >= 1 and @newurls < $maxurlret )
	{
		my $rand = int ( rand @urls );

		my $item = splice @urls, $rand, 1;	# pick an item from the list and remove it

		next if ${$item}{version} eq 'FAILED' or ${$item}{version} eq 'CHECKING';	# ignore failed URLs, or those currently being checked

		push @newurls, $item;
	}

	return @newurls;
}


sub getnetworks
{
	my %networks = ();

	# get the networks from the hosts files...
	foreach my $file ( <$config{prefix}-hosts*> )
	{
		# ignore temp files left behind
		next if $file =~ m/\.tmp\.\d+~$/;

# nasty hack to allow for no -gnutella suffix special case
		$file = "$config{prefix}-hosts-gnutella" if $file eq "$config{prefix}-hosts";


		$networks{substr $file, length "$config{prefix}-hosts-"} = 1;
	}

	# .. and the url files - for the gwc2 network only
	foreach my $file ( <$config{prefix}-urls-2-*> )
	{
		# ignore temp files left behind
		next if $file =~ m/\.tmp\.\d+~$/;

# nasty hack not needed - we always append the network name for gwc2 url databases
#		$file = "$config{prefix}-urls-gnutella" if $file eq "$config{prefix}-urls";

		$networks{substr $file, length "$config{prefix}-urls-2-"} = 1;
	}

	return sort keys %networks;
}


# NOTE: NOT to be used inside the 'statlog' function - this downloads the stats for ALL hosts
# if a list of stat urls has been defined
sub loadallstats
{
	unless ( scalar @{$config{statfileurls}} )
	{
		# a single host - just load the stat file
		return loadhashhash "$config{prefix}-stats";
	}

	# multiple hosts - download and combine the stats

	my %totalstats;
	foreach my $staturl ( @{$config{statfileurls}} )
	{
		my ( $code, $redircount, @lines ) = do_http_text_request $staturl;

		# if any url fails, return an error
		return () unless $code == 200;

		my %stats = loadhashhashfromdata @lines;
		foreach my $date ( keys %stats )
		{
			foreach my $item ( keys %{$stats{$date}} )
			{
				$totalstats{$date}{$item} = 0 unless defined $totalstats{$date}{$item};

				$totalstats{$date}{$item} += $stats{$date}{$item};
			}
		}

	}

	return %totalstats;
}

sub statlog
{
	return unless $config{enablestats};

	# NOTE: loadhashhash REQUIRES that all of the hashes have the same members, or data WILL NOT be saved correctly,
	# so use this to check...
# TODO?: once the table for stat colours on the graph web page is done, build this from that to save
# repeating information?
	my %stattypes =
	(
		update => 1,
		hostfile => 1,
		urlfile => 1,
		statfile => 1,
		ping => 1,

		badrequest => 1,
		block_banned => 1,
		block_requestrate => 1,
		block_anon => 1,
		update_block_badport => 1,
		update_block_badip => 1,
		update_block_ratelimit => 1,

		block_badpath => 1,

	# v2 actions are any combination of get, ping and update - always sorted
		v2_get => 1,
		v2_ping => 1,
		v2_update => 1,
		v2_get_ping => 1,
		v2_get_update => 1,
		v2_ping_update => 1,
		v2_get_ping_update => 1,

		v2_block_anon => 1,
		v2_update_block_badport => 1,
		v2_update_block_badip => 1,
		v2_update_block_badurl => 1,
		v2_update_block_ratelimit => 1,
	);

	my ( $day, $action ) = @_;

	# make sure this stat type exists...
	return unless defined $stattypes{$action};

	my %stats = loadhashhash "$config{prefix}-stats";

	# add in this stat item...
	$stats{$day}{$action} = 0 unless defined $stats{$day}{$action};
	$stats{$day}{$action}++;

	# and also into the totals...
	$stats{'total'}{$action} = 0 unless defined $stats{$day}{$action};
	$stats{'total'}{$action}++;

	foreach my $statday ( keys %stats )
	{
		# now remove old stat data...
		if ( $statday ne 'total' and $statday < $day - 28 )
		{
			delete $stats{$statday};
			next;
		}

		# remove bogus stats...
		foreach my $stattype ( keys %{$stats{$statday}} )
		{
			delete $stats{$statday}{$stattype} unless defined $stattypes{$stattype};
		}
		# and add unset stats...
		foreach my $stattype ( keys %stattypes )
		{
			$stats{$statday}{$stattype} = 0 unless defined $stats{$statday}{$stattype};
		}
	}

	savehashhash "$config{prefix}-stats", %stats;
}

# returns an array of ( $client, $version ) from a decoded cgi parameter hash
# allows for both v1 client=XXX&version=a.b.c and v2 client=XXXXa.b.c style versions...
sub getclientandversion
{
	my ( %p ) = @_;

	# the V2 specs say client and version should be combined into a single parameter - work around that here...
	if ( defined $p{client} and !defined $p{version} and $p{client} =~ m/^([A-Za-z0-9]{4})(.+)$/ )
	{
		$p{client} = $1;
		$p{version} = $2;
	}

	my $client;
	if ( !defined $p{client} )
	{
		$client = "unknown";
	}
	elsif ( $p{client} =~ m/^[a-zA-Z0-9.+-]{1,20}$/ )
	{
		$client = $p{client};
	}
	else
	{
		$client = "unknown_bad";
	}

	my $version;
	if ( !defined $p{version} )
	{
		$version = "unknown";
	}
	elsif ( $p{version} =~ m{^[a-zA-Z0-9/.+ @\-]{1,40}$} )
	{
		$version = $p{version};
	}
	else
	{
		$version = "unknown_bad";
	}

	return ( $client, $version );
}


###### main code ######


# some subs, to break up the code a little...

sub formatnumber
{
	my ( $num ) = @_;
	$num =~ s/(\d)(?=(\d\d\d)+$)/$1,/g;
	return $num;
}

sub isotime
{
	my ( $time ) = @_;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime $time;

	return sprintf "%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec;
}
sub isodate
{
	my ( $time ) = @_;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime $time;

	my $datestr = sprintf "%04d-%02d-%02d", $year+1900, $mon+1, $mday;
	return wantarray ? ($datestr,$wday) : $datestr;
}

sub dohtmlpage
{
	my ( %param ) = @_;

	$| = 1;

	my $browse = "index";
	$browse = $param{browse} if defined $param{browse} and $browse =~ m/^[a-zA-Z0-9]{1,100}$/;

	print "Content-type: text/html\n";
	print "\n";

print <<END;
<?xml version="1.0" encoding="us-ascii"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
<head><title>perlgcache $cacheversion</title>
<link rel="stylesheet" href="$config{styleurl}" />
</head>

<body>
<h1>perlgcache $cacheversion</h1>

<p>[
<a href="?browse=index">home</a> |
<a href="?browse=hosts">hosts</a> |
<a href="?browse=urlsgood">urls</a> |
<a href="?browse=limited">limited IPs</a> |
<a href="?browse=stats">stats (numbers)</a> |
<a href="?browse=statgraph">stats (graph)</a>
]</p>
END

	if ( open INFO, "cacheinfo.txt" )
	{
		print <INFO>;
		close INFO;
	}


	# right - it's a good idea to test the data directory is writable here - let's create then delete a file
	my $ok = 0;
	my $tmpfile = "$config{prefix}-writetest.$$.tmp~";
	if ( open OUT, "> $tmpfile" )
	{
		close OUT;

		unlink $tmpfile;

		$ok = 1;
	}

	if ( ! $ok )
	{
		print "<hr />\n";
		print "<h2>Datafile write failure</h2>\n";
		print "<p><b>This cache is not correctly configured!</b></p>\n";
		print "<p>You need to configure \$config{prefix} to point to a writable directory.</p>\n";
		print "<hr />\n";
	}

	if ( $browse eq 'stats' )
	{
	    if ( $config{enablestats} )
	    {
#		my %stats = loadhashhash "$config{prefix}-stats";
		my %stats = loadallstats;

		print "<table><caption>Cache stats</caption>\n";
		print "<tr><td></td>\n";
		foreach my $stattype ( sort keys %{$stats{'total'}} )
		{
			next if $stats{'total'}{$stattype} == 0;

			my $statdisp = $stattype;
			$statdisp =~ s/_/ /g;

			print "<th>$statdisp</th>";
		}
		print "<td></td><th>Total</th>";
		print "</tr>\n";

		foreach my $statday ( sort keys %stats )
		{
			print "<tr><td></td></tr>\n" if $statday eq 'total';

			my $daytext = "Total";
			my $dow = "x";
			( $daytext, $dow ) = isodate ($statday*60*60*24) unless $statday eq 'total';
			#$daytext =~ s/00:00:00 //;
			#$daytext =~ s/ /&nbsp;/g;

			print "<tr class=\"day$dow\"><th class=\"date\">$daytext</th>";

			my $total = 0;
			foreach my $stattype ( sort keys %{$stats{'total'}} )
			{
				next if $stats{'total'}{$stattype} == 0;

				my $d = formatnumber $stats{$statday}{$stattype};
				print "<td class=\"num\">$d</td>";

				$total += $stats{$statday}{$stattype};
			}
			$total = formatnumber $total;
			print "<td></td><td class=\"num\">$total</td>";
			print "</tr>\n";
		}
		print "</table>\n";

		if ( @{$config{statfileurls}} )
		{
			print "<p>Combined stats from all hosts for this cache URL</p>\n";
		}
	    }

	}
	elsif ( $browse eq 'statgraph' )
	{
	    if ( $config{enablestats} )
	    {
#		my %stats = loadhashhash "$config{prefix}-stats";
		my %stats = loadallstats;


		my $totalwidth = 600;		# max width of graphs on screen


		my $daytotalmax = 100;		# start above zero as we divide by this later
		foreach my $statday ( sort keys %stats )
		{
			next if $statday eq 'total';
			my $daytotal = 0;
			foreach my $stattype ( sort keys %{$stats{'total'}} )
			{
				$daytotal += $stats{$statday}{$stattype};
			}
			$daytotalmax = $daytotal if $daytotal > $daytotalmax;
		}

		my @typeorder = sort { $stats{'total'}{$b} <=> $stats{'total'}{$a} } keys %{$stats{'total'}};


		print "<table><caption>Cache stats</caption>\n";

		print "<tr><th>Date</th><th>Requests</th><th>Total</th></tr>\n";

		foreach my $statday ( sort keys %stats )
		{
			next if $statday eq 'total';

			my ( $daytext, $dow ) = isodate ($statday*60*60*24);
			#$daytext =~ s/00:00:00 //;
			#$daytext =~ s/ /&nbsp;/g;

			print "<tr class=\"day$dow\"><th class=\"date\">$daytext</th>";

			print "<td>";

			print "<table class=\"graph\"><tr>";

			my $daytotal = 0;
			foreach my $stattype ( @typeorder )
			{
				# calc the pixel width for this stat val

				my $val = $stats{$statday}{$stattype};

				$daytotal += $val;

				my $width = int ( $val / $daytotalmax * $totalwidth + 0.5 );

				next if $width == 0;

				$val = formatnumber $val;

				my $numpixwidth = 3 + 5 * length $val;
				$val = "&nbsp;" if $numpixwidth > $width;

				print "<td width=\"$width\" class=\"$stattype\">$val</td>";
			}
			print "</tr></table>";

			$daytotal = formatnumber $daytotal;
			print "</td><td class=\"num\">$daytotal</td></tr>\n";
		}

		print "</table>\n";


		print "<table><caption>Total requests</caption>\n";

		print "<tr><th>Action</th><th></th><th>Total requests</th></tr>\n";

		my $total = 0;
		foreach my $stattype ( @typeorder )
		{
			my $val = $stats{'total'}{$stattype};
			$total += $val;
			next if $val == 0;

			print "<tr><td>$stattype</td>";

			print "<td>";
			print "<table class=\"graph\"><tr><td class=\"$stattype\" width=\"30\">x</td></tr></table>";
			print "</td>";

			$val = formatnumber $val;
			print "<td class=\"num\">$val</td>";

			print "</tr>\n";
		}

		$total = formatnumber $total;
		print "<tr><th colspan=\"2\">Total requests</th><th>$total</th></tr>\n";

		print "</table>\n";


		if ( @{$config{statfileurls}} )
		{
			print "<p>Combined stats from all hosts for this cache URL</p>\n";
		}

	    }

	}
	elsif ( $browse eq 'hosts' )
	{
		foreach my $network ( getnetworks )
		{
			my @hosts = gethosts $network;

			print "<table><caption>Host cache - net=$network</caption>\n";
			print "<tr><th>IP:Port</th><th colspan=\"2\">Client</th><th>Time</th></tr>\n";
			foreach my $item ( @hosts )
			{
				next if ${$item}{time} < $time - $config{maxhostage}*60;

				print "<tr><td>${$item}{ipport}</td><td>${$item}{client}</td><td>${$item}{clientver}</td><td>".(isotime ${$item}{time})."</td></tr>\n";
			}
			print "<tr><td colspan=\"4\">no hosts</td></tr>\n" if scalar @hosts == 0;
			print "<tr><td colspan=\"4\">Maximum of $config{maxhost} hosts stored/returned.<br />\n";
			print "Hosts are no older than $config{maxhostage} minutes</td></tr>\n";
			print "</table>\n";
		}
	}
	elsif ( $browse eq 'urls' or $browse eq 'urlsgood' )
	{
		if ( $config{enablev1requests} )
		{
			my @urls = geturls 1;

			print "<table><caption>URL cache - GWebcache</caption>\n";
			print "<tr><th>URL</th><th>Version</th><th>Time</th><th colspan=\"2\">Client</th></tr>\n";
			my $failedcount = 0;
			foreach my $item ( @urls )
			{
				if ( ${$item}{version} eq 'FAILED' and $browse eq 'urlsgood' )
				{
					$failedcount++;
					next;
				}

				my $urlshort = ${$item}{url};
				substr $urlshort, 55, (length $urlshort), "..." if length $urlshort > 58;

				my $classbit = "";
				$classbit = " class=\"failed\"" if ${$item}{version} eq 'FAILED';
				$classbit = " class=\"checking\"" if ${$item}{version} eq 'CHECKING';
				print "<tr$classbit><td><a href=\"${$item}{url}\">$urlshort</a></td><td>${$item}{version}</td><td>".(isotime ${$item}{time})."</td><td>${$item}{client}</td><td>${$item}{clientver}</td></tr>\n";
			}
			print "<tr><td colspan=\"5\">$failedcount bad URLs known</td></tr>\n" if $failedcount;
			print "<tr><td colspan=\"5\">no urls</td></tr>\n" if scalar @urls == 0;
			print "</table>\n";
		}

		if ( $config{enablev2requests} )
		{
			foreach my $network ( getnetworks )
			{
				my @urls = geturls 2, $network;		##loadarrayhash "$config{prefix}-urls";

				print "<table><caption>URL cache - GWebcache2 - net=$network</caption>\n";
				print "<tr><th>URL</th><th>Version</th><th>Time</th><th colspan=\"2\">Client</th></tr>\n";
				my $failedcount = 0;
				foreach my $item ( @urls )
				{
					if ( ${$item}{version} eq 'FAILED' and $browse eq 'urlsgood' )
					{
						$failedcount++;
						next;
					}

					my $urlshort = ${$item}{url};
					substr $urlshort, 55, (length $urlshort), "..." if length $urlshort > 58;

					my $classbit = "";
					$classbit = " class=\"failed\"" if ${$item}{version} eq 'FAILED';
					$classbit = " class=\"checking\"" if ${$item}{version} eq 'CHECKING';
					print "<tr$classbit><td><a href=\"${$item}{url}\">$urlshort</a></td><td>${$item}{version}</td><td>".(isotime ${$item}{time})."</td><td>${$item}{client}</td><td>${$item}{clientver}</td></tr>\n";
				}
				print "<tr><td colspan=\"5\">$failedcount bad URLs known</td></tr>\n" if $failedcount;
				print "<tr><td colspan=\"5\">no urls</td></tr>\n" if scalar @urls == 0;
				print "</table>\n";
			}
		}

		print "<p><a href=\"?browse=urls\">all URLs</a> <a href=\"?browse=urlsgood\">good URLs</a></p>\n" if $config{checkurls};
	}
	elsif ( $browse eq 'limited' )
	{
		my %updateip = loadhashhash "$config{prefix}-updateip";

		print "<table><caption>Recent updates</caption>\n";
		print "<tr><th>Client IP</th><th>Update at</th></tr>\n";
		foreach my $ip ( sort { $updateip{$b}{time} <=> $updateip{$a}{time} } keys %updateip )
		{
			next if $updateip{$ip}{time} < $time - $config{updatelimit}*60;

			print "<tr><td>$ip</td><td>".(isotime $updateip{$ip}{time})."</td></tr>\n";
		}
		print "<tr><td colspan=\"2\">No updates for another $config{updatelimit} minutes</td></tr>\n";
		print "<tr><td colspan=\"2\">no blocked IPs</td></tr>\n" if scalar keys %updateip == 0;
		print "</table>\n";

		if ( $config{requestlimitcount} and $config{requestlimittime} )
		{
			# merge all request-* files into a single hash for display...
			my %requestip;
			foreach my $file ( 0 .. 255 )
			{
				my %requestfile = loadhashhash "$config{prefix}-requestip-$file";

				foreach my $key ( keys %requestfile )
				{
					$requestip{"$file.$key"} = $requestfile{$key};
				}
			}
#			my %requestip = loadhashhash "$config{prefix}-requestip";

			foreach my $ip ( keys %requestip )
			{
				if ( $requestip{$ip}{time} < $time - $config{requestlimittime}*60 )
				{
					delete $requestip{$ip};
					next;
				}
			}




			print "<table><caption>Recent requests</caption>\n";
			print "<tr><th>Client IP</th><th>count</th><th>time</th><th colspan=\"2\">client</th></tr>\n";
			my %lowcount = ();
			foreach my $ip ( sort { $requestip{$b}{count} <=> $requestip{$a}{count} } keys %requestip )
			{
				next if $requestip{$ip}{time} < $time - $config{requestlimittime}*60;

				if ( $requestip{$ip}{count} <= $config{requestlimitcount} )
				{
					$lowcount{$requestip{$ip}{count}}++;
				}
				else
				{
					print "<tr><td>$ip</td><td class=\"num\">$requestip{$ip}{count}</td><td>".(isotime $requestip{$ip}{time})."</td><td>$requestip{$ip}{client}</td><td>$requestip{$ip}{clientver}</td></tr>\n";
				}
			}
			foreach my $count ( sort { $b <=> $a } keys %lowcount )
			{
				print "<tr><td colspan=\"5\">$lowcount{$count} IP(s) have made $count request(s) in the last $config{requestlimittime} minutes</td></tr>\n";
			}
			print "<tr><td colspan=\"5\">No more than $config{requestlimitcount} requests every $config{requestlimittime} minutes</td></tr>\n";
			print "</table>\n";
		}
	}
	else
	{
print <<END;
<p>Welcome to this <a href="http://www.gnutella.com/">gnutella</a>
<a href="http://www.gnucleus.com/gwebcache/">web cache</a>.</p>


<hr />
<p>
<a href="http://www.jonatkins.com/perlgcache/">perlgcache</a>
by Jon Atkins

</p>

<iframe src="http://www.jonatkins.com/perlgcache/version/$cacheversion" width="500" height="100" frameborder="0">
Version check available <a href="http://www.jonatkins.com/perlgcache/version/$cacheversion">here</a>.
</iframe>

END
	}


	print "<p>Current time: ".(isotime $time)."</p>\n";


print <<END;

<hr />

<p>
<a href="http://validator.w3.org/check?uri=referer"><img
      style="border:0"
      src="http://www.w3.org/Icons/valid-xhtml10"
      alt="Valid XHTML 1.0!" height="31" width="88" /></a>

<a href="http://jigsaw.w3.org/css-validator/">
 <img style="border:0;width:88px;height:31px"
      src="http://jigsaw.w3.org/css-validator/images/vcss" 
      alt="Valid CSS!" /></a>
</p>

</body>
</html>
END

}




sub dov1request
{
	my ( %param ) = @_;


	my ( $client, $version ) = getclientandversion %param;

	my $network = 'gnutella';	## NOTE: default net name - supplying no net= param is the same as sending this value
##	$network = lc $1 if defined $param{net} and $param{net} =~ m/^([a-zA-Z0-9._-]{1,20})$/;
##	# (NOTE: above restrictions are the same as I use for the client string - no particular reason for this)


	if ( $config{blockv1anon} )
	{
#		unless ( defined $param{client} and defined $param{version} )
		if ( $client =~ m/^unknown/ )	# just check for client
		{
			statlog $day, "block_anon";
			error "anonymous clients not allowed here";
		}
	}



	# bodge: works around differences with an older version of the specs
	$param{url} = $param{url1} if !defined $param{url} and defined $param{url1};
	$param{ip} = $param{ip1} if !defined $param{ip} and defined $param{ip1};

	if ( defined $param{url} or defined $param{ip} )
	{
		# limit update rate by remembering the cache...
		my %updateip = loadhashhash "$config{prefix}-updateip";
		foreach my $ip ( keys %updateip )
		{
			if ( $updateip{$ip}{time} < $time - $config{updatelimit}*60 )
			{
				delete $updateip{$ip};
				next;
			}

			if ( $ENV{REMOTE_ADDR} eq $ip )
			{
				statlog $day, "update_block_ratelimit";

				print "OK\n";
				print "WARNING: update denied: $ENV{REMOTE_ADDR} has sent updates in the last $config{updatelimit} minutes\n";
				exit;
			}
		}
		$updateip{$ENV{REMOTE_ADDR}}{time} = $time;

		savehashhash "$config{prefix}-updateip", %updateip;


		print "OK\n";

		if ( defined $param{ip} )
		{
			my $ipport = $param{ip};

			if ( $ipport =~ m{^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})$} )
			{
				my ( $ip, $port ) = ( $1, $2 );

				if ( $port < 1 or $port > 65535 )
				{
					statlog $day, "update_block_badport";
					error "port $port out of range";
				}
				my $iptype = getiptype $ip;

				# TODO: allow 'private' addresses in certain situations??
				unless ( $iptype eq 'public' )
				{
					statlog $day, "update_block_badip";
					error "ip $ip invalid ($iptype)";
				}

				addhost "gnutella", $ipport, $client, $version;

			}
			else
			{
				print "WARNING: invalid format ip parameter\n";
			}
		}

		if ( defined $param{url} )
		{
			my $url = $param{url};

			# bodge to change %7e to ~
			$url =~ s{%7[eE]}{~}g;

			if ( is_good_url $url )
			{
				addurl 1, $url, undef, $client, $version;		# add url to the gwebcache v1 list...
			}
			else
			{
				print "WARNING: invalid format/character in url\n";
			}
		}

		statlog $day, "update";
	}
	elsif ( defined $param{hostfile} )
	{

		my @hosts = gethosts $network;		##loadarrayhash "$config{prefix}-hosts";

#		@hosts = pickhosts $client, @hosts;

		my $testclient = $client eq 'unknown' ? 'not set' : $client;

		my $outcount = 0;

		foreach my $item ( @hosts )
		{
			print "${$item}{ipport}\n";
		}

		# hack: the v1 cache specs allows caches to return no lines, but some clients
		# assume this is an error. let's always send something, even if it's useless
		# NOTE: this only happens when the cache has no hosts
		if ( @hosts == 0 )
		{
			print "0.0.0.0:0\n";	# an invalid IP/port but should match the format clients are expecting
		}

		statlog $day, "hostfile";
	}
	elsif ( defined $param{urlfile} )
	{
		my @urls = geturls 1;	# load gwebcache v1 list

		@urls = pickurls $config{maxv1urlret}, @urls;

		foreach my $item ( @urls )
		{
			print "${$item}{url}\n";
		}

		# hack: the v1 cache specs allows caches to return no lines, but some clients
		# assume this is an error. let's always send something, even if it's useless
		# NOTE: this only happens when the cache has no valid URLs
		if ( @urls == 0 )
		{
			print "http://0.0.0.0:0/\n";	# an invalid IP/port but should match the format clients are expecting
		}

		statlog $day, "urlfile";
	}
	elsif ( defined $param{ping} )
	{
		print "PONG perlgcache/$cacheversion\n";

		statlog $day, "ping";
	}
	elsif ( defined $param{statfile} )
	{
		if ( $config{enablestats} )
		{
#			my %stats = loadhashhash "$config{prefix}-stats";
			my %stats = loadallstats;


			my ( $totalreq, $dayreq, $dayupd ) = ( 0, 0, 0 );

			my $statday = $day - 1;

			# type1: count all requests for the requests figure...
			foreach my $statitem ( keys %{$stats{'total'}} )
##			# type2: count just hostfile and urlfile requests
##			foreach my $statitem ( 'hostfile', 'urlfile' )
			{
				$dayreq += $stats{$statday}{$statitem} if defined $stats{$statday};
				$totalreq += $stats{'total'}{$statitem};
			}

			$dayupd += $stats{$statday}{'update'} if defined $stats{$statday};
			$dayupd += $stats{$statday}{'v2_update'} if defined $stats{$statday};

			print $totalreq."\n";
			# NOTE: the statfile=1 specs ask for hour stats, but we only store day stats... fake them...
			print int($dayreq/24)."\n";
			print int($dayupd/24)."\n";

		}
		else
		{
			print "NOTE: statfile not supported\n";
		}

		statlog $day, "statfile";
	}
	else
	{
		statlog $day, "badcommand";
		error "unknown command";
	}

}



sub dov2request
{
	my ( %param ) = @_;

	my ( $client, $version ) = getclientandversion %param;

	my $network = 'gnutella';	## NOTE: default net name - supplying no net= param is the same as sending this value
	$network = lc $1 if defined $param{net} and $param{net} =~ m/^([a-zA-Z0-9._-]{1,20})$/;
	# (NOTE: above restrictions are the same as I use for the client string - no particular reason for this)

	if ( 1 )	# always enforce client parameter for v2 requests
	{
		if ( $client =~ m/^unknown/ )	# just check for client
		{
			statlog $day, "v2_block_anon";

			error "V2 Anonymous clients not allowed here";
		}
	}


	# OK - the v2 specs say that a cache must always return something - returning nothing is an error
	# they also specify a response to a ping but not the query to make!
	# there's also the fact that unwanted info can always be returned

	# so... - let's always output our ping line...
	print "i|pong|perlgcache/$cacheversion\n";


	my @actions;

	if ( defined $param{ping} )
	{
		push @actions, "ping";
	}

	if ( defined $param{update} )
	{
		# limit update rate by remembering the cache...
		my %updateip = loadhashhash "$config{prefix}-updateip";
		foreach my $ip ( keys %updateip )
		{
			if ( $updateip{$ip}{time} < $time - $config{updatelimit}*60 )
			{
				delete $updateip{$ip};
				next;
			}

			if ( $ENV{REMOTE_ADDR} eq $ip )
			{
				statlog $day, "update_block_ratelimit";

				print "i|update|WARNING|You came back too soon\n";
				exit;
			}
		}
		$updateip{$ENV{REMOTE_ADDR}}{time} = $time;

		savehashhash "$config{prefix}-updateip", %updateip;



		if ( defined $param{ip} )
		{
			my $ipport = $param{ip};

			if ( $ipport =~ m{^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})$} )
			{
				my ( $ip, $port ) = ( $1, $2 );

				if ( $port < 1 or $port > 65535 )
				{
					statlog $day, "v2_update_block_badport";

					print "i|update|WARNING|Rejected IP\n";
					print "d|update|ip|port $port out of range\n";
					return;
				}

				my $iptype = getiptype $ip;

				# TODO: allow 'private' addresses in certain situations??
				unless ( $iptype eq 'public' )
				{
					statlog $day, "v2_update_block_badip";

					print "i|update|WARNING|Rejected IP\n";
					print "d|update|ip|ip $ip isn't public - $iptype\n";
				}

				addhost $network, $ipport, $client, $version;

				print "i|update|OK\n";
				print "d|update|ip|ip=$ip:$port net=$network accepted\n";

			}
			

		}


		if ( defined $param{url} )
		{
			my $url = $param{url};

			# bodge to change %7e to ~
			$url =~ s{%7[eE]}{~}g;

			if ( is_good_url $url )
			{
				addurl 2, $url, $network, $client, $version;		# add url to the gwebcache v2 list...
				print "i|update|OK\n";
				print "d|update|url|url=$url added to gwc2 list\n";

			}
			else
			{
				statlog $day, "v2_update_block_badurl";

				print "i|update|WARNING|Rejected URL\n";

				return;
			}
		}

		push @actions, "update";
	}


	if ( $param{get} )
	{
		# first, do the hosts list...
		my @hosts = gethosts $network;

#		@hosts = pickhosts $client, @hosts;

		foreach my $item ( @hosts )
		{
			my $age = $time - ${$item}{time};
			$age = 0 if $age < 0;
			print "h|${$item}{ipport}|$age|${$item}{client}\n";
		}


		# now do the urls...

		my @urls = geturls 2, $network;

		@urls = pickurls $config{maxv2urlret}, @urls;

		foreach my $item ( @urls )
		{
			my $age = $time - ${$item}{time};
			$age = 0 if $age < 0;
			print "u|${$item}{url}|$age\n";
		}

		push @actions, "get";
	}

	if ( defined $param{support} )
	{
		my @networks = getnetworks;

		foreach my $network ( @networks )
		{
			print "i|SUPPORT|$network\n";
		}
		print "i|SUPPORT|*\n";	# show we support any unknown network
	}

	statlog $day, "v2_".(join "_", sort @actions);

}




sub dorequest
{
	# globals: read time once - to avoid possible race conditions
	$time = time;
	$day = int ( $time / (24*60*60) );


	unless ( defined $ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} eq 'GET' )
	{
		print "Content-type: text/plain\n";
		print "Cache-control: no-cache\n";
		print "Connection: close\n";
		print "\n";
		error "only GET requests supported" 
	}



	my %param = paramdecode $ENV{QUERY_STRING};



	if ( scalar %param eq "0" or defined $param{browse} )
	{
		dohtmlpage %param;
		exit;
	}



	print "Content-type: text/plain\n";
	print "Cache-control: no-cache\n";
	print "Connection: close\n";
	print "\n";


	# to avoid multiple paths to this script (eg .../perlgcache.cgi and .../perlgcache.cgi/)
	if ( defined $ENV{PATH_INFO} and $ENV{PATH_INFO} ne '' )
	{
		statlog $day, "block_badpath";
		error "invalid path to script (PATH_INFO = $ENV{PATH_INFO})";
	}


	# block http/0.9 requests
	# (there's one anonymous client which just sends "GET http://host/path/script\r\n")
	if ( 1 )
	{
		if ( defined $ENV{SERVER_PROTOCOL} and $ENV{SERVER_PROTOCOL} eq 'HTTP/0.9' )
		{
			statlog $day, "block_http0.9";
			error "HTTP/0.9 requests not supported. read RFC2616 or at least RFC1945";
		}
	}

	# block banned clients
	if ( defined $config{bannedclients} )
	{
		my ( $client, $version ) = getclientandversion %param;
		if ( defined ${$config{bannedclients}}{$client} )
		{
			if ( $version =~ m/${$config{bannedclients}}{$client}/ )
			{
				statlog $day, "block_banned";
				error "this client (version) is banned";
			}
		}
	}

	# if request rate is limited, check...
	if ( $config{requestlimitcount} and $config{requestlimittime} )
	{
		my ( $file, $key ) = ( $ENV{REMOTE_ADDR} =~ m/^(\d+)\.(\d+\.\d+\.\d+)$/ );

		my %requestip = loadhashhash "$config{prefix}-requestip-$file";

		# first, remove old entries...
		if ( 1 )
		{
			foreach my $ip ( keys %requestip )
			{
				# these two fields didn't exist before 0.7.12 - add them if missing..
				$requestip{$ip}{client} = 'unknown' unless defined $requestip{$ip}{client};
				$requestip{$ip}{clientver} = 'unknown' unless defined $requestip{$ip}{clientver};

				if ( $requestip{$ip}{time} < $time - $config{requestlimittime}*60 )
				{
					delete $requestip{$ip};
					next;
				}
			}
		}

		# add a blank entry if required...
		unless ( defined $requestip{$key} )
		{
			$requestip{$key}{count} = 0;
			$requestip{$key}{time} = $time;
			$requestip{$key}{client} = 'none';
			$requestip{$key}{clientver} = 'none';
		}
		# increment the counter...
		$requestip{$key}{count}++;

		# and store the client/version...
		my ( $client, $version ) = getclientandversion %param;

		$requestip{$key}{client} = $client;
		$requestip{$key}{clientver} = $version;


		# and save it back...
		savehashhash "$config{prefix}-requestip-$file", %requestip;

		if ( $requestip{$key}{count} > $config{requestlimitcount} )
		{
			statlog $day, "block_requestrate";

			# start adding delays to high request rate clients. the theory
			# is that even abusive clients still wait for a request to complete
			# before making another request
			sleep 5 if $requestip{$key}{count} > $config{requestlimitcount}*2;
			sleep 10 if $requestip{$key}{count} > $config{requestlimitcount}*3;
			sleep 15 if $requestip{$key}{count} > $config{requestlimitcount}*5;
			# if over 10 times the standard limit, then exit without a message (saves a few bytes)
			exit if $requestip{$key}{count} > $config{requestlimitcount}*10;

			error "request rate of $config{requestlimitcount} requests every $config{requestlimittime} minutes exceeded for $ENV{REMOTE_ADDR}\n";
		}

	}



	if ( $config{enablev2requests} and
		(
		 !$config{enablev1requests} or
		 defined $param{get} or
		 defined $param{update} or
		 defined $param{net} or
		 (defined $param{ping} and $param{ping} eq '2')
		)
	   )
	{
		dov2request %param;
	}
	else
	{
		dov1request %param;
	}



}


# regular CGI
dorequest;


# NOTE: not working yet - there's several cases where the above code does an 'exit' instead
# of a 'return', so it won't work well...
##FCGI### FastCGI
##FCGI##use FCGI;
##FCGI##my $fcgi = FCGI::Request();
##FCGI##while ( $fcgi->Accept() >= 0 )
##FCGI##{
##FCGI##	dorequest;
##FCGI##	$fcgi->Finish();
##FCGI##	# exit if script file changes...
##FCGI##	last if -M $ENV{SCRIPT_FILENAME} < 0;
##FCGI##}
