#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&setALTSParameter &getALTSParameter);

if(( $ARGV[0] ne "") && ( $ARGV[1] ne ""))
{
	setALTSParameter($ARGV[0],$ARGV[1]);
	print "$ARGV[0] Parameter modified To ".getALTSParameter($ARGV[0])."\n";
}
else
{
print "Usage: ./setALTSParameter.pl <Parameter_name> <Parameter_Value>\nE.g: ./setALTSParameter.pl TestModePossible 0\n\n";
}
