#!/usr/bin/perl
#
# 2002/06/22
# muwi v0.4, the Mutella Web Interface
# =======================================
#
# Copyright (C) 2002, M.R. Pape      <muwi@mr-pape.de>
#                     S. Ritterbusch
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# Find out about mutella at http://mutella.sourceforge.net/
#

BEGIN
{
   eval "use CGI::Carp qw(fatalsToBrowser)" if( $ENV{'REQUEST_METHOD'} );
} 

#########################################################################
#
# include Configuration-File
#
#########################################################################
do "/home/mutella/.mutella/mutelladrc" or die "Can't read config file\n";




#########################################################################
#
# NO NEED TO CHANGE ANYTHING BELOW
# 
#########################################################################

# define Version
my $Version="v0.4";

# get program name to use it later in the urls
$0 =~ s|.*/||;

use strict;
use IO::Socket; 
use vars qw(
   $SockFile
   $FaviconPath
   $DownloadPath
   $ShowEvents
   $RepeatCommand
   $RepeatTime
   $PageBGColor
   $MenuBGColor
   $MenuBrdColor
   $CmdColor
   $LineColor1
   $LineColor2
   $SectionColor
   $TotalColor
);

my $CMD;
my $CmdOptions;       # needed for "list -empty" or "list -auto"
my %QS;
my $LineColor = $LineColor1;
my @ResponseFromMutella;

