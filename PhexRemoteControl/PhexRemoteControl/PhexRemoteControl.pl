#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	17.1.2008
##### Function:		Hauptdatei für PhexRemoteControl
##### Todo:			Pfade für Linux Binarys (ps|top) anpassen
##### Last Added:	21.1.2008 - Free Server Memory
########################################

# root: -20 <> 20 | normal: 0 <> 20
my $ServicePriority = "10";				

system("renice $ServicePriority $$");
system("clear");

use constant VERSION	=> "PhexRemoteControl - 21.1.2007 @ 22.50 Uhr - Version 0.3.0 + gzip";
use constant PIDFILE	=> "/server/phexproxy/phexremotecontrol-pid.txt";
use constant LOGFILE	=> "/server/phexproxy/phexremotecontroll_logfile.txt";

use constant CRLF		=> "\r\n";

######################
### Module einbinden
######################

use strict;
use IO::Select;
use Net::hostent;
use PhexProxy::IO;
use PhexProxy::Gzip;
use PhexProxy::Phex;
use PhexProxy::Time;
use PhexProxy::Daemon;
use PhexProxy::CheckSum;


######################
### Objekte initialisieren
######################

my $IO					= PhexProxy::IO->new();
my $GZIP				= PhexProxy::Gzip->new();
my $Phex				= PhexProxy::Phex->new();
my $TIME				= PhexProxy::Time->new();
my $CHECKSUM			= PhexProxy::CheckSum->new();

###################################

my $DONE;
my $ClientSocket;
my $ClientIPAdress;

my $PhexRestart			= "phexrestart.pl";
my $PhexBinary			= "phex.jar";
my $FreeMem				= "Mem:";
my $FreeSwap			= "Swap:";
my ($ServerIPAdress)	= `LANG=US_us ifconfig eth0`=~/inet addr:([\d.]+)/;
my $port				= 9977;	# für IO von web->$0
my $ConnectionSocket	= &CreateConnectionSocket( $port );
my $SecurityToken		= "%6ASdgdfAERGHA7845338w4eFW44325fwer";
my $Token				= $Phex->readToken();

$SIG{'INT'}				= $SIG{'TERM'} =	sub { warn "SignalHandler Interrupt "; $DONE++; exit; };
use constant CRLF		=> "\r\n";

###################################

my $IN					= IO::Select->new($ConnectionSocket);

# für die finale version aktiviere das init_server();
# create PID file, initialize logging, and go into the background
unlink PIDFILE;
#&init_server(PIDFILE);

die "can't setup proxy server" unless $ConnectionSocket;
print "[Server $0 Version " . VERSION . " accepting clients on host $ServerIPAdress port $port with Priority '$ServicePriority']\n";

########################
##### while accept loop
########################
# my $PlainText = $CRYPTO->Decrypt( $PrivateCryptoKey, $ReadFromClient );

