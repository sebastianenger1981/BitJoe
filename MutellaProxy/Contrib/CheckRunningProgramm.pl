#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	26.07.2006
##### Function:		Teste, ob alle Programm richtig laufen, sonst Fehleremail
##### Todo:			
########################################

use MutellaProxy::Mail;
use MutellaProxy::Time;
use strict;


$SIG{CHLD} = sub { wait };

my $pid;

my %ToCheckProgramms = (
	"AddUltraPeer"			=> "/usr/bin/perl /server/mutella/AddUltraPeers.pl",
	"MutellaProxy"			=> "/usr/bin/perl /server/mutella/MutellaProxy.pl",
	"mutella-0.4.6"			=> "/server/mutella/mutella-0.4.6-bin --config=/server/mutella/.mutellarc",
	"DeleteOldEntries.pl"	=> "/usr/bin/perl /server/mutella/DeleteOldEntries.pl",
);


while(1){
	CheckAndRestart();
	sleep 60;	# für firmenversion dann auf 5 sec stellen!!!
};


sub CheckAndRestart(){

	while ( my ($prog, $startpath) = each(%ToCheckProgramms) ) {
	
		my @ps1		= `ps aux`;

		my @found1	= grep { /$prog/i } @ps1;
		my @c1		= split("\n", @ps1 );

		# print $#found1; # error if -1

		if ( $#found1 == -1 ) {
		
			print MutellaProxy::Time->MySQLDateTime() . "ERROR: Programm $prog läuft nicht!\n";

			my $MailConfig = {
				'TO1'		=> 'thecerial@gmail.com',
				'SUBJECT'	=> "$prog - $startpath läuft nicht um " . MutellaProxy::Time->MySQLDateTime(),
				'BODY'		=> 'Versuche das Programm neu zu Starten!!!',
			};
			
			MutellaProxy::Mail->SendMail( $MailConfig );
			
			# forke und versuche das programm neu zu starten
			unless ($pid = fork) {
				unless (fork) {
					exec("$startpath");
					die "no exec";
					exit 0;
				}; # unless (fork) {}
				exit 0;
			}; # unless ($pid = fork) {}
			waitpid($pid,0);
		
		}; # if ( $#found1 == -1 ) {}

	}; # while ( my ($prog, $startpath) = each(%ToCheckProgramms) ) {}

	return 1;

}; #sub CheckAndRestart(){}


# foreach my $entry ( @found1 ) {
#	print "$entry";
# };