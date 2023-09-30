#!/usr/bin/perl	-I/server/mutella/MutellaProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	14.07.2006
##### Function:		Mail
##### Todo:			
########################################

package MutellaProxy::Mail;

use MIME::Lite; #  perl -MCPAN -e 'install "MIME::Lite"'
use strict;

# Variablendefinition
my $MailTo		 = 'thecerial@gmail.com';
my $MailTo2		 = '', #'torsten.morgenroth@gmail.com';
my $MailFrom     = 'root@zoozle.net';
my $MailSubject  = 'MutellaProxy::Mail';
my $MailBody     = 'HOSTNAME: zoozle.net ';	# later: bestimme den hostname und sende ihn mit


my $VERSION			= '0.17.1';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub SendMail(){

	return 1;

	my $self		= shift;
	my $MailHashRef = shift;

    my $msg = MIME::Lite->new(
                 From     => $MailHashRef->{'FROM'} || $MailFrom,
                 To       => $MailHashRef->{'TO1'} || $MailTo,
                 Cc       => $MailHashRef->{'TO2'} || $MailTo2,
                 Subject  => $MailHashRef->{'SUBJECT'} || $MailSubject,
                 Type     => 'text/plain',
				 Data     => $MailBody . $MailHashRef->{'BODY'} || $MailBody,
                # Encoding =>'base64',
                # Path     =>'hellonurse.gif'
                 );
	$msg->send;
	system("/usr/sbin/postfix flush");
	
	return 1;

}; # sub SendMail(){}


return 1;