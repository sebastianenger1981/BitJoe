#!/usr/bin/perl -I/server/mutella/MutellaProxy

use MutellaProxy::Gzip;
my $GZIP = MutellaProxy::Gzip->new();

#gzip_compress
#gzip_decompress

$file_to_compress		= "test.txt";







sub DoStingCompress(){

	my $string_to_compress = shift;

	my $compressed_string;
	my $LoopCount = 0;

	do {
		
		return 0 if ( $LoopCount >= 10 );
		$compressed_string = $GZIP->gzip_compress_string( $string_to_compress );
		$LoopCount++;

	} until ( $compressed_string != -1 );

	return $compressed_string;

}; # sub DoFileCompress(){





sub DoFileDeCompress(){

	my $decompressed_filename;
	my $LoopCount = 0;

	my $compressed_filename = shift;

	do {
		
		return 0 if ( $LoopCount >= 10 );
		$decompressed_filename = $GZIP->gzip_decompress( $compressed_filename );
		$LoopCount++;

	} until ( $decompressed_filename != -1 );

	return $decompressed_filename;

}; # sub DoFileCompress(){





sub DoFileCompress(){

	my $compressed_filename;
	my $LoopCount = 0;

	my $file_to_compress = shift;

	do {
		
		return 0 if ( $LoopCount >= 10 );
		$compressed_filename = $GZIP->gzip_compress( $file_to_compress );
		$LoopCount++;

	} until ( $compressed_filename != -1 );

	return $compressed_filename;

}; # sub DoFileCompress(){
