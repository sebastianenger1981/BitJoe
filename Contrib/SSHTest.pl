#!/usr/bin/perl

use Net::SCP::Expect;


my $scpe = Net::SCP::Expect->new(host=>'85.214.59.105', user=>'root', password=>'PQdfqZHr');
$scpe->auto_yes(1);
$scpe->scp('/root/.mutella/MutellaProxy_V0.1.9.pl','root@85.214.59.105:/root/');
