#!/usr/bin/perl

use lib '/scripts/common_perl/';
use Framework qw(&setALTSParameter &getALTSParameter);

if( $ARGV[0] ne "")
{	
	
	my $Value=getALTSParameter($ARGV[0]);
	if ($Value  eq -1) { print "UNDEF"; exit 1; }
	print "$Value";
	exit 0;
}
else
{
	print "Usage: GetALTSParameter.pl <Parameter_name>\nE.g: GetALTSParameter.pl TestModePossible\n\n";
	die;
}
