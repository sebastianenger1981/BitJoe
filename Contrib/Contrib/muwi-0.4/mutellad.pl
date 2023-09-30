#!/usr/bin/perl -w
#
# 2002/06/22
# mutellad v0.4, the Mutella MuWI (Mutella-Web-Interface) Daemon
# =================================================================
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

############################################################################
#
# Configuration Section, see also muwi
#
############################################################################
my $MutelladRC = "$ENV{'HOME'}/.mutella/mutelladrc";





############################################################################
#
# NO NEED TO CHANGE ANYTHING BELOW
#
############################################################################
my $Version = "v0.4";


if ( -e $MutelladRC )
{
   do $MutelladRC;
}
else
{
   # set default values and write file
   $SockFile = "/tmp/mutellad.sock"; 
   $PathToMutella = 'mutella';
   $UseAutoAdaptMaxConnections = 'true';   
   $HostToPing    = "heise.de";  # a host near to you, maybe your DNS
   $PingWait      = 10;          # Seconds to wait between each ping
   $PingCount     = 10;          # pings to send, before getting the average
   $PingTimeIncSet        = 100;        # add connections
   $MaxConnectionsIncSet  = 15;
   $AdjustIncSet          = 1;
   $PingTimeDecSet1       = 600;       # reduce connections
   $MaxConnectionsDecSet1 = 7;
   $AdjustDecSet1         = -4;
   $PingTimeDecSet2       = 400;
   $MaxConnectionsDecSet2 = 4;
   $AdjustDecSet2         = -3;
   $PingTimeDecSet3       = 200;
   $MaxConnectionsDecSet3 = 3;
   $AdjustDecSet3         = -1;
   $UseAutoAdaptHDSpace = 'true';
   $MinFreeSpace        = '5000';      # min disk free
   $FreeSpaceBound      = '50000';     # if df is lower then this, calculate
   $RepeatCommand       = 'info';
   $RepeatTime          = '120'; 
   $FaviconPath  = "/~mutella/muwi.ico"; # For no icon change variable to "".
   $ShowEvents   = "true";             # Show Events.
   $DownloadPath = "~/mutella";        # Path to show in Partial or Finished.
   $PageBGColor  = "antiquewhite";     # "#fffaf0"; # floralwhite
   $MenuBGColor  = "gainsboro";        # "#dcdcdc"; # gainsboro
   $MenuBrdColor = "darkgray";         # "#a9a9a9"; # darkgray
   $CmdColor     = "lightslategray";   # "#778899"; # lightslategray
   $SectionColor = "lightsteelblue";   # "#b0c4de"; # lightsteelblue
   $LineColor1   = "lightgrey";        # "#d3d3d3"; # lightgrey with "e"
   $LineColor2   = "whitesmoke";       # "#f5f5f5"; # whitesmoke
   $TotalColor   = "silver";           # "#c0c0c0"; # silver
   
   &WriteMutelladRC;
}


use strict;
use Socket; 
use IO::Handle;
use IPC::Open2;

no strict 'refs';
use vars qw(
   $SockFile
   $PathToMutella
   $HostToPing
   $PingWait
   $PingCount
   $PingTimeIncSet
   $MaxConnectionsIncSet
   $AdjustIncSet
   $PingTimeDecSet1
   $MaxConnectionsDecSet1
   $AdjustDecSet1
   $PingTimeDecSet2
   $MaxConnectionsDecSet2
   $AdjustDecSet2
   $PingTimeDecSet3
   $MaxConnectionsDecSet3
   $AdjustDecSet3
   $UseAutoAdaptMaxConnections
   $UseAutoAdaptHDSpace
   $MinFreeSpace
   $FreeSpaceBound
   $READER
   $WRITER
   $Cmd
   $Char
   $RepeatCommand
   $RepeatTime 
   $FaviconPath
   $DownloadPath
   $ShowEvents
   $PageBGColor
   $MenuBGColor
   $MenuBrdColor
   $CmdColor
   $SectionColor
   $LineColor1
   $LineColor2
   $TotalColor
);

