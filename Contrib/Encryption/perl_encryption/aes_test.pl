#!/usr/bin/perl -Imodules

use Crypt::CBC;
$cipher = Crypt::CBC->new( -key    => 'my secret key',
                           -cipher => 'Blowfish_PP',
                           -salt   => 1,
                          );

$ciphertext = $cipher->encrypt("Th");
$plaintext = $cipher->decrypt($ciphertext);

print "$ciphertext und '$plaintext'\n";

$cipher->start('encrypting');
open(F,"./BIG_FILE");
while (read(F,$buffer,1024)) {
  print $cipher->crypt($buffer);
}
print $cipher->finish;