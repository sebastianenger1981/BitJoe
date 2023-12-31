use 5.008;
use ExtUtils::MakeMaker;

# we need libSSH2; check for it, if missing, try to install it
use Cwd;
use Config;

# Windows, as usual, is a special case
my $win32 = ($^O eq 'MSWin32');
my @define = $win32 ? (DEFINE => '-DLIBSSH2_WIN32') : ();

# override library and include directory here if desired
my $lib = '';
my $inc = '';

# try to find libSSH2 if we're not given a location
unless($lib and $inc) {
    for my $prefix($Config{siteprefixexp},$Config{prefixexp},
     '/usr','/usr/local','/opt') {
        $lib ||= "$prefix/lib"
         if -f "$prefix/lib/libssh2$Config{_a}" or
            -f "$prefix/lib/libssh2.$Config{so}";
        $inc ||= "$prefix/include"
         if -f "$prefix/include/libssh2.h";
        last if $lib and $inc;
    }
}

unless ($lib and $inc) {
    my $missing = join ' or ', $lib ? () : 'libssh2', $inc ? () : 'libssh2.h';
    print <<ERROR;
I can't find $missing.

Either libSSH2 is not installed, or it is installed incorrectly.  LibSSH2 is
required by Net::SSH2.  You can download it from http://www.libssh2.org; you
may also need OpenSSL, which can be obtained from http://www.openssl.org.

ERROR
    die "Quitting since I can't find $missing";
}