my $CmdLine = "@ARGV";

# show help
if ( $CmdLine =~ /--help/ || $CmdLine =~ /-h/ )
{
   print <<EOH;

This is mutellad $Version, a wrapper for the mutella programm.

Usage: 

\$ \./mutellad [--debug] [--help]

mutellad starts mutella with the configuration of the actual user.
If mutellad is started without options it goes into demon mode. With
the  --debug  option the deamon does not disconnect from the terminal.

EOH

   exit;
}

# unbuffer STDERR and STDOUT
select STDERR; $| = 1;
select STDOUT; $| = 1;


# run in terminal
my $debug = 1      if ( $CmdLine =~ /--debug/ );

# run in background deamon mode
if ( ! $debug )
{
   # to run a Prozess as Deamon, fork() and close the parent.
   # The child continues running by the init-prozess
   my $ChildPID=fork();
    
   # if we are the parent, exit
   exit if ( $ChildPID );

   # if we get here, we're the child. 
   die "Could not fork to deamon mode :(" unless defined( $ChildPID );

   use POSIX;
   POSIX::setsid() or die"Could not disconnect from terminal\n";
}

   
# Create socket file to communicate with webinterface. 
# This must be done here, because if bind to socket fails, we don't want to
# start the AutoAdaptProcess
unlink $SockFile;                               # delete socketfile
socket(SERVER, PF_UNIX, SOCK_STREAM, 0);        # define SOCKET
bind(SERVER, sockaddr_un($SockFile)) 
   or die "\nmutellad: Could not bind deamon to Socket \"$SockFile\" :(\n\n";
listen (SERVER, SOMAXCONN)
   or die "\nmutellad: Can't connect to Socket :(\n\n"; 
chmod( 0777, ($SockFile) );                     # chmod a+r $SockFile


