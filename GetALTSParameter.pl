#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&setALTSParameter &getALTSParameter);

my @P=("TestModePossible","ShowHints","GradeOnlyAfterBreak");

if ( $ARGV[0] eq "ALL")
{
	foreach my $p (@P)
	{
		print "$p=".getALTSParameter($p)."\n";
	}
exit 2;
}

if( $ARGV[0] ne "")
{	
	my $Value=getALTSParameter($ARGV[0]);
	if ($Value  eq -1) { print "UNDEF"; exit 1; }
	print "$Value";
	exit 0;
}
else
{
	print "Usage: GetALTSParameter.pl <Parameter_name>|ALL\nE.g: GetALTSParameter.pl TestModePossible\n\n";
	exit 1;
}