if( ! $ENV{'REQUEST_METHOD'} )
{
   # Terminal
   $CMD = "@ARGV";

   # show info if no CMD is given
   $CMD = "info"    if ( ! $CMD );
   &FullHelp        if ( $CMD eq "fullhelp" );

   &BuildOutput($CMD,0);
}
else
{
   # Browser
   my $Data;
   
   # Read QUERY_STRING from GET or POST
   if( $ENV{'REQUEST_METHOD'} eq "GET" )
   {
      $Data = $ENV{'QUERY_STRING'};
   }
   else
   {
      read(STDIN, $Data, $ENV{'CONTENT_LENGTH'});
   }  
                                                         
   # this is a typical request that the browser send
   #http://xxx/cgi-bin/muwi?query=something&minsize=100M&abssize=0&btn=Find
   #http://xxx/cgi-bin/muwi?query=something&btn=Command&minsize=0&abssize=0
   
   # split QUERY_STRING Data and build the command
   my @KeyValuePair = split(/&/, $Data);
   
   foreach (@KeyValuePair)
   {
      my ($Key, $Value) = split(/=/, $_, 2);   
                        
      $Key   =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
      $Key   =~ s/^[\s]*//;     # strip leading spaces
      $Key   =~ s/[\s]+$//;     # strip spaces at the end
      
      
      $Value =~ tr/+/ /;
      $Value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
      $Value =~ s/<!--(.|\n)*-->//g;
      $Value =~ s/^[\s]*//;     # strip leading spaces
      $Value =~ s/[\s]+$//;     # strip spaces at the end
     
      # put QUERY_STRING in Hash %QS
      $QS{$Key} = $Value;
   }                        
   
   #  generate $CMD which will be send to mutella.
   if( exists $QS{"CMD"} )
   {
      $CMD = $QS{"CMD"};           # A link was pressed.
      $CMD .= " " .$QS{"nr"}  if( exists $QS{"nr"} );
   }
   else
   {
      if( $QS{"btn"} eq "Find" )   # The "Find" button was pressed.
      {
         $CMD = "find ";             
         if( $QS{"query"} ne "" )
         {
            $CMD .= $QS{"query"};         # There was something in the query.
            if ( $QS{"abssize"} eq "0" )  # Add "min:" or "size:" if requested.
            { 
               $CMD .= " min:". $QS{"minsize"}  if ( $QS{"minsize"} ne "0" );
            }
            else
            {
               $CMD .= " size:". $QS{"abssize"};
            }
         }
         else
         {
            $CMD="list";          # Find requests with empty query return list.
         }
      }
      elsif( $QS{"btn"} eq "Command" )    # The "Command" button was pressed.
      {
         $CMD = $QS{"query"};
      }
      elsif( $QS{"btn"} eq "Move" )       # edit up/downloads in list.
      {
         $CMD = "move " . $QS{"nr"} ." ". $QS{"query"};
      }
      elsif( $QS{"btn"} eq "Edit" )
      {
         $CMD = "edit " . $QS{"nr"} ." ". $QS{"query"};
      }
      elsif( $QS{"btn"} eq "Set" )
      {
         $CMD = "set " . $QS{"var"} ." ". $QS{"query"};
      }
      elsif( $QS{"btn"} eq "Dset" )
      {
         $CMD = "dset " . $QS{"var"} ." ". $QS{"query"};
      }
      else
      {
         $CMD = $QS{"query"};
      }
   }  
   
   
   # Browser
   # print goes to STDOUT, that means to the Browser

   # print html header 
   print "Content-type: text/html\n\n" 
        ,"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n"
        ,"<html><head>\n" 
        ,"<title>Mutella Web Interface</title>\n" ;
   
   print '<LINK REL="SHORTCUT ICON" HREF="'.$FaviconPath
        ,'" TYPE="image/x-icon">'."\n"         if ( $FaviconPath );
   
   print "<meta http-equiv=\"content-type\" " 
        ,"content=\"text/html; charset=iso-8859-1\">\n" 
        ,"<meta http-equiv=\"refresh\" content=\"$RepeatTime;"
        ,   "url=$0?CMD=$RepeatCommand\">\n" 

        ,"<style type=\"text/css\">" 
        ,"<!--\n" 
        ,"a:link    { color:#0000EE; }\n" 
        ,"a:visited { color:#0000EE; }\n" 
#        ,"a:link    { color:#EE6666; }\n" 
#        ,"a:visited { color:#EE6666; }\n" 
        ,"a:hover   { color:#EE0000; background-color:#FFFF99; }\n" 
        ,"a { "
        ,   "font-weight:bold; "
        ,   "text-decoration:none; "
        ,"}\n" 
        ,"a.btn { "
#        ,   "background-color:$CmdColor; "
#        ,   "border:2px solid green; "
        ,   "margin:4px; "
        ,   "padding-right:3px; "
        ,   "padding-left:3px; "
        ,"}\n"
        ,"table.main { "
        ,   "border-spacing:0px; "
        ,   "white-space:nowrap; "
        ,   "width:100%; "
        ,"}\n"
        ,"table.form { "
        ,   "white-space:nowrap; "
        ,   "border-spacing:0px; "
        ,"}\n"
        ,"table.menu { "
        ,   "border-spacing:1px; "
        ,   "background-color:#778899; "
#        ,   "line-height:150%; "
        ,   "margin:0px; "
        ,   "width:100%; "
        ,"}\n"
#        ,"table.red {border:thin solid red; }\n"

        ,"tr.num { background-color:#a0a0a0; line-height:150%; }\n"
        ,"tr.linecolor1 { background-color:#d0d0d0; }\n"
        ,"tr.linecolor2 { background-color:#f0f0f0; }\n"
        ,"td { padding:3px; padding-right:5px; padding-left:5px; }\n"
        ,"td.color1 { background-color:#d0d0d0; }\n"
        ,"td.color2 { background-color:#f0f0f0; }\n"

        ,"body {"
        ,   "background-color:$PageBGColor; "
        ,   "font-family:'sans serif'; "
        ,"}\n"
         
        ,"-->\n" 
        ,"</style>\n"

        ,"</head><body>\n" 
        
        ,"<h2>Mutella Web Interface:</h2>\n";
         
   # the form things in a table
   print "<form action=\"$0";
   print "\#$QS{'nr'}"         if ( $QS{'nr'} );
   print "\" method=\"GET\">\n"
        ,'<table class="form">',"\n"
        ,'<tr>'
        ,'<td><input type="text" name="query" size="50"></td>',"\n"
        ,'<td valign="left">'
        ,'<input type="submit" style="width:8em" name="btn" value="Command">'
        ,"</td>\n"
        ,"</tr><tr>\n" 
        ,'<td>Filesize: <b>min:</b> '
        ,'<select name="minsize" '
        ,   'style="margin-left:4px; margin-right:4px;" >',"\n"
        ,'<option value="0" selected>0</option>',"\n"
        ,'<option value="1M">1M</option>',"\n"
        ,'<option value="2M">2M</option>',"\n"
        ,'<option value="3M">3M</option>',"\n"
        ,'<option value="5M">5M</option>',"\n"
        ,'<option value="10M">10M</option>',"\n"
        ,'<option value="20M">30M</option>',"\n"
        ,'<option value="30M">20M</option>',"\n"
        ,'<option value="50M">50M</option>',"\n"
        ,'<option value="100M">100M</option>',"\n"
        ,'<option value="200M">200M</option>',"\n"
        ,'<option value="500M">500M</option>',"\n"
        ,"</select>\n <b>abs:</b> "
        ,'<input type="text" name="abssize" size="11" value="0" '
        ,   'style="margin-left:4px; margin-right:4px;"> bytes.</td>',"\n" 
        ,'<td>'
        ,  '<input type="submit" style="width:8em" name="btn" value="Find">'
        ,"</td>\n" 
        ,"</tr>\n" 
        ,"</table>\n"
        ,"&nbsp;"; 


   # define the Menu, use it later   
   my $Menu='<table class="menu">'."\n"
      ."<tr bgcolor=\"$MenuBGColor\">\n" 
      ."<td><a href=\"$0?CMD=info\">info</a></td>\n" 
      ."<td nowrap><a href=\"$0?CMD=info+downloads\">info downloads</a></td>\n"
      ."<td><a href=\"$0?CMD=library\">library</a></td>\n" 
      ."<td nowrap><a href=\"$0?CMD=showpartial\">partial downloads</a></td>\n"
      ."<td nowrap><a href=\"$0?CMD=lowtraffic\">low traffic</a></td>\n" 
      ."<td><a href=\"$0?CMD=set\">set</a></td>\n" 
      ."<td><a href=\"$0?CMD=help\">help</a></td>\n" 
         
      .'<td width="99%">&nbsp;</td>'."\n" 
         
      ."</tr><tr bgcolor=\"$MenuBGColor\">\n" 
         
      ."<td><a href=\"$0?CMD=list\">searches</a></td>\n"
      ."<td nowrap><a href=\"$0?CMD=list+-auto\">user searches</a></td>\n"
      ."<td nowrap><a href=\"$0?CMD=list+-empty\">search hits</a></td>\n"
      ."<td nowrap><a href=\"$0?CMD=showfinished\">finished downloads</a></td>\n" 
      ."<td nowrap><a href=\"$0?CMD=hightraffic\">high traffic</a></td>\n" 
      ."<td><a href=\"$0?CMD=dset\">dset</a></td>\n" 
      ."<td nowrap><a href=\"$0?CMD=fullhelp\">full help</a></td>\n" 
      
      .'<td width="99%">&nbsp;</td>'."\n" 
      ."</tr>\n" 
      ."</table>\n" 
      ."&nbsp;\n";

   print $Menu;
   
   print '<table class="main">'."\n";
   
   # if CMD is empty make it to "info" to get some info! :)
   if ( ! $CMD )
   {
      $CMD = "info";
   }
   # catch "system" calls. DANGER. mutella's system command is not secure!!!
   # catch "color" cmds also.
   elsif ( $CMD =~ /^[\s]*\!/ || $CMD =~ /^[\s]*sy/ || $CMD =~ /\|/ ||
           $CMD =~ /^[\s]*co/
         )
   {
      # show executed command in a colored line and a info msg
      print "<tr bgcolor=\"$CmdColor\"><td><b>$CMD</b></td></tr>\n" 
           ,"<tr bgcolor=\"$LineColor\"><td><p><pre>" 
           ,"Sorry. This command is not allowed in Muwi!" 
           ,"</p></pre></td></tr>\n" 
           ,"<tr><td>&nbsp;</td></tr>\n";
            
      $CMD="";
   }
   # create "edit search in list" and "move up/download to new name" page
   elsif ( ( $QS{"CMD"} =~ /^ed/ || $QS{"CMD"} =~ /^m/ ) &&
           exists $QS{"nr"} &&
           exists $QS{"text"}
         )
   {
      &ShowEditPage("search string","nr","text");
   }
   # create "set" and "dset" change setting page
   elsif ( $QS{"CMD"} =~ /^[d]*set/ &&
           exists $QS{"var"} &&
           exists $QS{"val"}
         )
   {
      &ShowEditPage("value","var","val");
   }
   # Change 'list -empty' or 'list -auto' back to 'list', because we need the 
   # right numbers when we prepend the commands in list -empty or -auto mode.
   # Later we have to do a regexp for auto|empty on QS{"query"}
   elsif ( $CMD =~ /^(?:l|li|lis|list) (-auto|-empty)/ )
   {
      $CMD = "list";
      $CmdOptions = $1;
   }
   
   # parse some user defined commands
   $CMD = "system ls -lhAto $DownloadPath/"    if ( $CMD eq "showfinished" );
   $CMD = "system ls -lhAS $DownloadPath/part" if ( $CMD eq "showpartial" );
   $CMD = "set MaxConnections 3"               if ( $CMD eq "lowtraffic" );
   $CMD = "set MaxConnections 10"              if ( $CMD eq "hightraffic" );
   &FullHelp                                   if ( $CMD eq "fullhelp" );
   
   # do normal conversation with mutella
   &BuildOutput($CMD,0);

   # add suitable output to quite silent commands
   &BuildOutput("info",0)   if ( $CMD =~ /^g/);   # get file
   &BuildOutput("info",1)   if ( $CMD =~ /^clo/); # close connection
   &BuildOutput("info",1)   if ( $CMD =~ /^st/);  # stop download
   &BuildOutput("info",1)   if ( $CMD =~ /^k/);   # kill download, erase file
   &BuildOutput("info",2)   if ( $CMD =~ /^o/);   # open connections 
   &BuildOutput("info",0)   if ( $CMD =~ /^m/);   # move downloads 
   &BuildOutput("info",0)   if ( $CMD =~ /set MaxConnections/);
   &BuildOutput("info",5)   if ( $CMD =~ /restart/);  
   &BuildOutput("list",0)   if ( $CMD =~ /^ed/);     # edit search kriteria
   &BuildOutput("list",0)   if ( $CMD =~ /^de/ );    # delete query
   &BuildOutput("list",5)   if ( $CMD =~ /^f/ );     # find an query
   &BuildOutput("system df $DownloadPath",0) if ( $CMD =~ /^system ls -lh/ );
   
   # print footer 
   print "</table>\n" 
         ,$Menu 
         ,"<hr noshade>\n" 
         ,"<p><font size=\"2\">\n"
         ,"This is <b>$0 $Version</b>. For comments or ideas contact "
         ,"<i><a href='mailto:muwi\@mr-pape.de'>muwi\@mr-pape.de</a></i><br>\n" 
         ,"Get Mutella from <a href=\"http://mutella.sourceforge.net/\">" 
         ,"http://mutella.sourceforge.net/</a>.\n" 
         ,"</font></p>\n"
         ,"</form>\n"
         ,"</body>\n" 
         ,"</html>";
}



         
###############################################################################
# Subroutines
###############################################################################
sub ShowEditPage
{
   my $Subject = shift;
   my $Var     = shift;
   my $Val     = shift;
   
   $CMD = $QS{"CMD"};

   print "<tr bgcolor=\"$CmdColor\"><td><b>$CMD</b></td></tr>\n" ;
   
   print "<tr bgcolor=\"$LineColor1\"><td>"
        ,"<p>Please change the $Subject in the entry.</p>\n"
        ,"<p>The old is: <b><i><code>'";
   
   if ( $CMD =~ /^([d])*set/ )
   {
      print $QS{$Var} . " = " . $QS{$Val};   # set and dset
   }
   else
   {
      print $QS{$Val};                       # move and edit
   }
   
   print "'</code></i></b><br>\n";
   
   print "<input type=\"hidden\" name=\"$Var\" value=\"".$QS{$Var}."\">\n"
        ,'<input type="text" name="query" size="50" value="'
        ,$QS{$Val} . '" style="margin-left:4px; margin-right:4px">'."\n" 
        ,'<input type="submit" style="width:8em" name="btn" value="'
        ."\u$CMD\">\n"
        ,'<input type="hidden" style="width:8em" name="btn" value="'
        ."\u$CMD\">\n"
        ,"</p>&nbsp;</td></tr>\n";
         
   print "<tr><td>&nbsp;</td></tr>\n";

   $CMD="";
   
   $CMD = $1 . "help " . $QS{$Var}  if ( $QS{"CMD"} =~ /^([d])*set/ );
}