# Define all Variables ( VarName, RegExp, Help )
my @Settings=(
"SockFile", 
"[a-zA-Z0-9/]", 
"    Enter the path to the Socket-File, which muwi uses to talk to mutellad",

"PathToMutella", 
"[a-zA-Z0-9/]",
"    Enter the path to the mutella binary, p. e. /usr/local/bin/mutella.",

"UseAutoAdaptMaxConnections",
"true|false",
"    If you set UseAutoAdaptMaxConnections to true, mutellad automatically
    adapts the numbers of connections which mutella opens. The calculation
    is based on the average latency time meassured by ping. You can define 
    four rules to adapt the MaxConnections. One increasing the number of 
    connections, three other decreasing them.",

"HostToPing",
"[a-zA-Z0-9.]",
"    This should be a host near to you. For example your DNS.
    See also UseAutoAdaptMaxConnections.",

"PingWait", 
"[0-9]", 
"    Time to wait between two pings.
    See also UseAutoAdaptMaxConnections.",

"PingCount",
"[0-9]", 
"    Number of pings to send.
    See also UseAutoAdaptMaxConnections.",

"PingTimeIncSet",
"[0-9]", 
"    If the average ping time is lower then this and if MaxConnections is lower
    then the maximal number of connections defined by MaxConnectionsIncSet, 
    mutellad increases the number of MaxConnections.
    See also UseAutoAdaptMaxConnections.",

"MaxConnectionsIncSet",
"[0-9]", 
"    This is the maximum number of connections.
    See also UseAutoAdaptMaxConnections.",

"AdjustIncSet",
"[0-9]", 
"    The number of connections will be increased by this.
    See also UseAutoAdaptMaxConnections.",

"PingTimeDecSet1",
"[0-9]", 
"    If the average ping time is greater then this and if MaxConnections is 
    greater then the maximal number of connections defined by 
    MaxConnectionsDecSet1, mutellad decreases the number of MaxConnections.
    See also UseAutoAdaptMaxConnections.",

"MaxConnectionsDecSet1",
"[0-9]", 
"    This is the maximum number of connections.
    See also UseAutoAdaptMaxConnections and PingTimeDecSet1.",

"AdjustDecSet1",
"[0-9]", 
"    The number of connections will be increased with this amount.
    See also UseAutoAdaptMaxConnections and PingTimeDecSet1.",

"PingTimeDecSet2",
"[0-9]", 
"    See also UseAutoAdaptMaxConnections and PingTimeDecSet1...3 Settings.",

"MaxConnectionsDecSet2",
"[0-9]", 
"    See also UseAutoAdaptMaxConnections and PingTimeDecSet1...3 Settings.",

"AdjustDecSet2",
"[0-9]", 
"    See also UseAutoAdaptMaxConnections and PingTimeDecSet1...3 Settings.",

"PingTimeDecSet3",
"[0-9]", 
"    See also UseAutoAdaptMaxConnections and PingTimeDecSet1...3 Settings.",

"MaxConnectionsDecSet3",
"[0-9]", 
"    See also UseAutoAdaptMaxConnections and PingTimeDecSet1...3 Settings.",

"AdjustDecSet3",
"[0-9]", 
"    See also UseAutoAdaptMaxConnections and PingTimeDecSet1...3 Settings.",

"UseAutoAdaptHDSpace",
"true|false",
"    Mutellad also can adapt the MaxConnections based on the free HDSpace.
    If this is set to true, then mutellad will lower the MaxConnections step 
    by step to 0, leaving the 'MinFreeSpace'. Mutellad only acts this way if 
    the actual free space ist lower then the 'FreeSpaceBound'.",

"MinFreeSpace",
"[0-9]", 
"    See UseAutoAdaptHDSpace.",

"FreeSpaceBound", 
"[0-9]", 
"    See UseAutoAdaptHDSpace.",

"RepeatCommand", 
"[a-zA-Z0-9]",
"    Repeat the given command after 'RepeatTime'. The default is 'info'.",

"RepeatTime", 
"[0-9]",
"    Insert the amount of seconds after which the RepeatCommand is executed.",

"FaviconPath", 
"[a-zA-Z0-9/]",
"    This is the path to the favicon.",

"DownloadPath", 
"[a-zA-Z0-9/]",
"    This is the path where mutella save the downloads.",

"ShowEvents", 
"true|false",
"    As the variable say, show events in the Output or don't show them.",

"PageBGColor",
"[a-zA-Z0-9]", 
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"MenuBGColor", 
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"MenuBrdColor", 
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"CmdColor",
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"SectionColor",
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"LineColor1", 
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"LineColor2", 
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",

"TotalColor",
"[a-zA-Z0-9]",
"    The 'Name' of the HTML Color, i. e. 'silver' and not'#c0c0c0'.",
); 
   
my $MutellaVersion = " ";  # put space in, so that the sting isnt empty.

my $MaxCon;
my $AvPingTime;
my $MutellaPID;
my $AutoAdaptPID = fork();

if ( $AutoAdaptPID )
{
   # we are the parent
   &Debug ("\nStarting on PID $AutoAdaptPID: AutoAdaptProcess");

   &RunDeamonProcess;
}
else
{
   &AutoAdaptProcess;
}


###############################################################################
### Main Subroutines

