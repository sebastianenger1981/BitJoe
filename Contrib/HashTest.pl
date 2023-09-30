
my %ConfigHash =(
	"1"	=> my $CfG1 = { 
			"HOST"	=> "HOSTIP",
			"USER"	=> "USERNAME",
			"PASS"	=> "PASSWORD"
			},
	"2"	=> my $CfG2 = { 
			"HOST"	=> "HOSTIP",
			"USER"	=> "USERNAME",
			"PASS"	=> "PASSWORD"
			}, 
	);


while ( my ($key, $value) = each(%ConfigHash) ) {
#		my $RemoteUserName	= %ConfigHash->{  }
#		my $RemotePassword
#		my $RemoteHostname
#		my $RemoteStorePath
		print $value->{'USER'} . "\n" ;
};