#!/usr/bin/perl

use Net::MySQL;	
use Digest::MD5 qw(md5 md5_hex md5_base64);


my $DBHOST		= "localhost";
my $DBNAME		= "bitjoe";
my $DBUSER		= "root";	
my $DBPASS		= "rouTer99";		

my $mysql = Net::MySQL->new(
  # hostname => 'mysql.example.jp',   # Default use UNIX socket
  unixsocket => '/var/run/mysqld/mysqld.sock',
  database => $DBNAME,
  user     => $DBUSER,
  password => $DBPASS
);

$BJParis_FirstCheck	= "SELECT username,password FROM `bjparis_new` WHERE `web_up_MD5` = \"\";";




 $mysql->query($BJParis_FirstCheck);
  my $record_set = $mysql->create_record_iterator;
  while (my $record = $record_set->each) {
      printf "Username: %s - Password: %s\n",
          $record->[0], $record->[1];
	  my $user = $record->[0];
	  my $pass = $record->[1];
	  my $web_up_MD5 = md5_hex( $user . $pass );

	  $mysql->query( 
				qq {
					UPDATE `bjparis_new` SET `web_up_MD5` = "$web_up_MD5" WHERE username="$user" AND password="$pass" LIMIT 1;
				});

  }
  $mysql->close;

exit;
