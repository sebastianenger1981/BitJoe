#!/usr/bin/perl

use LWP::Simple;
use strict;

my $CACHE = 'http://www.alpha64.info/Cache/cachelist.txt';
my $doc = get($CACHE);
print $doc; exit;