$lib = "-L$lib -lssh2";
$inc = "-I$inc";
print "Net::SSH2: using library $lib and include path $inc.\n";

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Net::SSH2',
    VERSION_FROM      => 'lib/Net/SSH2.pm', # finds $VERSION
    PREREQ_PM         => {
                            'Socket'            => 0,
                            'IO::File'          => 0,
                            'File::Basename'    => 0,
                         },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Net/SSH2.pm', # retrieve abstract from module
       AUTHOR         => 'David B. Robins <dbrobins@cpan.org>') : ()),
    LIBS              => [$lib],
    INC               => "$inc -I.",
    @define,
);
if  (eval {require ExtUtils::Constant; 1}) {
  # If you edit these definitions to change the constants used by this module,
  # you will need to use the generated const-c.inc and const-xs.inc
  # files to replace their "fallback" counterparts before distributing your
  # changes.
  my @names = (qw(
     LIBSSH2_CALLBACK_DEBUG
     LIBSSH2_CALLBACK_DISCONNECT LIBSSH2_CALLBACK_IGNORE
     LIBSSH2_CALLBACK_MACERROR LIBSSH2_CALLBACK_X11
     LIBSSH2_CHANNEL_EXTENDED_DATA_IGNORE
     LIBSSH2_CHANNEL_EXTENDED_DATA_MERGE
     LIBSSH2_CHANNEL_EXTENDED_DATA_NORMAL LIBSSH2_CHANNEL_FLUSH_ALL
     LIBSSH2_CHANNEL_FLUSH_EXTENDED_DATA LIBSSH2_CHANNEL_MINADJUST
     LIBSSH2_CHANNEL_PACKET_DEFAULT LIBSSH2_CHANNEL_WINDOW_DEFAULT
     LIBSSH2_DH_GEX_MAXGROUP LIBSSH2_DH_GEX_MINGROUP
     LIBSSH2_DH_GEX_OPTGROUP LIBSSH2_ERROR_ALLOC
     LIBSSH2_ERROR_BANNER_NONE LIBSSH2_ERROR_BANNER_SEND
     LIBSSH2_ERROR_CHANNEL_CLOSED LIBSSH2_ERROR_CHANNEL_EOF_SENT
     LIBSSH2_ERROR_CHANNEL_FAILURE LIBSSH2_ERROR_CHANNEL_OUTOFORDER
     LIBSSH2_ERROR_CHANNEL_PACKET_EXCEEDED
     LIBSSH2_ERROR_CHANNEL_REQUEST_DENIED
     LIBSSH2_ERROR_CHANNEL_UNKNOWN
     LIBSSH2_ERROR_CHANNEL_WINDOW_EXCEEDED LIBSSH2_ERROR_DECRYPT
     LIBSSH2_ERROR_FILE LIBSSH2_ERROR_HOSTKEY_INIT
     LIBSSH2_ERROR_HOSTKEY_SIGN LIBSSH2_ERROR_INVAL
     LIBSSH2_ERROR_INVALID_MAC LIBSSH2_ERROR_INVALID_POLL_TYPE
     LIBSSH2_ERROR_KEX_FAILURE LIBSSH2_ERROR_KEY_EXCHANGE_FAILURE
     LIBSSH2_ERROR_METHOD_NONE LIBSSH2_ERROR_METHOD_NOT_SUPPORTED
     LIBSSH2_ERROR_PASSWORD_EXPIRED LIBSSH2_ERROR_PROTO
     LIBSSH2_ERROR_PUBLICKEY_UNRECOGNIZED
     LIBSSH2_ERROR_PUBLICKEY_UNVERIFIED
     LIBSSH2_ERROR_REQUEST_DENIED LIBSSH2_ERROR_SCP_PROTOCOL
		 LIBSSH2_ERROR_PUBLICKEY_PROTOCOL
     LIBSSH2_ERROR_SFTP_PROTOCOL LIBSSH2_ERROR_SOCKET_DISCONNECT
     LIBSSH2_ERROR_SOCKET_NONE LIBSSH2_ERROR_SOCKET_SEND
     LIBSSH2_ERROR_SOCKET_TIMEOUT LIBSSH2_ERROR_TIMEOUT
     LIBSSH2_ERROR_ZLIB LIBSSH2_FLAG_SIGPIPE LIBSSH2_FXF_APPEND
     LIBSSH2_FXF_CREAT LIBSSH2_FXF_EXCL LIBSSH2_FXF_READ
     LIBSSH2_FXF_TRUNC LIBSSH2_FXF_WRITE LIBSSH2_FX_BAD_MESSAGE
     LIBSSH2_FX_CONNECTION_LOST LIBSSH2_FX_DIR_NOT_EMPTY
     LIBSSH2_FX_EOF LIBSSH2_FX_FAILURE
     LIBSSH2_FX_FILE_ALREADY_EXISTS LIBSSH2_FX_INVALID_FILENAME
     LIBSSH2_FX_INVALID_HANDLE LIBSSH2_FX_LINK_LOOP
     LIBSSH2_FX_LOCK_CONFlICT LIBSSH2_FX_NOT_A_DIRECTORY
     LIBSSH2_FX_NO_CONNECTION LIBSSH2_FX_NO_MEDIA
     LIBSSH2_FX_NO_SPACE_ON_FILESYSTEM LIBSSH2_FX_NO_SUCH_FILE
     LIBSSH2_FX_NO_SUCH_PATH LIBSSH2_FX_OK
     LIBSSH2_FX_OP_UNSUPPORTED LIBSSH2_FX_PERMISSION_DENIED
     LIBSSH2_FX_QUOTA_EXCEEDED LIBSSH2_FX_UNKNOWN_PRINCIPLE
     LIBSSH2_FX_WRITE_PROTECT LIBSSH2_H LIBSSH2_HOSTKEY_HASH_MD5
     LIBSSH2_HOSTKEY_HASH_SHA1 LIBSSH2_METHOD_COMP_CS
     LIBSSH2_METHOD_COMP_SC LIBSSH2_METHOD_CRYPT_CS
     LIBSSH2_METHOD_CRYPT_SC LIBSSH2_METHOD_HOSTKEY
     LIBSSH2_METHOD_KEX LIBSSH2_METHOD_LANG_CS
     LIBSSH2_METHOD_LANG_SC LIBSSH2_METHOD_MAC_CS
     LIBSSH2_METHOD_MAC_SC LIBSSH2_PACKET_MAXCOMP
     LIBSSH2_PACKET_MAXDECOMP LIBSSH2_PACKET_MAXPAYLOAD
     LIBSSH2_POLLFD_CHANNEL LIBSSH2_POLLFD_CHANNEL_CLOSED
     LIBSSH2_POLLFD_LISTENER LIBSSH2_POLLFD_LISTENER_CLOSED
     LIBSSH2_POLLFD_POLLERR LIBSSH2_POLLFD_POLLEX
     LIBSSH2_POLLFD_POLLEXT LIBSSH2_POLLFD_POLLHUP
     LIBSSH2_POLLFD_POLLIN LIBSSH2_POLLFD_POLLNVAL
     LIBSSH2_POLLFD_POLLOUT LIBSSH2_POLLFD_POLLPRI
     LIBSSH2_POLLFD_SESSION_CLOSED LIBSSH2_POLLFD_SOCKET
     LIBSSH2_SFTP_ATTR_ACMODTIME LIBSSH2_SFTP_ATTR_EXTENDED
     LIBSSH2_SFTP_ATTR_PERMISSIONS LIBSSH2_SFTP_ATTR_SIZE
     LIBSSH2_SFTP_ATTR_UIDGID LIBSSH2_SFTP_LSTAT
     LIBSSH2_SFTP_OPENDIR LIBSSH2_SFTP_OPENFILE
     LIBSSH2_SFTP_PACKET_MAXLEN LIBSSH2_SFTP_READLINK
     LIBSSH2_SFTP_REALPATH LIBSSH2_SFTP_RENAME_ATOMIC
     LIBSSH2_SFTP_RENAME_NATIVE LIBSSH2_SFTP_RENAME_OVERWRITE
     LIBSSH2_SFTP_SETSTAT LIBSSH2_SFTP_STAT LIBSSH2_SFTP_SYMLINK
     LIBSSH2_SFTP_TYPE_BLOCK_DEVICE LIBSSH2_SFTP_TYPE_CHAR_DEVICE
     LIBSSH2_SFTP_TYPE_DIRECTORY LIBSSH2_SFTP_TYPE_FIFO
     LIBSSH2_SFTP_TYPE_REGULAR LIBSSH2_SFTP_TYPE_SOCKET
     LIBSSH2_SFTP_TYPE_SPECIAL LIBSSH2_SFTP_TYPE_SYMLINK
     LIBSSH2_SFTP_TYPE_UNKNOWN LIBSSH2_SFTP_VERSION
     LIBSSH2_SOCKET_POLL_MAXLOOPS LIBSSH2_SOCKET_POLL_UDELAY
     LIBSSH2_TERM_HEIGHT
     LIBSSH2_TERM_HEIGHT_PX LIBSSH2_TERM_WIDTH
     LIBSSH2_TERM_WIDTH_PX
  ));
  ExtUtils::Constant::WriteConstants(
    NAME         => 'Net::SSH2',
    NAMES        => \@names,
    DEFAULT_TYPE => 'IV',
    C_FILE       => 'const-c.inc',
    XS_FILE      => 'const-xs.inc',
  );

}
else {
  use File::Copy;
  use File::Spec;
  foreach my $file ('const-c.inc', 'const-xs.inc') {
    my $fallback = File::Spec->catfile('fallback', $file);
    copy ($fallback, $file) or die "Can't copy $fallback to $file: $!";
  }
}
