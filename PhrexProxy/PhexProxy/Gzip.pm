#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Patrick Canterino / Sebastian Enger / B.Sc
##### CopyRight:	2003 Patrick Canterino / since 2006 BitJoe GmbH
##### LastModified	11.07.2006
##### Function:		Gzip (De)Compression of Files/Strings
##### Todo:			Testing
########################################

package PhexProxy::Gzip;

use PhexProxy::CryptoLibrary;
use PhexProxy::CheckSum;
use base qw(Exporter);
# use Compress::Zlib;
use PhexProxy::IO;
use strict;

my $VERSION = '0.10';

use vars qw( @EXPORT );           #$gzippath 

### Export ###
@EXPORT = qw( gzip_compress_string );

#	gzip_compress
#   gzip_decompress
#	gzip_decompress_string


# Constructor
sub new(){
	
	my $self = bless {}, shift;
	return $self;
		
}; # new()


# Pfad zum GZip-Programm (erreichbar ueber $GZip::gzippath)
my $gzippath = '/bin/gzip';
my $temppath = '/server/phexproxy/tmp';
mkdir $temppath;

# ============================
#  Zugriff mit Compress::Zlib
# ============================

# decompress_string_zlib(): Interne Funktion
# Komprimieren einer GZip-Datei mit Compress::Zlib und lese den Inhalt der Datei in einen Scalar ein und gib den scalar zurück
# Parameter: Zu komprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst den comprimierten string

sub decompress_string_zlib(){

	my $self		= shift;
	my $string		= shift;	# contains String to decompress

	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(8096) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;
	my $file		= PhexProxy::IO->WriteFile("$temppath/gziptostring.$RandString.temp.txt", $string );

	# fehlermeldung, wenn datei nicht steht
	return -1 if(not -e $file || -d $file);

	my $gzfile		= "$file";
	my $gztemp		= "$gzfile.$RandString.temp";
	local *FILE;

	my $gz			= Compress::Zlib::gzopen($gzfile,"rb") or return -1;
	my $content;

	# Datei anlegen und GZip-Datei stueckchenweise dekomprimieren
	open(FILE,">$gztemp") or return -1;
		flock(FILE, 2);
		binmode(FILE);
		print FILE $content while($gz->gzread($content) > 0);
		$gz->gzclose;
	close(FILE) or do { unlink($gztemp); return -1};

	# Datei umbenennen
	rename($gztemp,$gzfile) and unlink($gztemp);

	my $ContentScalar = PhexProxy::IO->ReadFileIntoScalar( $gzfile );
	unlink $gzfile; unlink $gztemp;

	return ${$ContentScalar};

}; # sub decompress_string(){



# compress_string_zlib(): Interne Funktion
# Komprimieren einer GZip-Datei mit Compress::Zlib und lese den Inhalt der Datei in einen Scalar ein und gib den scalar zurück
# Parameter: Zu komprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst den comprimierten string

sub compress_string_zlib(){

	my $self		= shift;
	my $string		= shift;	# contains String to compress

	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(8096) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;
	my $file		= PhexProxy::IO->WriteFile("$temppath/gziptostring.$RandString.temp.txt", $string );

	# fehlermeldung, wenn datei nicht steht
	#return -1 if(not -e $file || -d $file);

	#print "$file doestn exits\n";
	
	my $gzfile		= "$file.gz";
	my $gztemp		= "$gzfile.$RandString.temp";

	# Daten komprimieren
	my $gz = Compress::Zlib::gzopen($gztemp,"wb") or die; #return -1;
	$gz->gzwrite($string) or do { $gz->gzclose; unlink($gztemp); return -1; };
	$gz->gzclose;

	# Datei umbenennen
	rename($gztemp,$gzfile) and unlink($gztemp);

	my $ContentScalar = PhexProxy::IO->ReadFileIntoScalar( $gzfile );
	unlink $gzfile; unlink $gztemp;

	return ${$ContentScalar};

}; # sub compress_string(){

# compress_zlib(): Interne Funktion
# Komprimieren einer GZip-Datei mit Compress::Zlib
# Parameter: Zu komprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst Dateinamen

sub compress_zlib(){

	my $self		= shift;
	my $file		= shift;

	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(8096) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;

	my $gzfile		= "$temppath/$file.gz";
	my $gztemp		= "$temppath/$gzfile.$RandString.temp";
	local *FILE;

	return -1 if(not -e $file || -d $file);

	# Datei auslesen
	open(FILE,"<$file") or return -1;
		flock(FILE, 2);
		binmode(FILE);
		read(FILE, my $content, -s $file);
	close(FILE) or return -1;

	# Daten komprimieren
	my $gz = Compress::Zlib::gzopen($gztemp,"wb") or return -1;
	$gz->gzwrite($content)                        or do { $gz->gzclose; unlink($gztemp); return -1; };
	$gz->gzclose;

	# Datei umbenennen
	rename($gztemp,$gzfile) and unlink($gztemp) and return $gzfile;

	# Mist
	unlink($gztemp);
	return -1;

}; # sub compress_zlib(){


# decompress_zlib(): Interne Funktion
# Dekomprimieren einer GZip-Datei mit Compress::Zlib
# Parameter: Zu dekomprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst Dateinamen