while (!$DONE) {

	next unless $IN->can_read;
	next unless $ClientSocket	= $ConnectionSocket->accept();
	$ClientIPAdress				= $ClientSocket->sockhost;

	my $child					= launch_child();

	unless ($child) {

	# Aufbau '$key##$SecurityToken\r\n'
	my $ReadFromClient			= $IO->readSocket( $ClientSocket );	
	my ( $stuff			)		= split("\r\n", $ReadFromClient ); 
	my ( @IOReadFromClient )	= split("##", $stuff ); 
	
	#	print "I got: '$IOReadFromClient[0]' and '$IOReadFromClient[1]'\n";

	### Security Check: start
	if ( $IOReadFromClient[1] ne $SecurityToken ) {	
		
	#	print "Security Token Missmatch: '@IOReadFromClient': \n";
		$IO->writeSocket( $ClientSocket, "Wrong Protocol" . CRLF );	
		exit(0);

	}; # if ( $IOReadFromClient[1] ne $SecurityToken ) {	
	### Security Check: end

	my $CurrentTime = $TIME->MySQLDateTime();
	
	# Hier Parameter verarbeiten
	if ( $IOReadFromClient[0] eq 'load' ) {				# load status abfragen
	
		####################################################
		######	Phex Load Status des Servers abholen #######
		####################################################

		my $FileContent;

		open(FILE, "</proc/loadavg" ) or warn "$0->ReadFile(/proc/loadavg): IO ERROR: $!\n";
		flock(FILE, 2);
		{ 	local $/		= undef;	# Read entire file at once
			$FileContent	= <FILE>;   # Return file as one single `line'
        };  
		close FILE;

		my ($Load1,$Load2,$Load3,undef)	= split(" ", $FileContent);
		my $CurrentLoad					= "$Load1 $Load2 $Load3";
		print "$CurrentTime [IP:$ClientIPAdress] - Load Request - '$CurrentLoad' \n";
		$IO->writeSocket( $ClientSocket, $CurrentLoad . CRLF );	
	
	} elsif ( $IOReadFromClient[0] eq 'restart' ) {		# phex restarten

		#####################################################################
		######	Phex auf Servers jetzt beenden und neu starten lassen #######
		#####################################################################

		my $PhexRestartPID	= `/bin/ps aux | grep $PhexRestart | grep perl`;
		
		my (@PID)			= split(" ", $PhexRestartPID);
		$PhexRestartPID		= $PID[1];
		chomp($PhexRestartPID);

		if ( $PhexRestartPID !~ /\d{1,6}/ || length($PhexRestartPID) <= 0 ) {
			
			print "$CurrentTime [IP:$ClientIPAdress] - Phex Restart Request - 'Cannot Restart: phexrestart.pl not running / PID of phexrestart.pl not found' \n";
			$IO->writeSocket( $ClientSocket, "Cannot Restart: phexrestart.pl not running / PID of phexrestart.pl not found" . CRLF );	

		} else {
		
			my $PhexBinaryPID = `/bin/ps aux | grep $PhexBinary | grep java`;
			my (@PID1)			= split(" ", $PhexBinaryPID);
			$PhexBinaryPID		= $PID1[1];

			chomp($PhexBinaryPID);	
		
			if ( $PhexBinaryPID =~ /\d{1,6}/ ) {
			
				kill 9, $PhexBinaryPID || system("/bin/kill -9 $PhexBinaryPID");
				print "$CurrentTime [IP:$ClientIPAdress] - Phex Restart Request - 'PID $PhexBinaryPID - PhexKilled - Restarted by phexrestart.pl' \n";
				
				$IO->writeSocket( $ClientSocket, "PID $PhexBinaryPID - PhexKilled - Restarted by phexrestart.pl#" . CRLF );	

			}; # if ( $PhexBinaryPID =~ /\d{1,6}/ ) {

		}; # if ( $PhexRestartPID !~ /\d{1,6}/ || length($PhexRestartPID) <= 0 ) {


	} elsif ( $IOReadFromClient[0] eq 'memory' ) {		# speicherverbrauch des Phex testen

		######################################################
		######	Phex Memory Status des Servers abholen #######
		######################################################

		my $GesamtSpeicher			= `/usr/bin/top -n1 | grep $FreeMem`;
		my $MemoryUsage				= `/bin/ps aux | grep $PhexBinary | grep java`;
	
		my (@Memory)				= split(" ", $GesamtSpeicher);
		my $GesamtSpeicher			= $Memory[2];
		$GesamtSpeicher				=~ s/(b|k|m|g)//ig;

		my (@Memory2)				= split(" ", $MemoryUsage);
		my $PhexRealMemoryUsage		= $Memory2[5];
		my $PhexVirtualMemoryUsage	= $Memory2[4];
		$PhexRealMemoryUsage		=~ s/(b|k|m|g)//ig;
		$PhexVirtualMemoryUsage		=~ s/(b|k|m|g)//ig;

		chomp($GesamtSpeicher);
		chomp($PhexVirtualMemoryUsage);
		chomp($PhexRealMemoryUsage);
	
		$GesamtSpeicher				= sprintf("%.2f", ( $GesamtSpeicher / 1024 ));
		$PhexVirtualMemoryUsage		= sprintf("%.2f", ( $PhexVirtualMemoryUsage / 1024 ));
		$PhexRealMemoryUsage		= sprintf("%.2f", ( $PhexRealMemoryUsage / 1024 ));
		
		my $Memory					= $GesamtSpeicher . "M " . $PhexVirtualMemoryUsage . "M " . $PhexRealMemoryUsage ."M";

		print "$CurrentTime [IP:$ClientIPAdress] - Server Memory Request - '$Memory'\n";
		
		$IO->writeSocket( $ClientSocket, $Memory . CRLF );	


	} elsif ( $IOReadFromClient[0] eq 'uptime' ) {		# phex uptime status 
	
		######################################################
		######	Phex Uptime Status des Servers abholen #######
		######################################################

		my $Uptime;
		my $UptimeUsage				= `/bin/ps aux | grep $PhexBinary | grep java`;
		my (@Uptime)				= split(" ", $UptimeUsage);
		$UptimeUsage				= $Uptime[8];
		my ( $date, $time)			= split(" ", $CurrentTime);	
		my ($year,$mon,$day)		= split("-", $date);
		$date						= "$day.$mon.$year";

		if ( $UptimeUsage =~ /:/ ) {
			
			my ( $a1, $a2, $a3 )		= split(":", $time);
			my ( $b1, $b2, $b3 )		= split(":", "$UptimeUsage:00");
			
			my $hour					= $a1 - $b1; $hour =~ s/-//;	# $hour--;
			my $min						= $a2 - $b2; $min =~ s/-//;		#$min = 60 - $min;
			my $sec						= $a3 - $b3; $sec =~ s/-//;

			my $UptimeFinal				= "$hour:$min:$sec";
			$Uptime						= "$time-$date $UptimeUsage:00 $UptimeFinal";

		} else {

			$Uptime						= "$time-$date $UptimeUsage $UptimeUsage";

		}; # if ( $UptimeUsage =~ /:/ ) {

		print "$CurrentTime [IP:$ClientIPAdress] - Phex Uptime Request - '$Uptime'\n";
		$IO->writeSocket( $ClientSocket, $Uptime . CRLF );	


	} elsif ( $IOReadFromClient[0] eq 'status' ) {		# phex status 

		##############################################
		######	Phex Status des Servers prüfen #######
		##############################################

		my $Status	= $Phex->status( "127.0.0.1", $Token); 
		
		my $ReturnResultString;
		if ( $Status =~ /running/ig ) {
			$ReturnResultString = "Phex $ServerIPAdress running";
		} else {
			$ReturnResultString = "Phex $ServerIPAdress not working correctly - restart suggested!";
		}; # if ( $ReturnString =~ /searching/ig ) {

		print "$CurrentTime [IP:$ClientIPAdress] - Phex Status Request - '$ReturnResultString'\n";
		$IO->writeSocket( $ClientSocket, $ReturnResultString . CRLF );	

	
	} elsif ( $IOReadFromClient[0] eq 'freemem' ) {		# phex status 

		##############################################
		######	Phex Status des Servers prüfen #######
		##############################################

		my $SystemFreeMemory		= `/usr/bin/free -m aux | grep $FreeMem`;
		chomp($SystemFreeMemory);
		my (undef,undef,undef,$SystemFreeMemory)	= split(" ", $SystemFreeMemory);
		

		my $SystemFreeSwap	= `/usr/bin/free -m aux | grep $FreeSwap`;
		chomp($SystemFreeSwap);
		my (undef,undef,undef,$SystemFreeSwap)	= split(" ", $SystemFreeSwap);

		my $ReturnString = "$SystemFreeMemory#$SystemFreeSwap";
		print "$CurrentTime [IP:$ClientIPAdress] - Phex Free Memory Request - 'Memory: $SystemFreeMemory MByte | Swap: $SystemFreeSwap Mbyte'\n";
		$IO->writeSocket( $ClientSocket, $ReturnString . CRLF );	

	}; # if ( $IOReadFromClient[0] eq 'load' ) {


	close($ConnectionSocket);
	exit(0);

	}; #  unless ($child) {}

	close $ClientSocket;

}; # while (!$DONE) {}

