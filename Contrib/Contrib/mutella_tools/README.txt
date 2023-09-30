This Directory Contains some Tools I built to extend Mutella

Please extend them as you see fit, and do not be afraid to share back

They are fairly flexible, yet fairly basic Perl/shell scripts


2003-12-31   Eric Aksomitis ( aksomitis@mail.com )

CONTENTS:

1)  mutella.sh 
  Use this 2 start mutella, it launches in the backround, then gets fed from
  a named pipe.

2)  hookmutella.sh
  Use this to 'hook' into the running mutella.  It works almost like normal, 
  depending  on how you are logged in to the Linux Machine.
  TIP:  Don't do Ctrl-C to exit, type out as a command, it will get intercepted
  and will not go to mutella, it will just exit....

3)  speedmutella.sh
  Usage: speedmutella.sh __SPEED__  , with mutella launched from #1, you can
  automate the throttling of mutella (ie cron ! ).

4)  parse_mupload.pl 
  Parse / sort / summarize your upload log, by artist / album / filetype / client
  type etc...  Basic stuff with a couple of neat sorts, and filtering by date or
  arbitrary regex.....

5) sltors
  Symlink Files into Remote Mutella Share.  Saves space and lets you easily
  Manage what you want to share.  Also allows you to prefix names, or can
  automatically guess a name if you have DIR/artist/album/... (ie from grip ).