sub decompress_zlib(){
	
	my $self		= shift;
	my $gzfile		= shift;
	
	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(100) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;

	my $file		= "$temppath/$gzfile"; $file =~ s/\.gz$//i;
	my $tempfile	= "$temppath/$file.$RandString.temp";
	local *FILE;

	return -1 if(not -e $gzfile || -d $gzfile);

	my $content;

	my $gz			= Compress::Zlib::gzopen($gzfile,"rb") or return -1;

	# Datei anlegen und GZip-Datei stueckchenweise dekomprimieren
	open(FILE,">$tempfile") or return -1;
		flock(FILE, 2);
		binmode(FILE);
		print FILE $content while($gz->gzread($content) > 0);
		$gz->gzclose;
	close(FILE) or do { unlink($tempfile); return -1};

	# Datei umbenennen
	rename($tempfile,$file) and unlink($tempfile) and return $file;

	# Mist
	unlink($tempfile);
	return -1;

}; # sub decompress_zlib(){



# ===============================
#  Zugriff mit dem gzip-Programm
# ===============================



# compress_gzipprog(): Interne Funktion
# Komprimieren einer GZip-Datei mit dem gzip-Programm
# (Pfad des gzip-Programmes in $Gzip::gzippath)
# Parameter: Zu komprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst Dateinamen

sub compress_gzipprog(){
	
	my $self		= shift;
	my $file		= shift;

	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(100) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;

	my $gzfile		= "$temppath/$file.gz";
	my $gztemp		= "$temppath/$gzfile.$RandString.temp";

	return -1 if(not -e $gzippath || -d $gzippath);
	return -1 if(not -e $file     || -d $file);

	my $command		= "$gzippath -9 -q -f -c $file >$gztemp";

	# Unter Windows die Slashes durch Backslashes ersetzen
	$command		=~ tr!/!\\! if($^O =~ /Win32/i);

	# gzip ausfuehren und sofort pruefen,
	# ob es 0 zurueckgegeben hat (0 = Erfolg)

	if(system($command) == 0){
		# Datei umbenennen
		rename($gztemp,$gzfile) and unlink($gztemp) and return $gzfile;
	};

	# Mist
	unlink($gztemp);
	return -1;

}; # sub compress_gzipprog(){


# decompress_gzipprog()
# Dekomprimieren einer GZip-Datei mit dem gzip-Programm
# (Pfad des gzip-Programmes in $Gzip::gzippath)
# Parameter: Zu dekomprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst Dateinamen

sub decompress_gzipprog(){
	
	my $self		= shift;
	my $gzfile		= shift;
	
	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(100) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;


	my $file		= "$gzfile"; $file =~ s/\.gz$//i;
	my $tempfile	= "$file.$RandString.temp";

	return -1 if(not -e $gzippath || -d $gzippath);
	return -1 if(not -e $gzfile   || -d $gzfile);

	my $command		= "$gzippath -q -f -cd $gzfile >$tempfile";

	# Unter Windows die Slashes durch Backslashes ersetzen
	$command		=~ tr!/!\\! if($^O =~ /Win32/i);

	# gzip ausfuehren und sofort pruefen,
	# ob es 0 zurueckgegeben hat (0 = Erfolg)

	if(system($command) == 0){
		# Datei umbenennen
		rename($tempfile,$file) and unlink($tempfile) and return $file;
	};

	# Mist
	unlink($tempfile);
	return -1;

}; # sub decompress_gzipprog(){


# compress_gzipprog(): Interne Funktion
# Komprimieren einer GZip-Datei mit dem gzip-Programm und lese den Inhalt der Datei in einen Scalar ein und gib den scalar zurück
# (Pfad des gzip-Programmes in $Gzip::gzippath)
# Parameter: Zu komprimierende Datei
# Rueckgabe: Status-Code (Boolean) -1 Im Fehlerfall sonst den comprimierten string

sub compress_string_gzipprog(){
	
	my $self		= shift;
	my $string		= shift;

	my $URandom		= PhexProxy::CryptoLibrary->URandom( rand(8096) );
	my $URandomMD5	= PhexProxy::CheckSum->MD5ToHEX( \$URandom ); 
	my $RandString	= time() . $URandomMD5;
	my $file		= PhexProxy::IO->WriteFile("$temppath/gziptostring.$RandString.temp.txt", $string );

	my $gzfile		= "$file.gz";
	my $gztemp		= "$gzfile.$RandString.temp";

	return -1 if(not -e $gzippath || -d $gzippath);
	return -1 if(not -e $file     || -d $file);

	my $command		= "$gzippath -9 -q -f -c $file >$gztemp";

	# Unter Windows die Slashes durch Backslashes ersetzen
	$command		=~ tr!/!\\! if($^O =~ /Win32/i);

	# gzip ausfuehren und sofort pruefen,
	# ob es 0 zurueckgegeben hat (0 = Erfolg)

	if(system($command) == 0){
		# Datei umbenennen
		rename($gztemp,$gzfile) and unlink($gztemp);
	};

	my $ContentScalar = PhexProxy::IO->ReadFileIntoScalar( $gzfile );
	unlink $gzfile;

	return ${$ContentScalar};

}; # sub compress_gzipprog(){


# =========================
#  Zuweisen der Funktionen
# =========================

BEGIN {
#	if(eval{ local $SIG{'__DIE__'}; require Compress::Zlib; 1 }){
#		*gzip_compress			= \&compress_zlib;
#		*gzip_decompress		= \&decompress_zlib;
#		*gzip_compress_string	= \&compress_string_zlib;
#		*gzip_decompress_string = \&decompress_string_zlib;
#	} else {
		*gzip_compress			= \&compress_gzipprog;
		*gzip_decompress		= \&decompress_gzipprog;
		*gzip_compress_string	= \&compress_string_gzipprog;
#		*gzip_decompress_string = \&decompress_string_zlib;
#	};

};# BEGIN

# it's true, baby ;-)

1;

#
### Ende ###

return 1;