#! /usr/local/bin/perl -w

print "1..1\n";

local $@;
eval { require Crypt::Rijndael_PP };
print $@ ? "not ok 1\n" : "ok 1\n";

