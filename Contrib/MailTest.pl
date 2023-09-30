#!/usr/bin/perl -w


use MIME::Lite; #  perl -MCPAN -e 'install "MIME::Lite"'
#
# Variablendefinition
my $to		 = 'thecerial@gmail.com';
my $from     = 'root@zoozle.net';
my $name     = 'Basti';
my $vorname  = 'BigBoss';
my $subject  = 'TestNachricht';
my $body     = 'Dies ist eine Testmail.und zwar die 2. version';


 ### Create a new single-part message, to send a GIF file:
    $msg = MIME::Lite->new(
                 From     => $from,
                 To       => $to,
                # Cc       => 'torsten.morgenroth@gmail.com',
                 Subject  => $subject,
                 Type     => 'text/plain',
				 Data     => $body,
                # Encoding =>'base64',
                # Path     =>'hellonurse.gif'
                 );
 $msg->send;
 system("/usr/sbin/postfix flush");