#!/bin/sh
#
#
#  Launches mutella with a Named-Pipe feeding ti, so I can hook into it
#  from any terminal with hookmutella.sh
#
#
# 2003-11-30 Eric Aksomitis (aksomitis@mail.com) Original
#

cd `dirname "$0"`
PATH="`pwd`:$PATH:/usr/local/bin:/opt/sfw/bin:/opt/freeware/bin"
export PATH

cd $HOME

rm -f .mutella.np
mknod .mutella.np p

echo 2> out.txt
perl -e '
   use IO::Handle;
   $MUT = IO::Handle->new();
   $MUT->autoflush(1);
   open($MUT,"| mutella > out.txt 2>&1");
   $MUT->autoflush(1);

   while (1) {
      open(INPUT,"<.mutella.np");
      $_ = <INPUT>;
      print $MUT $_;
      close(INPUT);
      if ( m/^\s*exit/i ) {
         sleep(1);
         close($MUT);
         last;
      }
   }
' &

exit 0
