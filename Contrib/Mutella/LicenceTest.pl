#!/usr/bin/perl -I/root/.mutella/MutellaProxy


use MutellaProxy::LicenceManagement;

my $LICENCE		= MutellaProxy::LicenceManagement->new();
my ( @IOReadFromClient );

$IOReadFromClient[0] = ''; 
$IOReadFromClient[1] = '';
$IOReadFromClient[2] = '';
$IOReadFromClient[3] = 'TESTLICENCE';

$LICENCE->CheckLicence( \@IOReadFromClient );