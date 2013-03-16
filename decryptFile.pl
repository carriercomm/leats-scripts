#!/usr/bin/perl


use lib '/scripts/common_perl/';
use Framework qw(&decryptFile);

print "\n\n".decryptFile($ARGV[0])."\n\n\n";
