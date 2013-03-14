#!/usr/bin/perl


use lib '/scripts/common_perl/';
use Framework qw(&decryptFile);

print decryptFile($ARGV[0]);
