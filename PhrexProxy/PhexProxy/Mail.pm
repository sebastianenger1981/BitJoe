#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian Enger / B.Sc
##### CopyRight:	BitJoe GmbH
##### LastModified	14.07.2006
##### Function:		Mail
##### Todo:			
########################################

package PhexProxy::Mail;

use PhexProxy::Time;
#use MIME::Lite;			#  perl -MCPAN -e 'force install "MIME::Lite"'
use strict;

# Variablendefinition
my $MailTo			= 'thecerial@gmail.com';
my $MailTo2			= '', #'torsten.morgenroth@gmail.com';
my $MailFrom		= 'root@zoozle.net';
my $MailSubject		= 'PhexProxy::Mail';
my $MailBody		= 'HOSTNAME: zoozle.net ';	# later: bestimme den hostname und sende ihn mit

my $SmtpUser		= "xxxx";	
my $SmtpPass		= "xxxx";

my $VERSION			= '0.17.1';


sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new(){}


sub SendNoHandyClientSocketMail(){

	my $self	= shift;
	my $host	= shift;

	my $time	= PhexProxy::Time->MySQLDateTime();

    my $msg		= MIME::Lite->new(
					From     => "servererror\@bitjoe.de",
					To       => "thecerial\@gmail.com",
					Subject  => "Paris Frontend Connection Down at [$time] on Server $host!",
					Type     => 'text/plain',
					Data     => "Paris Frontend Connection Down at [$time] on Server $host!",
                 );
	
	$msg->send("sendmail");	# send('smtp','smtp.gmail.com', AuthUser=>$SmtpUser, AuthPass=>$SmtpPass);
	# $msg->send('smtp','smtp.gmail.com', AuthUser=>$SmtpUser, AuthPass=>$SmtpPass);
	
	# system("/usr/sbin/postfix flush");
	system("/usr/sbin/sendmail -q");
	
	return 1;

}; # sub SendNoHandyClientSocketMail(){


sub SendProxyDownMail(){

	my $self	= shift;
	my $host	= shift;

	my $time	= PhexProxy::Time->MySQLDateTime();

    my $msg		= MIME::Lite->new(
					From     => "servererror\@bitjoe.de",
					To       => "thecerial\@gmail.com",
					Subject  => "Paris Backend Down at [$time] on Server $host!",
					Type     => 'text/plain',
					Data     => "Paris Backend Down at [$time] on Server $host!",
                 );

	$msg->send("sendmail");
	# $msg->send('smtp','smtp.gmail.com', AuthUser=>$SmtpUser, AuthPass=>$SmtpPass);

	# system("/usr/sbin/postfix flush");
	system("/usr/sbin/sendmail -q");

	return 1;

}; # sub SendProxyDownMail(){


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
	$msg->send("sendmail");
	# $msg->send('smtp','smtp.gmail.com', AuthUser=>$SmtpUser, AuthPass=>$SmtpPass);

	# system("/usr/sbin/postfix flush");
	# system("/usr/sbin/sendmail -q");

	return 1;

}; # sub SendMail(){}


return 1;