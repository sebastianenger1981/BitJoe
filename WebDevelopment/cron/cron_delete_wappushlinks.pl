#!/usr/bin/perl

use strict;
no strict 'subs';

use File::Find qw(finddepth);
# perl -MCPAN -e 'force install "File::Find"'

*name = *File::name;
finddepth \&zap, '/srv/server/wwwroot/download';

sub zap() {
	
	if ( !-l && -d ) {
	
	#	print "rmtree $name\n";
	#	rmdir($name) or warn "$name not deleted: $!\n";

	} else {

	#	unlink($name) or warn "$name not deleted: $!\n";
		
		my $name	= $File::Find::name;
		my $dir		= $File::Find::dir;
		my @stats	= stat($name);
	
		next if ( $dir eq '/srv/server/wwwroot/download' );
		print "unlink $name | $dir \n";

		if ( time() > $stats[9] + 60*60*24 ) {	# wenn erstellte datei älter als 1h*24 ist
			
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($stats[9]);
			printf "%4d-%02d-%02d %02d:%02d:%02d [$dir] [$name]\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
			unlink($name) or warn "$name not deleted: $!\n";
			rmdir($dir);

		}; # if ( time() > $stats[9] + 60*60 ) {	# wenn erstellte datei älter als 1h ist
		
	}; # if ( !-l && -d ) {

}; # sub zap() {

# http://www.hidemail.de/blog/stat-perl-dateieigenschaften.shtml
# 00 */1 * * * /usr/bin/perl /srv/server/cron/cron_delete_wappushlinks.pl