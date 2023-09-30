#!/usr/bin/perl -w
#
#
#  Parses the Mutella Upload log and sums it for Interest sake
#
#  NOTE1: I don't worry about full/partial, one file to one person
#           on one day is an upload, whether they take 1/2 or all of it.
#
#  NOTE2: For some sorts to work, Files SB named: ARTIST - ALBUM - ...
#
#  NOTE3: This was a quick thing for me, PLEASE extend it and share it back...
#
#  2003-11-30  Eric Aksomitis ( aksomitis@mail.com ) Original...
#

$_ = &parse_mutella_upload(@ARGV);

die $_ if ( $_ ne '0' );

sub parse_mutella_upload {
my($sort,$regex,$upload_log) = @_;

return &usage if ( $sort && $sort =~ m/\-+help|^\-+h|^\?|\/\?/i );

my($biggest,$totalsum) = ( 0 , 0 );

   $regex = '.' if ( ! defined($regex) );
   $upload_log = $ENV{'HOME'} . "/.mutella/upload.log" if ( ! defined($upload_log) );

   $sort = 'album' if ( ! $sort );

   open (INPUT,"<$upload_log") || return "Could not open $upload_log , $! \n";

   while ( <INPUT> ) {
      next if ( ! m/$regex/i ) ; # Filter first
      
      my @row = split(/\t/,$_);
      my ($date,$to,$file,$base1,$base2,$rest , $client);
      
      $date = $row[0];
      $date = substr($date,0,6);

      $to     = $row[5];
      $client = $row[6];

      # I assume Filenames are split (Artist - Album - .... )
      #  This is not required for all sorts to work though.
      ($base1,$base2,$rest) = split( /\ -\ |\ \,\ |\// , lc($row[7]) , 3);
      
      $base1 =~ s/\s+$//;

      $rest = '-' if ( ! $rest);
      $base2 = '-' if ( ! $base2);
      $base1 =~ s/^\s*file\://;
      next if ( $base1 =~ m/^\s*$/ ); # DUmmy file anyways

      $client =~ s/(\d+\.*)+$//; # Toast version no

      if    ( $sort eq 'artist' ) {
         # One upload to one person , summed By Artist (if applicable)
         $upload{"$base1"}{"$base2 - $rest TO $to on $date"} = 'Y';
      }
      elsif ( $sort eq 'fullalbums' ) {
         # One uploaded Song to as many people as wanted it,
         #  Basically how 'much' of the album was shared 
         # (IE the whole thing or just the one Radio Track )
         $upload{"$base1 - $base2"}{"$rest"} = 'Y';
      }
      elsif ( $sort eq 'client' ) {
         #  Different Clients, who am I giving to
         $upload{$client}{"$base1 - $base2 - $rest TO $to on $date"} = 'Y';
      }
      elsif ( $sort eq 'filetype' ) {
         #  Different Formats
         $_ = "$base1 $base2 $rest";
         s/.*\.// || ( $_ = 'None' );
         s/\s//g;
         s/\-+$//; # Sometimes I tacked on - for a filler in base2 , rest
         $upload{$_}{"$base1 - $base2 - $rest TO $to on $date"} = 'Y';
      }
      elsif ( $sort eq 'album' ) {
         # One upload to one person , summed By Artist / Album (if applicable)
         $upload{"$base1 - $base2"}{"$rest TO $to on $date"} = 'Y';
      }
      else {
         return "$sort is Not a Valid sort option, try -help\n";
      }
   }

   # We really don't care about the data now, just counts
   foreach my $sum ( keys %upload ) {
      $upload{$sum} = scalar(keys %{$upload{$sum} } ) ;
      $biggest = length($sum) if ( length($sum) > $biggest);
   }
   $biggest = 65 if ( $biggest > 65 );

   foreach my $sum ( sort { $upload{$::a} <=> $upload{$::b} }  keys %upload ) {
      print sprintf( "\%".$biggest."s -> \%10.0f \n", $sum
         , $upload{$sum} );
      $totalsum += $upload{$sum};
   }
   print sprintf( "\%".$biggest."s -> \%10.0f \n", "TOTAL:"
      , $totalsum );
   return '0';
}

sub usage {
   return "
Usage: $0 sort [regex_to_filter_upload] [alternate_upload_log]

Sort can be:
1) artist     -> Sum by artist
2) fullalbums -> Amount of an album thats been uploaded to anyone
3) client     -> What clients are uploading
4) filetype   -> Sort by filetype (ogg, mp3, mpg,avi etc )
5) album      -> Default:  Sort by artist_album

Songs Should be named Artist - Album - .... to sort for some sorts...

For REGEX, usually its just a date, but the whole upload line is compared with /i
Example:
$0 album 30.11.03        # By Album 30th November
$0 filetype '\\d\\d.11.03' # By Filetype , November
(BTW, technically it should be \\. to be safer, it is a regex :-) )
";

}