### "RunDeamon"-Process #######################################################
sub RunDeamonProcess
{
   # define some signal handler
   $SIG{TERM} = \&Exit_Deamon;    # catch control-c, ...
   $SIG{HUP}  = \&Exit_Deamon;
   $SIG{INT}  = \&Exit_Deamon;
   $SIG{PIPE} = \&Restart_Deamon; # a broken pipe restarts mutellad

   # create handle READER and WRITER to handle STDIN and STDOUT from mutella
   ($READER, $WRITER) = (IO::Handle->new, IO::Handle->new);
   
   &Start_Mutella;

   # Waiting for connections.
   while( accept(CLIENT, SERVER) )
   {
      # get Cmd from client
      $Cmd=<CLIENT>;

      #strip return and space at the beginning and the end
      chomp $Cmd;
      $Cmd =~ s/^[\s]+//;
      $Cmd =~ s/[\s]+$//;
      $Cmd =~ s/[\s]+/ /;

      if ( $Cmd =~ /^exi/ )  
      {
         print CLIENT "$MutellaVersion\n".
                      "exit\n" .
                      " Shut down mutella and mutellad!\n";
                      
         &Exit_Deamon;       # needed for exiting the AutoConAdapt-Process
      }
      elsif ( $Cmd =~ /^restart/ )
      {
         print CLIENT "$MutellaVersion\n".
                      "restart\n".
                      " Restarting mutella and mutellad!\n";

         &Restart_Deamon;    # restart mutella deamon deamon on demand
      }
      elsif ( $Cmd =~ /^dhelp/ ) 
      {
         my ($temp, $Var) = split(/ /, $Cmd , 2);
         if ( $Var ) # everything but not only spaces
         {
            $_ = &ShowDhelp($Var);
         }
      }
      elsif ( $Cmd =~ /^dset/ ) 
      {
         my ($temp, $Var, $Value) = split(/ /, $Cmd , 3);
         if ( $Var ) # everything but not only spaces
         {
            $_ = &ChangeDeamonSettings($Var, $Value);
         }
         else
         {
            $_ = &ShowDSet;   # Show complete Settings of the Deamon.
         }
      }
      else
      {
         $_ = &Send_And_Receive($Cmd);   # send cmd to mutella 
      }
      
      print CLIENT $_;
   }


   # Do closing stuff
   close($READER);
   close($WRITER);
   close(SERVER);
   unlink $SockFile;

   exit;
}



