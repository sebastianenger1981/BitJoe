#!/usr/bin/perl	-I/root/.mutella/MutellaProxy

use MutellaProxy::Time;

my $DATE = MutellaProxy::Time->GetValid8DayDateForLicence();

print "$DATE\n";
