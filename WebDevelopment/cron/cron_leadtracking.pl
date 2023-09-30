#!/usr/bin/perl

# 00 */1 * * * /usr/bin/perl /srv/server/cron/cron_leadtracking.pl

use DBI();
use strict;
use LWP::Simple;
use Data::Dumper;
use Digest::MD5 qw( md5_hex );

my $drh				= DBI->install_driver("mysql");

my $DBHOST			= "localhost";
my $DBNAME			= "bitjoe";
my $DBUSER			= "root";	
my $DBPASS			= "rouTer99";		

my $DBHandle		= DBI->connect("DBI:mysql:database=$DBNAME;host=$DBHOST", "$DBUSER", "$DBPASS", {'RaiseError' => 0});

my $CurrentDate		= getDATE();
my $SQLQuery		= "SELECT `web_mobilephone`,`web_ref_PP`,`web_grp_PP` FROM `bjparis` WHERE DATE(`web_signup_date`) = '$CurrentDate' AND `web_lead_istracked` = '0' AND `hc_abuse` = '0' AND `web_lead_istracked` = '0' AND `web_firstuse` = '0';";
my $ResultHashRef	= {};
my (@matrix)		= ();

eval {
	
	my $sth = $DBHandle->prepare( qq { $SQLQuery } );
	$sth->execute;
	#$ResultHashRef = $sth->fetchrow_hashref;
	
	while (my @ary = $sth->fetchrow_array()) {
		
		print Dumper @ary;

		# push(@matrix, [@ary]);  # [@ary] is a reference
		my $phone	= $ary[0];
		my $pp		= $ary[1];
		my $grp		= $ary[2];

		if ( $pp == 0 ) {
			$pp = 3;
		};
		if ( $grp == 0) {
			$grp = 1;
		};

		my $doc = "http://www.bitjoepartner.com/callbacks/callback_sample.php?txn_id=BITJOE&aff_id=$pp&group_id=$grp&amount=1&cur=EUR&country_code=de&add_info=" . md5_hex(time().rand(10000));
		my $ret = get($doc);

		print "RETURN: '$ret'\n";

		my $SqlBJParisUpdateTable = "UPDATE `bjparis` SET `web_lead_istracked` = \"1\" WHERE CONVERT( `bjparis`.`web_mobilephone` USING utf8 ) = '$phone' AND `hc_abuse` = '0' LIMIT 1;";
		
		my $DBHandle2 = DBI->connect("DBI:mysql:database=$DBNAME;host=$DBHOST", "$DBUSER", "$DBPASS", {'RaiseError' => 0});
		my $sth2 = $DBHandle2->prepare( qq { $SqlBJParisUpdateTable } );
		$sth2->execute;
		$sth2->finish;

	}; # while (my @ary = $sth->fetchrow_array()) {

	$sth->finish;

}; # eval {






# http://www.bitjoepartner.com/callbacks/callback_sample.php?txn_id=BITJOE&aff_id=0&group_id=0&amount=1&cur=EUR&country_code=de&add_info=




sub getDATE() {

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	$year = $year+1900;
	$mon = $mon + 1;

	if ( length($mon) == 1 ) {
		$mon = "0". $mon;
	};
	if ( length($mday) == 1 ) {
		$mday = "0". $mday;
	};

	my $date = $year ."-". $mon ."-". $mday;

	return $date;

}; # GetDate