### "AutoAdapt"-Process #######################################################
sub AutoAdaptProcess
{
   # Set RestartDone to true, because when mutellad restarts, it must know that
   # it already has restarted one time.
   # If we have more free disk space in betwen, the MaxDownloads will be raised
   # and the RestartDone will be unset.
   my $RestartDone=1; 
   
   while (1)
   {
      # reload config file
      do $MutelladRC or die "Can't read config file\n";
      
      if ( $UseAutoAdaptMaxConnections eq 'true' )
      {
         # ping host p.e. 10 times with a delay of 10 s between the pings
         $AvPingTime=`ping -i$PingWait -c$PingCount $HostToPing -q 2>/dev/null`;

         # Last line of a typical answer. Maybe depends on the ping programm.
         # round-trip min/avg/max/mdev = 74.657/74.657/74.657/0.000 ms
         $AvPingTime =~ s!.*/([\d]+).*/.*/.*ms.*!$1!s;   # cut the average

         
         #print "-->> $AvPingTime\n"; #debug
         if ( $AvPingTime )
         {
         # Get MaxConnections from mutella, because a user maybe has
         # configured MaxConnections in between.
         foreach ( &InterProcessCom("set MaxConnections") )
         {
            # get value from "MaxConnections = (xx)"
            if ( $_ =~ /MaxConnections = ([0-9]+)/ )
            {
               $MaxCon=$1;
               last;
            }
         }
        
         if ( $AvPingTime < $PingTimeIncSet && 
              $MaxCon < $MaxConnectionsIncSet )
         {
            &Adjust($AdjustIncSet);
         }
         elsif ( $AvPingTime > $PingTimeDecSet1 && 
                 $MaxCon > $MaxConnectionsDecSet1 )
         {
            &Adjust($AdjustDecSet1);
         }
         elsif ( $AvPingTime > $PingTimeDecSet2 &&
                 $MaxCon > $MaxConnectionsDecSet2 )
         {
            &Adjust($AdjustDecSet2);
         }
         elsif ( $AvPingTime > $PingTimeDecSet3 &&
                 $MaxCon > $MaxConnectionsDecSet3 )
         {
            &Adjust($AdjustDecSet3);
         }
         }
         else 
         {
            &Debug("\n". (localtime) . "\nCan't get AvPingTime ;(.");
         }
      }
      
      
      if ( $UseAutoAdaptHDSpace eq "true")
      {
         # Get the "df $DownloadPath" Output.
         my $df=`df $DownloadPath 2>/dev/null`;

         # The "df output" maybe depends on the df programm.
         # $ df /share/mutella
         # Filesystem           1k-blocks      Used Available Use% Mounted on
         # /dev/hdc1              6126235   4652918   1156001  81% /
         $df =~ s!.*[\s]+([\d]+)[\s]+\d+%.*!$1!s;  # cut available

         # get MaxConnections from mutella.
         # Maybe a user has configured MaxDownloads in between.
         # remember, the first line in the answer is the version of mutella 
         my $MaxDownloads;
         foreach ( &InterProcessCom("set MaxDownloads") )   # send request 
         {
            # get value from "MaxDownloads = (xx)"
            if ( $_ =~ /MaxDownloads = ([-\d]+)/ )
            {
               $MaxDownloads=$1;
               last;
            }
         }
         
         my $NewMaxDownloads;
         # If free disk space is greater then FreeSpaceBound, set the 
         # MaxDownloads to 20.
         # If free disk space is lower then MinFreeSpace, set MaxDownload to 0.
         # Between these bounds calculate a linear reduce of MaxDownloads.
         if ( $df > $FreeSpaceBound )
         {
            $NewMaxDownloads = 20;   # this are the absolute maxDownloads
         }
         elsif ( $df < $MinFreeSpace )
         {
            $NewMaxDownloads = 0; # this is the absolute 
         }
         else
         {
            $NewMaxDownloads = int (($df - $MinFreeSpace) * $MaxDownloads / 
                                    ($FreeSpaceBound - $MinFreeSpace ));
         }
         
         &Debug("\n". (localtime) . "\n" . 
                "df = $df, " .
                "MaxDownloads = $MaxDownloads, ".
                "NewMaxDownloads = $NewMaxDownloads");
         
         # If MaxDownloads have changed, send them to mutellad.
         if ($MaxDownloads != $NewMaxDownloads )
         {
            # send request 
            &InterProcessCom("set MaxDownloads $NewMaxDownloads");
            undef $RestartDone;
         }
         elsif ($NewMaxDownloads == 0 && $MaxDownloads == 0 && ! $RestartDone )
         {
            &Debug("\nRestarting mutellad, to be save that no download is running any more.\n");
            $RestartDone = 1;
            &InterProcessCom("restart");    # send request 
         }
         else
         {
            &Debug("\n");    # beautify output
         }
      }

      sleep ($PingWait*$PingCount) if ($UseAutoAdaptMaxConnections eq "false");
   }


   ############################################################################
   ### Subroutines for "AutoAdaptProcess"
   ############################################################################
   sub InterProcessCom
   {
      my $CMD = shift;
      chomp $CMD;

      socket(SOCKET, PF_UNIX, SOCK_STREAM, 0)
         or die "\n$0 Can't connect to Socket\n";
      connect(SOCKET, sockaddr_un("$SockFile"))
         or die  "Bind to Socket failed\n";

      # unbuffered output of SOCKET. Very important!
      select(SOCKET); $| = 1;
      select(STDOUT);
      
      print SOCKET "$CMD\n";  # send request 
      @_ = <SOCKET>;          # catch response
      close (SOCKET);
      
      foreach ( @_ )
      {
         $_ = &RemoveAnsiColor($_);
      }
      
      return @_;
   }


   sub Adjust
   {
      # calculate new MaxConnections to send to muella
      $_ = shift;
      my $NewMaxCon = $MaxCon + $_;
      
      &Debug("\n". (localtime) . "\n" . 
            "AvPingTime = $AvPingTime, MaxCon = $MaxCon, ".
            "# = $_, NewMaxCon = $NewMaxCon");
      
      &InterProcessCom("set MaxConnections $NewMaxCon");  # send request 
   }
}