sub FullHelp
{
   # build list of commands to get help on, using "help" and "set"
   my @CommandList;
   foreach my $Cmd ("help", "set" , "dset")
   {
      # get response and parse it
      @ResponseFromMutella = &Response($Cmd);
      
      for ( my $i = 2; $i < $#ResponseFromMutella; $i++ )
      {
         # here we need no colors! we just want the text!
         $_ = &RemoveAnsiColor($ResponseFromMutella[$i]);
         
         next if ( $_ =~ /========/ );
         next if ( $Cmd eq "help" && $_ =~ /:/ );    # ignore xyz: lines
         next if ( $Cmd =~ /set/  && $_ =~ /\[/ );   # ignore [ xyz ] lines
         
         last if ( $_ =~ /^Event/ && $ShowEvents eq "false"); 
         
         if ( $_ =~ /^[\s]*([\d\w!?]+) / )
         {
            if ( $Cmd eq "dset" )
            {
               push(@CommandList, "dhelp $1");
            }
            else
            {
               push(@CommandList, "help $1");
            }
         }
         else
         {
            last;
         }
      }
   } 
   
   # display "fullhelp" head line
   if( ! $ENV{'REQUEST_METHOD'} )
   {
      # Terminal
      print "  fullhelp
Here are the commands you can use with muwi & mutellad.

dset       Set the settings of mutellad. Use it like mutella's 'set'.
dhelp      Show some help on the the settings of mutellad. Use it like 'help'.

fullhelp   This shows help on all available commands from mutella and mutellad.
           Including set an dset.

restart    This restarts the mutellad.

";
   }
   else
   {
      # Browser
      print "<tr bgcolor=\"$CmdColor\"><td><b>fullhelp</b></td></tr>\n";
      
      print "<tr bgcolor=\"$SectionColor\"><td><pre>"
           ,"muwi & mutellad internal commands</pre></td></tr>\n"
           ,"<tr bgcolor=\"$LineColor\"><td><pre>"
           ,"dset\n"
           ,"    Set the settings of mutellad. Use it like mutella's \"set\".\n"
           ,"dhelp\n"
           ,"    Show some help on the the settings of mutellad. Use it like \"help\".\n\n"
           ,"fullhelp\n"
           ,"    shows help on all commands from mutella's \"help\" and \"set\".\n\n"
           ,"restart\n"
           ,"    restarts the mutellad\n"
           ,"</pre></td></tr>\n" 
           ,"<tr><td>&nbsp;</td></tr>\n";
   }
   
   # request help .... on each element of the CommandList and parse it.
   for ( my $i; $i < $#CommandList; $i++ )
   {
      &BuildOutput($CommandList[$i],0);  # send request 
   } 
   
   $CMD = $CommandList[$#CommandList];  # send last command from list 
}


sub Response 
{
   # do communication with mutella and return the answer
   
   my $CMD = shift;                        # CMD to send to mutella
   &OpenSocket;                            # call OpenSocket-Subroutine.
   print SOCKET "$CMD\n";                  # send request 
   return @ResponseFromMutella = <SOCKET>; # get response and return it
   close (SOCKET);
}


sub BuildOutput
{
   my $CMD = shift;         # CMD to send to mutella
   my $Sec = shift;         # Give mutella some time to collect infos
   
   sleep $Sec if ( $Sec > 0);
   return if ( ! $CMD );
  
   @ResponseFromMutella = &Response($CMD);

   # version of mutella from the first line of response
   my $MutellaVersion = shift @ResponseFromMutella || " ";
   chomp $MutellaVersion;
  
   # build output
   if( ! defined($ENV{'REQUEST_METHOD'}) )
   {
      # Terminal
      
      # print response, version is allready stripped
      foreach (@ResponseFromMutella)
      {
         print $_;
      }
      print "\n";
   }
   else 
   {
      # Browser
      
      # go from line to line in the ResponseFromMutella.
      # version is allready stripped.
      my $Section;
      my $LastLineColor;
      my $comment="";
      
      for (my $i=0; $i<=$#ResponseFromMutella; $i++)
      {
         # do all work on $_. The $_ line gets printed at end of routine.
         $_ = &RewriteColorAndChars($ResponseFromMutella[$i]);

         next if ( $_ =~ /----/   || $_ =~ /=====/ ); # ignore some lines
         last if ( $_ =~ /^Event/ && $ShowEvents eq "false"); 
         
         $_ =~ s/\[|\]//g if ( $_ =~ /\[/   && $CMD !~ /set/ );
         
         if ( $i == 0 )
         {
            # show executed command in a colored line and set a anchor with the 
            # first word of the command (for now only used at results)
            $_ =~ /<font> ([^ ]*).*$/ ;
            
            print "<tr bgcolor=\"$CmdColor\"><td>"
                 ,"<a name=\"$1\"></a><b>$_ $CmdOptions</b></td></tr>\n";
            next;
         }
         
         # if $_ isn't defined print white line. Not in fullhelp
         if ( ! $_ )
         {
            next if ( $QS{"CMD"} =~ /set/ );
            print "<tr><td>&nbsp;</td></tr>\n" if ( $QS{"CMD"} !~ /help/ );
            next;
         }
         
         my $row;    # text to show in a additional row
         my $inrow;  # text to show in the actual row like "close"
         
         # color should only be changed for new section, number, etc.
         ######################################################################
         
         # define different sections so they can be colorized
         if ( $_ =~ /^(network) horizon/              ||  # info
              $_ =~ /^(sockets)/                      ||  # info
              $_ =~ /^(bandwidth)/                    ||  # info 
              $_ =~ /^gnutella network (connections)/ ||  # info
              $_ =~ /^(uploads):/                     ||  # info
              $_ =~ /^(downloads):/                   ||  # info
              $_ =~ /(Searches) in progress/          ||  # info
              $_ =~ /Current search (results)/        ||  # result
              $_ =~ /^(shared)/                       ||  # library 
              $_ =~ /^(Event)/                        ||  
              $_ =~ /(\[ )/                               # set
            )
         {
            $Section = $1;
            $LineColor = $SectionColor;
         }
         # define some footer so they can be colorize with TotalColor 
         elsif ( $_ =~ /total.*: / || $_ =~ /count:/ )
         {
            $LineColor = $TotalColor;
         }
         # Show events in different color
         elsif( $Section eq "Event" && $_ !~ /^Event/ )
         {
            $LineColor = $LineColor2;
         }
         # See if we are in a section that does't uses numbered lines.
         elsif( ( $Section eq "network"   && $_ !~ /^network horizon/ ) ||
                ( $Section eq "sockets"   && $_ !~ /^sockets/ )         ||
                ( $Section eq "bandwidth" && $_ !~ /^bandwidth/ )       ||
                ( $Section eq "Event"     && $_ !~ /^Event/ )           ||
                ( $Section eq "[ "        && $_ !~ /\[ / )
              )
         {
            &SwitchLineColor   if ( $LastLineColor eq $LineColor );
         }
         # See if we are in a section that uses numbered lines. Use them
         # to build links with commands, i.e. search "  x)" 
         elsif ( $_ =~ /^[\s]*(\d+)\)/ )
         {
            my $Nr = $1;
         
            $_ =~ />[ `]*(.*)</;   # get text for move and edit
            my $text = $1;
            $text =~ s/'//;        # strip ' at end of list entrys
            
            # Switch colors
            &SwitchLineColor   if ( $LastLineColor eq $LineColor );
            
            # make links at beginning of numbered lines in the sections
            if ( $Section eq "uploads" )
            {
               # stop
               $inrow ="<a class=\"btn\" href=\"$0?CMD=stop&nr=$Nr\">stop</a>";
            }
            elsif ( $Section eq "downloads" )
            {
               # kill, stop, move
               $row = "<a name=\"$Nr\"></a>"
                     ."<a class=\"btn\" href=\"$0?CMD=kill&nr=$Nr\">kill</a>"
                     ."<a class=\"btn\" href=\"$0?CMD=stop&nr=$Nr\">stop</a>";
                    
               if ( $MutellaVersion gt "0.3.3" )
               {
                  $row .= '<a class="btn" '
                         ."href=\"$0?CMD=move&nr=$Nr&text=$text\">move</a>";
               }
            }
            elsif ( $Section eq "connections" )
            {
               # close
               $inrow='<a class="btn" href="'."$0?CMD=close&nr=$Nr\">close</a>";
            }
            elsif ( $Section eq "Searches" )
            {
               # anchor, results, clear, edit, delete
               $row = "<a name=\"$Nr\"></a>"

                     .'<a class="btn" '
                     ."href=\"$0?CMD=results&nr=$Nr#results\">results</a>"
                     
                     .'<a class="btn" '
                     ."href=\"$0?CMD=clear&nr=$Nr\">clear</a>";
                    
               if ( $MutellaVersion gt "0.3.3" )
               {
                  $row .= '<a class="btn" '
                         ."href=\"$0?CMD=edit&nr=$Nr&text=$text\">edit</a>";
               }
                  
               $row .= '<a class="btn" '
                      ."href=\"$0?CMD=delete&nr=$Nr#$Nr\">delete</a>";
            }
            elsif ( $Section eq "results" )
            {
               # get
               $inrow = '<a class="btn" '."href=\"$0?CMD=get&nr=$Nr\">get</a> ";
            }
         }
         
         # add help to the "set" and "dset" commands for each entry
         if ( $CMD =~ /^(d)*set/  && 
              $_ !~ /\[ /         && 
#              $Section ne "Event" &&
              ! $QS{"btn"}        # don't appy this if the (d)setbtn was pressed
            )
         {
            my $d = $1;
            $_ =~ /[^>]*>\s*([a-zA-Z0-9]+)
                     (?:        # nicht lesende Gruppierung, zaehlt nicht als $2
                       <[^>]*>  # matcht genau ein Tag <font>
                     )          # hier endet die Gruppierung 
                     ?          # 0 oder 1 mal treffen.
                     \s=\s(?:[^>]*>)?[`']*(.[^'<]*)/x ;

            # help, set, dhelp, dset
            $inrow = '<a class="btn" '
                    ."href=\"$0?CMD=$d"."help $1\">". $d . "help</a>"
                    
                    .'<a class="btn" '
                    ."href=\"$0?CMD=$d"."set&var=$1&val=$2\">". $d . "set</a> ";
#            $inrow .= "'$&'";    # $& shows the match !!!  
         }
        
         # print the $_ line in the defined LineColor
         print "<tr bgcolor=\"$LineColor\">";
         if ( $row )
         {
            # test if given command was list -auto or list -empty, we then have
            # to output only the HITS or not the AUTOGET lines   
            if ( ( $CmdOptions eq "-empty" 
                   && $ResponseFromMutella[$i+1] =~ /NO HITS/ )
               or
                 ( $CmdOptions eq "-auto"
                   && $ResponseFromMutella[$i+1] =~ /SIZE:/ ) 
               )
            {
               $i++;
               undef $row;
               next;
            }
         
            # print commands in a extra row 
            print "<td>$row</td></tr>\n"  if ( $row );
            print "<tr bgcolor=\"$LineColor\"><td><pre>$_</pre></td></tr>\n";
         }
         elsif ( $inrow )
         {
            # print with inrow
            $_ =~ s/ /&nbsp;/g;
            $_ =~ s/<font&nbsp;/<font /g;
            print "<td>$inrow<tt>$_</tt></td></tr>\n";
         }
         else
         {
            # print normal rows
            print "<td><pre>$_</pre></td></tr>\n";
         }
         
         undef $row; 
         undef $inrow; 
         
         $LastLineColor = $LineColor;
      }
      
      # print empty line to split composed commands
      print "<tr><td>&nbsp;</td></tr>\n";
   }   
}


sub RewriteColorAndChars
{
   $_ = shift;
         
   chomp $_;                    # remove return, because of <pre>
   
   $_ =~ s/\</\&lt\;/g;         # change < to html &lt;
   $_ =~ s/\>/\&gt\;/g;         # change > to html &gt;
   $_ =~ s/ä/\&auml\;/g;
   $_ =~ s/Ä/\&Äuml\;/g;
   $_ =~ s/ö/\&ouml\;/g;
   $_ =~ s/Ö/\&Ouml\;/g;
   $_ =~ s/ü/\&uuml\;/g;
   $_ =~ s/Ü/\&Uuml\;/g;
   $_ =~ s/ß/\&szlig\;/g;
   
   
   $_ = "<font>" . $_ . "</font>"; 
   $_ =~ s/\x1b\[2;37;0m/<\/font><font color=\"black\">/g;
   $_ =~ s/\x1b\[31m/<\/font><font color=\"red\">/g;
   $_ =~ s/\x1b\[32m/<\/font><font color=\"green\">/g;
   $_ =~ s/\x1b\[33m/<\/font><font color=\"brown\">/g;
   $_ =~ s/\x1b\[34m/<\/font><font color=\"blue\">/g;
   $_ =~ s/\x1b\[35m/<\/font><font color=\"purple\">/g;
   $_ =~ s/\x1b\[36m/<\/font><font color=\"#8080ff\">/g;  # darker cyan
   
   $_ =~ s/<font color=\"[\w]+?\"><\/font>//g;
   $_ =~ s/<font color=\"black\">(.*?)<\/font>/$1/g;
   $_ =~ s/<font>([ ]*)<\/font>/$1/g;
 
   $_ =~ s/\x1b\[1m(.*)/$1/g;
   $_ =~ s/\x1b\[1m//g;

   return $_;
}     


sub RemoveAnsiColor
{
   $_ = shift;
   $_ =~ s/\x1b\[[;\d\w]+?m//g; # remove ansi color from output
   return $_;
}


sub OpenSocket
{
   # Open SOCKET 
   socket(SOCKET, PF_UNIX, SOCK_STREAM, 0) 
      or die "\n$0 Can't connect to Socket\n";
   connect(SOCKET, sockaddr_un($SockFile)) 
      or die  "Bind to Socket failed\n";
   # TODO Change die Msg if htmloutput

   # unbuffered output of SOCKET
   select(SOCKET); $| = 1;
   select(STDOUT);
}  


sub SwitchLineColor
{
   if ( $LineColor eq $LineColor1 )
   {
      $LineColor = $LineColor2;
   }
   else
   {
      $LineColor = $LineColor1;
   }
}

