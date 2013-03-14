#!/usr/bin/perl


use lib '/scripts/common_perl/';
use Framework qw(&encryptFile);

print encryptFile($ARGV[0]);