########################
##### while accept loop
########################

die "Normal termination\n";
exit(0);


sub CreateConnectionSocket(){

	no strict 'subs';
	my $port	= shift || 9977;
	my $socket	= IO::Socket::INET->new(
		LocalPort	=> $port,
		Proto		=> 'tcp',
		Listen		=> SOMAXCONN,
		Reuse		=> 1,
	) or die "$0->CreateProxySocket($port): Can't create listen socket: $!\n";

	use strict;
	return $socket;
	
}; # sub CreateConnectionSocket(){}

	
#	# Daten komprimieren
#	use Compress::Zlib;
#	my $Compressed = Compress::Zlib::memGzip($CurrentLoad) ;


# memory auslesen
# top -n1 | grep Mem: | awk '{ print $3 }' 

### ps aux | grep "perl phexrestart.pl"
# ps aux | grep phexrestart.pl | grep perl | awk '{ print $2}'

# ps aux | grep phex.jar | grep java | awk '{ print $5}' --- get virutelle current memory usage:
# ps aux | grep phex.jar | grep java | awk '{ print $6}' --- get raw current memory usage
# alle daten kommen als KB an 

# ps aux | grep phex.jar | grep java | awk '{ print $2}' --- phex.jar PID auslesen

#$GesamtSpeicher				= chop($GesamtSpeicher);
		#$GesamtSpeicher			= substr($GesamtSpeicher, length($GesamtSpeicher)-1, length($GesamtSpeicher)) = ""; # entferne zeichen "k" von string