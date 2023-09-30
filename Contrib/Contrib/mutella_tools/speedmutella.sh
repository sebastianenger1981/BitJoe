#/bin/sh 
#
#
#  Hooks into my running mutella, adjusts the Speed
#  mutella must have been started with the mutella.sh supplied by me as well.
#
#  Mainly for Choked DSL connections so the Upload doesn't kill the download
#  capacity
#
#
# 2003-11-30 Eric Aksomitis (aksomitis@mail.com) Original
#
#

SP="$1"
MAXUP="$2"
[ -z "$SP" ] && SP=10
[ -z "$MAXUP" ] && MAXUP=`expr $SP - 2 `


# Note, all the Enters are to scroll through the events
# Works only 1/2 well through a named pipe :-(
for a in 1 2 3 4
do
  for b in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 
  do
    echo >> ~/.mutella.np
  done
  sleep 1
done

sleep 1
echo "set BandwidthTotal " > ~/.mutella.np
sleep 1
echo "set BandwidthUpload " > ~/.mutella.np
sleep 1
echo "set BandwidthTotal $SP" > ~/.mutella.np
sleep 1
echo "set BandwidthUpload $MAXUP" > ~/.mutella.np
sleep 1
echo "set BandwidthTotal " > ~/.mutella.np
sleep 1
echo "set BandwidthUpload " > ~/.mutella.np
