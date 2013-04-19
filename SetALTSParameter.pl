#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&setALTSParameter &getALTSParameter);

my @P=("TestModePossible","ShowHints","GradeOnlyAfterBreak");

if(($ARGV[0] eq "clear"))
{
	print "Clear the unnecessary parameters..\n";
	setALTSParameter("clear","");
	exit 0;
}

if(( $ARGV[0] ne "") && ( $ARGV[1] ne ""))
{
	if ( $ARGV[0] ~~ @P)
	{
		setALTSParameter($ARGV[0],$ARGV[1]);
		print "$ARGV[0] Parameter modified To ".getALTSParameter($ARGV[0])."\n";
	}
	else
	{
		setALTSParameter($ARGV[0],$ARGV[1]);
		print "$ARGV[0] Exercise specific Parameter modified To ".getALTSParameter($ARGV[0])."\n";
	}
}
else
{
	print "\nUsage: \n./SetALTSParameter.pl <Parameter_name> <Parameter_Value>\n./SetALTSParameter.pl clear  -> Clear all unnecessary parameters\nE.g: ./SetALTSParameter.pl TestModePossible 0\n\n";
}
