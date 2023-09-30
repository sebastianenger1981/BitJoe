#/bin/sh
#
#
#  Hooks into my running mutella, looks like a terminal running it
#  mutella must have been started with the mutella.sh supplied by me as well.
#
#  Not all Scrolling features work, but its 95% their.
#
#  NOTE:  To exit cleanly form a hookmutella.sh session, type
#   out
#   at the beginning of the line and hit enter, it won't even send it to mutella
#
#
# 2003-11-30 Eric Aksomitis (aksomitis@mail.com) Original
#
#
#

cd $HOME
tail -f out.txt &

TAILPID=$!

perl -e '
   while (1 ) {
      $_ = <STDIN> ; 
      last if ( m/^\s*out\s*$/i);
      
      open(OUT,">>.mutella.np");
      print OUT $_;
      
      if ( m/^\s*exit/i ) {
         sleep(1);
         close(OUT);
         last;
      }
     close(OUT);
  }
'
kill $TAILPID
