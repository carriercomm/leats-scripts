#!/usr/bin/perl


use strict;
use warnings;
use MIME::Base64;
use Crypt::Tea;
use Crypt::Random;

use lib '/scripts/common_perl/';
use Framework qw(&decryptFile);


my $AESKeyFile="/ALTS/SECURITY/ALTSkey";
my $Tmpfile="/tmp/abcd1234";

 my $File = $ARGV[0];
 if (!(-f $AESKeyFile)) { print "$AESKeyFile is unreachable!\n"; die; }
 print "Decrypting $File...\n";
 system("cat $File | openssl aes-256-cbc -d -a -pass file:$AESKeyFile > $Tmpfile");


print "\n\n".decryptFile("$Tmpfile")."\n\n";
system("rm -rf $Tmpfile");
