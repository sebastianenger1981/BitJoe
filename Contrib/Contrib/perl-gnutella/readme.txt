Sorry.. lots of stuff going on...

 Here are the files... newgnut is the daemon, reads hosts from .hosts....
client2 I kind of used as a library, client5 was the most recent version,
does a require of client2. The clients connect to the daemon.

 You have to pass the client a -W with a directory and -d with the number of
matches you need on the same file before you start a download attempt, -p and
-P include or exclude porn as best they can. a query item that starts with a
! excludes anything that matches a perl regexp. -m is min size in bytes, -M
is max size... a common query may be...

./client5 -d 1 -W /tmp/music -m 2000000 -M 7000000 'walk this way' '!(run\s*dmc|kidd\s*rock)'

 Push is not supported.

 It needs some real work on connecting to peers, only a few work right
with it.

 Let me know if you have questions.
- Zitierten Text anzeigen -


On Fri, May 05, 2006 at 02:28:53PM +0200, Sebastian Enger wrote:
> Hi Anthony,
>
> so do you please send me your gnutella perl code so that i can continue your
> work?
>
> Thanks,
> Sebastian
>
> 2006/5/3, Anthony R. J. Ball <ant@suave.net>:
> >
> >
> >  Heh.. I have one partially written, it kind of works. Haven't really
> >worked on it lately. I can give you the code to get you started if you
> >want.
> >
> >On Wed, May 03, 2006 at 03:57:53AM +0200, Sebastian Enger wrote:
> >> Hi to you,
> >>
> >> my name is Sebastian and i red that you are working on a perl gnutella
> >> client. Are you still working on it?
> >> Need help?
> >>
> >>
> >> Yours,
> >> Sebastian
> >>
> >> --
> >> Sebastian Enger / B. Sc.
> >> Web:     http://www.sebastian-enger.de.vu/
> >> eMail:    thecerial@gmail.com
> >> Phone:  ++49 (0) 160 7979247
> >> Skype:  zoozleadmin
> >> ICQ:      135846444
> >>
> >> "Unser Schicksal h??ngt nicht von den Sternen ab, sondern von unserem
> >> Handeln."
> >
> >--
> >     www.suave.net - Anthony Ball - ant@suave.net
> >        OSB - http://rivendell.suave.net/Beer
> >-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
> >Uh-oh.  This isn't good.  I've seen good before, and this isn't it.
> >
> >
>
>
> --
> Sebastian Enger / B. Sc.
> Web:     http://www.sebastian-enger.de.vu/
> eMail:    thecerial@gmail.com
> Phone:  ++49 (0) 160 7979247
> Skype:  zoozleadmin
> ICQ:      135846444
>
> "Unser Schicksal h??ngt nicht von den Sternen ab, sondern von unserem
> Handeln."

--
    www.suave.net - Anthony Ball - ant@suave.net
       OSB - http://rivendell.suave.net/Beer
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
The symbol is not the same as the reality.
