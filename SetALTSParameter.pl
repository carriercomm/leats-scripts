#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&setALTSParameter &getALTSParameter);

my @P=("TestModePossible","ShowHints","GradeOnlyAfterBreak");

if(( $ARGV[0] ne "") && ( $ARGV[1] ne ""))
{
	if ( $ARGV[0] ~~ @P)
	{
		setALTSParameter($ARGV[0],$ARGV[1]);
		print "$ARGV[0] Parameter modified To ".getALTSParameter($ARGV[0])."\n";
	}
	else
	{
		print "Unknown ALTS Parameter (Valid Paramters are: @P\n\n";	
	}
}
else
{
	print "Usage: ./SetALTSParameter.pl <Parameter_name> <Parameter_Value>\nE.g: ./SetALTSParameter.pl TestModePossible 0\n\n";
}