### End of Main-Subroutines ###################################################
###############################################################################



###############################################################################
### Subroutines for "RunDeamonProcess"
###############################################################################

sub ChangeDeamonSettings
{
   my $Var = shift;
   my $Value = shift;
   my $output;
   
   &Debug("\nmutellad < $Cmd");
   
   for (my $i=0; $#Settings; $i=$i+3)
   {
      if ( $Var eq $Settings[$i] )
      {
         if( $Value =~ /$Settings[$i+1]/)
         {
            $$Var = $Value;
            $output = "\"$MutelladRC\" file written!" if ( &WriteMutelladRC );
         }
         else
         {
            $output = "Failed to parse '$Value'!";
         }
         last;
      }   
   }
   
   &Debug("\nmutellad > $output\n");
   
   return(&AddMutellaVersion(" dset $Var $Value\n$output"));
}


sub Start_Mutella
{
   # start mutella and associate READER and WRITER with STDIN and STDOUT
   $MutellaPID = open2( $READER, $WRITER, $PathToMutella );
   
   if ( ! $MutellaPID )
   {
      # mutella couldn't be started
      &KillAutoAdaptProcess;
      die "Could not start mutella!\n";
   }
   
   &Debug("\nStarting on PID $MutellaPID: Mutella\n\n");

   # Drop Mutella's starting message until mutella prompt "\n>"
   while ( ( sysread ($READER, $Char, 1) ) && ($Char ne '>' ) )
   {
      $MutellaVersion .= $Char;
   }

   &Debug(&RemoveAnsiColor($MutellaVersion));

   # filter Mutella's Version number
   if ( $MutellaVersion !~ s/.* v([\d\.a-z]+).*/$1/s )
   {
      $MutellaVersion = &Send_And_Receive("version");
      $MutellaVersion =~ s/.* v([\d\.a-z]+).*/$1/s ;
   }
  
   # disable Paginate 
   &Send_And_Receive("set Paginate false");
}


sub Restart_Deamon
{
   &Do_Closing_Stuff;
   
   warn "\nRestarting mutella and mutellad!\n\n";
   exec($0, $CmdLine ) or die "FAILED!\n";
}


sub Exit_Deamon
{
   # Reset SignalHandler to itself
   $SIG{TERM} = \&Exit_Deamon;
   $SIG{HUP}  = \&Exit_Deamon;
   $SIG{INT}  = \&Exit_Deamon;
   
   &Do_Closing_Stuff;
   
   warn "\nShut down mutella and mutellad!\n\n";
   exit;
}


sub KillAutoAdaptProcess
{
   &Debug("\nKilling PID $AutoAdaptPID: AutoAdaptProcess\n");
   kill 'INT' => $AutoAdaptPID;
}


sub Do_Closing_Stuff
{
   # killing the AutoAdaptProcess is necessary !!!
   &KillAutoAdaptProcess;
   
   $SIG{CHLD} = 'IGNORE';         # We are not interested in dead Childs
   $SIG{PIPE} = 'IGNORE';         # Disable PIPE-Handler
   
   # Send "exit" to mutella.
   # If we press Ctrl-C in debug mode, we won't get an answer from mutella, 
   # because the shell sends the INT sig to all connectet proceses, i.e. 
   # mutellad an mutella. So we can't exit mutella with saving :(
   # Sending kill -INT works fine!
   &Send_And_Receive("exit");
   
   # Do closing stuff
   close(SERVER);
   close($READER);
   close($WRITER);
   unlink $SockFile;
}


sub Send_And_Receive
{
   # get Cmd from client
   my $Cmd = (shift) . "\n";
      
   # Do normal conversation with mutella.
   # send Cmd to mutella
   print $WRITER $Cmd;
   &Debug("\nmutella < $Cmd");
   
   # get answer from mutella
   my $Answer = "";       # the return-string of this routine
   my $Char = "";         # read char from mutella's answer
   my $HavePrompt = 0;
   
   # read char by char until mutella prompt "\nESC-Seq>", then stop
   while( sysread ($READER, $Char, 1) )
   {
      
      # build answer char by char
      $Answer .= $Char;
  
      # the first prompt looks like : "\n> ", u see, there's no \n in.
      
      # a typical ESC Sequence Prompt looks like: 
      # 10 27  91 50 59 51 55 59 48 109 62 32
      # \n ESC [  2  ;  3  7  ;  0  m   >  space
      
      # if prompt is received do 
      # - exit while and 
      # - cut "\n> " from last line of the answer, so we get the color tag. 
      
      # Only test the Answer if it matches the prompt, if Char is ">". 
      # This is much faster then testing the whole answer after each Char.
      if( $Char eq ">" )
      {
         $HavePrompt = 1 if( $Answer =~ s/\n([\x1b\[2;37;0m]*)>/$1/sg );
      }
      
      # Only for heavy debug needed. These lines should be commented out.
      #$Char = "ESC" if ( $Char =~ /\x1b/ );
      #&Debug($Char);

      last if ($HavePrompt == 1);
   }
   
   # debug received answer from mutella
   &Debug("mutella > Answering ".length(&RemoveAnsiColor($Answer))." bytes.\n");
   #&Debug("---------------------------------------------------------------\n");
   
   return (&AddMutellaVersion($Answer));
}


sub AddMutellaVersion
{
   $_ = shift;
   # add the Version of mutella to the first line of the answer.
   # Muwi needs to know the version of mutella to disable some functions. 
   # This is nececcary if muwi is running with an older mutella. 
   return ("$MutellaVersion\n$_");
} 


sub ShowDhelp
{
   # get help out of the Settings an return it.
   my $Var = shift;
   my $HelpFound = "-1"; 
   my $returntext = "";

   &Debug("\nmutellad < $Cmd");
   
   for (my $i=0; $#Settings; $i=$i+3)
   {
      if ( $Var eq $Settings[$i] )
      {
         $HelpFound = $i;
         last;
      }
   }

   if ( $HelpFound != -1 )
   {
      $_ = "Help on '$Var' found!";
      $returntext = $Settings[$HelpFound+2];
   }
   else
   {
      $_ = "No help found!";
      $returntext = "Sorry, no help found!";
   }
  
   &Debug("\nmutellad > $_\n");
   
   return(&AddMutellaVersion(" dhelp $Var\n$returntext\n"));
}


sub ShowDSet
{
   my $Answer = " dset\n";
   open(IN, "< $MutelladRC");
   foreach (<IN>)
   {
      chomp $_;
      next if ( $_ =~ /^# / ); # ignore comment lines "# "
      next if ( $_ eq "");     # ignore empty lines
      $_ =~ s/^#//;  # strip leading "#"
      $_ =~ s/;//;   # strip ";"
      $_ =~ s/\$//;  # strip "$"
      $_ =~ s/\@//;  # strip "$"
      
      $Answer .= "$_\n";
   }
   close(IN);

   return (&AddMutellaVersion($Answer));
}


sub WriteMutelladRC
{
   open(OUT, "> $MutelladRC");

   print OUT <<EOCF;
\# 
\# This is the rc file for "mutellad" and "muwi", the mutella wrapper
\# and web interface.
\# 
\# You have to use perl syntax!!!
\# 
\# Maybe it is neccessary to make the file world readable cause of muwi.

\#[ Global Settings ]
\# talk-socket: muwi <-> mutellad
                      \$SockFile = '$SockFile'; 

\#[ Mutellad Settings ]
                 \$PathToMutella = '$PathToMutella';

\#[ Mutellad AutoAdaptMaxConnections Settings ]
\# Mutellad can calculate best "MaxConnections" based on latency time meassured.
    \$UseAutoAdaptMaxConnections = '$UseAutoAdaptMaxConnections';

\# A host near to you, maybe your DNS.
                    \$HostToPing = '$HostToPing';

\# Seconds to wait between each ping.
                      \$PingWait = '$PingWait';

\# Pings to send, before getting the average.
                     \$PingCount = '$PingCount';

\# Define 4 Sets of Rules ( PingTime, MaxCon, Adjust)
\# Add connections.
                \$PingTimeIncSet = '$PingTimeIncSet';
          \$MaxConnectionsIncSet = '$MaxConnectionsIncSet';
                  \$AdjustIncSet = '$AdjustIncSet';
\# Reduce connections.
               \$PingTimeDecSet1 = '$PingTimeDecSet1';
         \$MaxConnectionsDecSet1 = '$MaxConnectionsDecSet1';
                 \$AdjustDecSet1 = '$AdjustDecSet1';
               \$PingTimeDecSet2 = '$PingTimeDecSet2';
         \$MaxConnectionsDecSet2 = '$MaxConnectionsDecSet2';
                 \$AdjustDecSet2 = '$AdjustDecSet2';
               \$PingTimeDecSet3 = '$PingTimeDecSet3';
         \$MaxConnectionsDecSet3 = '$MaxConnectionsDecSet3';
                 \$AdjustDecSet3 = '$AdjustDecSet3';

\#[ Mutellad AutoAdaptHDSpace Settings ]
\# Mutellad can calculate the "MaxDownloads" (max. 20) based on free disk space.
\# If the free disk space is higher then the FreeSpaceBound, no adaption will 
\# be made. Else linear reduceing of the MaxDownloads will be calulated.
           \$UseAutoAdaptHDSpace = '$UseAutoAdaptHDSpace';
                \$FreeSpaceBound = '$FreeSpaceBound';
                  \$MinFreeSpace = '$MinFreeSpace';

\#[ Muwi Settings ]
\# Define the default RepeatCommand and the RepeatTime for muwi   
                 \$RepeatCommand = '$RepeatCommand';
                    \$RepeatTime = '$RepeatTime'; 

\# For no icon change variable to "".
                   \$FaviconPath = '$FaviconPath';

\# Path to show in Partial or Finished.
                  \$DownloadPath = '$DownloadPath';

\# Ignore or show Events in HTML Page.
                    \$ShowEvents = '$ShowEvents';

\# Change the colors in the HTML Page if you want.
\# floralwhite     "#fffaf0"
                   \$PageBGColor = '$PageBGColor';
\# gainsboro       "#dcdcdc"
                   \$MenuBGColor = '$MenuBGColor';
\# darkgray        "#a9a9a9"
                  \$MenuBrdColor = '$MenuBrdColor';
\# lightslategray  "#778899"
                      \$CmdColor = '$CmdColor';
\# lightsteelblue  "#b0c4de"
                  \$SectionColor = '$SectionColor';
\# lightgrey with "e" "#d3d3d3"  
                    \$LineColor1 = '$LineColor1'; 
\# whitesmoke      "#f5f5f5"
                    \$LineColor2 = '$LineColor2';
\# silver          "#c0c0c0"
                    \$TotalColor = '$TotalColor';

EOCF
   close (OUT);

}


sub RemoveAnsiColor
{
   $_ = shift;
   $_ =~ s/\x1b\[[;\d\w]+?m//g; # remove ansi color from output
   return $_;
}


sub Debug
{
   print shift if ( $debug );
}

